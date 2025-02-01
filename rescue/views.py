from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib import messages
from .models import Animal, MedicalRecord, AnimalReport, RescueTask, VolunteerLocation, UserLocationHistory
from accounts.models import UserProfile
from .forms import AnimalForm, MedicalRecordForm
from django.http import JsonResponse
from django.core.mail import send_mail
from django.conf import settings
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
# from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import ensure_csrf_cookie
import base64
from django.core.files.base import ContentFile
from .utils import send_notification_to_volunteer
from math import radians, sin, cos, sqrt, atan2
from django.utils import timezone
from datetime import timedelta
import logging
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny  # Import AllowAny
from .serializers import AnimalReportSerializer
from accounts.serializers import UserProfileSerializer
from django.contrib.auth import get_user_model

logger = logging.getLogger(__name__)

User = get_user_model()
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def save_user_location(request):
    try:
        latitude = float(request.data.get('latitude'))
        longitude = float(request.data.get('longitude'))
        current_time = timezone.now()

        # Create Point object
        location_point = Point(longitude, latitude, srid=4326)
        
        # Update user's current location
        user_profile = request.user.userprofile
        
        # Only save if location has changed significantly (more than 10 meters)
        should_save = False
        if not user_profile.location:
            should_save = True
        elif user_profile.location.distance(location_point) > 0.01:  # 10 meters
            should_save = True
            
        if should_save:
            # Update current location
            user_profile.location = location_point
            user_profile.last_location_update = current_time
            user_profile.save()

            # Save to location history
            UserLocationHistory.objects.create(
                user=request.user,
                location=location_point,
                timestamp=current_time,
                user_type=user_profile.user_type
            )
            
            # Clean up old location history (keep last 24 hours)
            cleanup_time = current_time - timedelta(hours=24)
            UserLocationHistory.objects.filter(
                user=request.user,
                timestamp__lt=cleanup_time
            ).delete()
        
        return JsonResponse({
            'status': 'success',
            'message': 'Location updated successfully',
            'location_saved': should_save
        })
    except Exception as e:
        logger.error(f"Error saving location: {str(e)}")
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=400)
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_all_users_locations(request):
    try:
        # Get active users (updated in last 5 minutes)
        active_time = timezone.now() - timedelta(minutes=5)
        users = UserProfile.objects.filter(
            location__isnull=False,
            last_location_update__gte=active_time
        )
        
        users_data = []
        
        for user_profile in users:
            # Get location history for the last hour
            history = UserLocationHistory.objects.filter(
                user=user_profile.user,
                timestamp__gte=timezone.now() - timedelta(hours=1)
            ).order_by('-timestamp')
            
            location_history = [{
                'latitude': h.location.y,
                'longitude': h.location.x,
                'timestamp': h.timestamp.isoformat()
            } for h in history]
            
            users_data.append({
                'id': user_profile.user.id,
                'username': user_profile.user.username,
                'phone': user_profile.mobile_number,
                'user_type': user_profile.user_type,
                'location': {
                    'latitude': user_profile.location.y,
                    'longitude': user_profile.location.x,
                    'last_update': user_profile.last_location_update.isoformat()
                },
                'location_history': location_history
            })
        
        return JsonResponse({
            'status': 'success',
            'users': users_data
        })
    except Exception as e:
        logger.error(f"Error getting locations: {str(e)}")
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=400)
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_info(request):
    try:
        user_profile = request.user.userprofile
        return JsonResponse({
            'username': request.user.username,
            'phone': user_profile.mobile_number,
            'location': {
                'latitude': user_profile.location.y if user_profile.location else None,
                'longitude': user_profile.location.x if user_profile.location else None
            },
            'user_type': user_profile.user_type
        })
    except Exception as e:
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=400)

class NearbyVolunteersView(generics.ListAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        try:
            lat = self.request.query_params.get('lat')
            lng = self.request.query_params.get('lng')
            
            if not lat or not lng:
                return UserProfile.objects.none()

            # Convert to float and create Point
            user_location = Point(
                float(lng),  # longitude first
                float(lat),  # latitude second
                srid=4326
            )

            # Query for nearby volunteers with distance annotation
            volunteers = UserProfile.objects.filter(
                user_type='VOLUNTEER',
                location__isnull=False
            ).annotate(
                distance=Distance('location', user_location)
            ).filter(
                distance__lte=D(km=10)  # 10km radius
            ).order_by('distance')

            return volunteers

        except (ValueError, TypeError) as e:
            print(f"Error in NearbyVolunteersView: {str(e)}")
            return UserProfile.objects.none()

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['distance'] = True  # Add flag to include distance in serializer
        return context

class UserReportView(generics.CreateAPIView):
    serializer_class = AnimalReportSerializer
    permission_classes = [IsAuthenticated]

    def create(self, request, *args, **kwargs):
        try:
            # Log the incoming request data for debugging
            logger.info(f"Received data: {request.data}")
            logger.info(f"Files: {request.FILES}")

            # Validate incoming data
            if 'photo' not in request.FILES:
                return Response({
                    'status': 'error',
                    'message': 'Photo is required'
                }, status=status.HTTP_400_BAD_REQUEST)

            if not request.data.get('description'):
                return Response({
                    'status': 'error',
                    'message': 'Description is required'
                }, status=status.HTTP_400_BAD_REQUEST)

            if not request.data.get('latitude') or not request.data.get('longitude'):
                return Response({
                    'status': 'error',
                    'message': 'Location coordinates are required'
                }, status=status.HTTP_400_BAD_REQUEST)

            # Create report object directly
            report = AnimalReport.objects.create(
                user=request.user,
                photo=request.FILES['photo'],
                description=request.data['description'],
                location=Point(
                    float(request.data['longitude']),
                    float(request.data['latitude']),
                    srid=4326
                ),
                status='PENDING'
            )

            # Find nearest volunteer within 10km
            nearest_volunteer = UserProfile.objects.filter(
                user_type='VOLUNTEER',
                location__isnull=False,
                location__distance_lte=(report.location, D(km=10))
            ).annotate(
                distance=Distance('location', report.location)
            ).order_by('distance').first()

            if nearest_volunteer:
                # Assign to nearest volunteer
                report.assigned_to = nearest_volunteer.user
                report.status = 'ASSIGNED'
                report.save()
                
                # Send notification to volunteer
                send_notification_to_volunteer(nearest_volunteer, report)
                
                return Response({
                    'status': 'success',
                    'message': 'Report submitted and assigned to volunteer',
                    'volunteer': {
                        'name': nearest_volunteer.user.get_full_name() or nearest_volunteer.user.username,
                        'distance': f"{nearest_volunteer.distance.km:.2f} km"
                    }
                }, status=status.HTTP_201_CREATED)
            
            # If no volunteer found, assign to admin
            admin_profile = UserProfile.objects.filter(user_type='ADMIN').first()
            if admin_profile:
                report.assigned_to = admin_profile.user
                report.status = 'ADMIN_REVIEW'
                report.save()

                # Send notification to admin
                send_mail(
                    subject="New Animal Report - No Volunteers Available",
                    message=f"""
                    A new animal report requires admin attention.
                    Description: {report.description}
                    Location: {report.location.y}, {report.location.x}
                    Reported by: {request.user.get_full_name() or request.user.username}
                    Contact: {request.user.userprofile.mobile_number}
                    """,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[admin_profile.user.email],
                    fail_silently=False
                )
                
                return Response({
                    'status': 'success',
                    'message': 'No nearby volunteers available. Report assigned to admin.',
                    'assigned_to': 'admin'
                }, status=status.HTTP_201_CREATED)
            
            return Response({
                'status': 'success',
                'message': 'Report submitted. Waiting for assignment.',
            }, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            logger.error(f"Error in UserReportView: {str(e)}")
            return Response({
                'status': 'error',
                'message': f"Error processing report: {str(e)}"
            }, status=status.HTTP_400_BAD_REQUEST)
        
    def get(self, request, *args, **kwargs):
        return Response({
            'message': 'Please use POST method to submit an animal report.',
            'required_fields': {
                'photo': 'Image file from camera',
                'description': 'Text description of the situation',
                'latitude': 'Current location latitude',
                'longitude': 'Current location longitude'
            }
        }, status=status.HTTP_405_METHOD_NOT_ALLOWED)

def home(request):
    if request.user.is_authenticated:
        return redirect('dashboard')
    return render(request, 'landing_page.html')

# Add these decorator functions
def is_admin(user):
    return hasattr(user, 'userprofile') and user.userprofile.user_type == 'ADMIN'

def is_volunteer(user):
    return hasattr(user, 'userprofile') and user.userprofile.user_type == 'VOLUNTEER'

# Modify your existing views to add role-based access
@login_required
@user_passes_test(lambda u: is_admin(u) or is_volunteer(u))
def animal_list(request):
    animals = Animal.objects.all()
    return render(request, 'rescue/animal_list.html', {'animals': animals})

@login_required
def user_dashboard(request):
    user_profile = UserProfile.objects.get(user=request.user)
    if user_profile.user_type != 'USER':
        return redirect(f'{user_profile.user_type.lower()}_dashboard')
    
    # Fetch recent animal reports by the user
    recent_reports = AnimalReport.objects.filter(user=request.user).order_by('-timestamp')[:5]

    context = {
        'user_profile': user_profile,
        'recent_reports': recent_reports,
    }

    response = render(request, 'rescue/user_dashboard.html', context)
    response['Content-Security-Policy'] = (
        "default-src 'self'; "
        "script-src 'self' 'unsafe-inline' https://unpkg.com https://cdn.jsdelivr.net; "
        "style-src 'self' 'unsafe-inline' https://unpkg.com https://cdn.jsdelivr.net; "
        "img-src 'self' blob: data: https://unpkg.com; "
        "media-src 'self' blob:; "
        "object-src 'none';"
    )
    return response

@login_required
def volunteer_dashboard(request):
    print(f"Logged in user: {request.user.username}")  # Debug print
    try:
        # Fetch the user's profile
        user_profile = UserProfile.objects.get(user=request.user)
        print(f"User profile type: {user_profile.user_type}")  # Debug print
        
        # Check if the user is a volunteer
        if user_profile.user_type != 'VOLUNTEER':
            messages.error(request, 'Access denied. Volunteer privileges required.')
            return redirect('user_dashboard')
        
        # Fetch all volunteers' locations
        volunteers = UserProfile.objects.filter(user_type='VOLUNTEER').exclude(location__isnull=True)

        # Fetch tasks assigned to the volunteer
        available_tasks = RescueTask.objects.filter(assigned_to=request.user, is_completed=False)
        completed_tasks = RescueTask.objects.filter(assigned_to=request.user, is_completed=True)

        print(f"Available tasks for {request.user.username}: {available_tasks}")
        print(f"Completed tasks for {request.user.username}: {completed_tasks}")

        # Prepare context data
        context = {
            'user_profile': user_profile,
            'total_animals': Animal.objects.count(),
            'under_treatment': Animal.objects.filter(status='TREATMENT').count(),
            'recovered': Animal.objects.filter(status='RECOVERED').count(),
            'recent_animals': Animal.objects.order_by('-rescue_date')[:5],
            'volunteers': volunteers,
            'available_tasks': available_tasks,  # Add available tasks to context
            'completed_tasks': completed_tasks,  # Add completed tasks to context
        }
        
        # Set cookies for the volunteer's location
        if user_profile.location:
            latitude = user_profile.location.y  # Assuming location is a PointField (longitude, latitude)
            longitude = user_profile.location.x
            response = render(request, 'rescue/volunteer_dashboard.html', context)
            response.set_cookie('user_latitude', latitude, max_age=60*60*24*7)  # Store for 7 days
            response.set_cookie('user_longitude', longitude, max_age=60*60*24*7)  # Store for 7 days
            return response

        return render(request, 'rescue/volunteer_dashboard.html', context)  # Pass the full context
    except UserProfile.DoesNotExist:
        messages.error(request, 'User profile not found')
        return redirect('login')

@login_required
def admin_dashboard(request):
    user_profile = UserProfile.objects.get(user=request.user)
    if user_profile.user_type != 'ADMIN':
        return redirect(f'{user_profile.user_type.lower()}_dashboard')
    
    volunteers = UserProfile.objects.all()
    
    context = {
        'user_profile': user_profile,
        'total_animals': Animal.objects.count(),
        'under_treatment': Animal.objects.filter(status='TREATMENT').count(),
        'recovered': Animal.objects.filter(status='RECOVERED').count(),
        'volunteer_count': UserProfile.objects.filter(user_type='VOLUNTEER').count(),
        'recent_animals': Animal.objects.order_by('-rescue_date')[:5],
        'volunteers': UserProfile.objects.filter(user_type='VOLUNTEER'),
    }
    return render(request, 'rescue/admin_dashboard.html', context)

@login_required
def dashboard(request):
    try:
        user_profile = UserProfile.objects.get(user=request.user)
        # Redirect based on user type
        if user_profile.user_type == 'VOLUNTEER':
            return redirect('volunteer_dashboard')
        elif user_profile.user_type == 'ADMIN':
            return redirect('admin_dashboard')
        else:
            return redirect('user_dashboard')
    except UserProfile.DoesNotExist:
        # Create a default user profile if it doesn't exist
        user_profile = UserProfile.objects.create(
            user=request.user,
            user_type='USER'
        )
        return redirect('user_dashboard')
    
@login_required
def animal_list(request):
    animals = Animal.objects.all()
    return render(request, 'rescue/animal_list.html', {'animals': animals})

@login_required
def animal_detail(request, pk):
    animal = get_object_or_404(Animal, pk=pk)
    print(f"Animal: {animal}")  # Debugging line
    try:
        medical_records = animal.medical_records.all()
        print(f"Medical Records: {medical_records}")  # Debugging line
    except AttributeError as e:
        print(f"Error: {e}")  # Debugging line
        raise
    if request.method == 'POST':
        form = MedicalRecordForm(request.POST)
        if form.is_valid():
            medical_record = form.save(commit=False)
            medical_record.animal = animal
            medical_record.created_by = request.user
            medical_record.save()
            messages.success(request, 'Medical record added successfully.')
            return redirect('animal_detail', pk=pk)
    else:
        form = MedicalRecordForm()

    return render(request, 'rescue/animal_detail.html', {
        'animal': animal,
        'medical_records': medical_records,
        'form': form,
    })

@login_required
def animal_create(request):
    if request.method == 'POST':
        form = AnimalForm(request.POST, request.FILES)
        if form.is_valid():
            animal = form.save()
            messages.success(request, 'Animal record created successfully.')
            return redirect('animal_detail', pk=animal.pk)
    else:
        form = AnimalForm()
    
    return render(request, 'rescue/animal_form.html', {'form': form, 'title': 'Add New Animal'})

@login_required
def animal_edit(request, pk):
    animal = get_object_or_404(Animal, pk=pk)
    
    if request.method == 'POST':
        form = AnimalForm(request.POST, request.FILES, instance=animal)
        if form.is_valid():
            animal = form.save()
            messages.success(request, 'Animal record updated successfully.')
            return redirect('animal_detail', pk=animal.pk)
    else:
        form = AnimalForm(instance=animal)
    
    return render(request, 'rescue/animal_form.html', {
        'form': form, 
        'title': f'Edit {animal.name}'
    })

@api_view(['POST'])
def report_animal(request):
    try:
        # Get data from request
        photo_data = request.data.get('photo')
        description = request.data.get('description')
        latitude = float(request.data.get('latitude'))
        longitude = float(request.data.get('longitude'))

        # Create a point for the report location
        report_location = Point(longitude, latitude, srid=4326)

        # Process photo data
        if isinstance(photo_data, str) and photo_data.startswith('data:image'):
            format, imgstr = photo_data.split(';base64,')
            ext = format.split('/')[-1]
            photo = ContentFile(base64.b64decode(imgstr), name=f'report_{request.user.id}.{ext}')
        else:
            photo = request.FILES.get('photo')

        # Create report
        report = AnimalReport.objects.create(
            user=request.user,
            photo=photo,
            description=description,
            location=report_location,
            status='PENDING'
        )

        # Find nearest volunteer within 10km radius
        nearest_volunteer = UserProfile.objects.filter(
            user_type='VOLUNTEER',
            location__isnull=False,
            location__distance_lte=(report_location, D(km=10))
        ).annotate(
            distance=Distance('location', report_location)
        ).order_by('distance').first()

        if nearest_volunteer:
            # Assign to nearest volunteer
            report.assigned_to = nearest_volunteer.user
            report.status = 'ASSIGNED'
            report.save()

            # Send notification to volunteer
            send_notification_to_volunteer(nearest_volunteer, report)

            return JsonResponse({
                'status': 'success',
                'message': 'Report submitted and assigned to volunteer',
                'volunteer': {
                    'name': nearest_volunteer.user.get_full_name() or nearest_volunteer.user.username,
                    'distance': f"{nearest_volunteer.distance.km:.2f} km"
                }
            })
        else:
            # If no volunteer found, assign to admin
            admin_profile = UserProfile.objects.filter(user_type='ADMIN').first()
            if admin_profile:
                report.assigned_to = admin_profile.user
                report.status = 'ADMIN_REVIEW'
                report.save()

                return JsonResponse({
                    'status': 'success',
                    'message': 'No nearby volunteers available. Report assigned to admin.',
                    'assigned_to': 'admin'
                })
            else:
                return JsonResponse({
                    'status': 'success',
                    'message': 'Report submitted. Waiting for assignment.',
                })

    except Exception as e:
        logger.error(f"Error reporting animal: {str(e)}")
        return JsonResponse({
            'status': 'error',
            'message': 'Failed to submit report. Please try again.'
        }, status=400)
    
@api_view(['GET'])
def nearby_volunteers(request):
    try:
        lat = float(request.GET.get('lat'))
        lng = float(request.GET.get('lng'))
        radius = float(request.GET.get('radius', 10))  # Default 10km
        
        user_location = Point(lng, lat, srid=4326)
        
        nearby_volunteers = UserProfile.objects.filter(
            user_type='VOLUNTEER',
            location__isnull=False,
            location__distance_lte=(user_location, D(km=radius))
        ).annotate(
            distance=Distance('location', user_location)
        ).order_by('distance')

        volunteer_data = [{
            'id': v.user.id,
            'name': v.user.get_full_name() or v.user.username,
            'distance': f"{v.distance.km:.2f}",
            'location': {
                'latitude': v.location.y,
                'longitude': v.location.x
            }
        } for v in nearby_volunteers]

        return Response({
            'status': 'success',
            'volunteers': volunteer_data
        })
    except Exception as e:
        logger.error(f"Error fetching nearby volunteers: {str(e)}")
        return Response({
            'status': 'error',
            'message': str(e)
        }, status=400)
    
@api_view(['POST'])
def save_user_location(request):
    try:
        latitude = float(request.data.get('latitude'))
        longitude = float(request.data.get('longitude'))
        
        user_profile = request.user.userprofile
        user_profile.location = Point(longitude, latitude, srid=4326)
        user_profile.save()
        
        return JsonResponse({'status': 'success'})
    except Exception as e:
        logger.error(f"Error saving user location: {str(e)}")
        return JsonResponse({
            'status': 'error',
            'message': str(e)
        }, status=400)
        
def volunteer_locations(request):
    volunteers = UserProfile.objects.filter(user_type='VOLUNTEER').exclude(location__isnull=True)
    data = [
        {
            'username': volunteer.user.username,
            'latitude': volunteer.location.y,
            'longitude': volunteer.location.x
        }
        for volunteer in volunteers
    ]
    return JsonResponse(data, safe=False)

def calculate_distance(lat1, lon1, lat2, lon2):
      # Convert latitude and longitude from degrees to radians
      lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])

      # Haversine formula
      dlon = lon2 - lon1
      dlat = lat2 - lat1
      a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
      c = 2 * atan2(sqrt(a), sqrt(1-a))
      r = 6371  # Radius of earth in kilometers
      return r * c

def get_nearest_volunteers(animal_lat, animal_lon, radius_km=10):
    # Create a point for the animal's location
    animal_location = Point(animal_lon, animal_lat)  # Note: (longitude, latitude)

    # Fetch volunteers within the specified radius
    nearby_volunteers = UserProfile.objects.filter(
        user_type='VOLUNTEER',
        location__distance_lte=(animal_location, D(km=radius_km))
    )

    return nearby_volunteers

def animal_location_view(request, animal_id):
    animal = get_object_or_404(Animal, id=animal_id)
    medical_records = MedicalRecord.objects.filter(animal=animal)
    nearby_volunteers = get_nearest_volunteers(animal.latitude, animal.longitude)  # Assuming Animal has latitude and longitude

    context = {
        'animal': animal,
        'medical_records': medical_records,
        'nearby_volunteers': nearby_volunteers,
    }
    return render(request, 'rescue/animal_location.html', context)

@login_required
def rescued_animals_today(request):
    today = timezone.now().date()
    rescued_animals = Animal.objects.filter(rescue_date=today)

    return render(request, 'rescue/rescued_animals_today.html', {
        'rescued_animals': rescued_animals,
        'total_rescued_today': rescued_animals.count(),
    })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ensure_csrf_cookie
def update_volunteer_location(request):
    print("Received location update request")  # Debug print
    try:
        latitude = float(request.data.get('latitude'))
        longitude = float(request.data.get('longitude'))

        print(f"Received coordinates: lat={latitude}, lng={longitude}")  # Debug print
        
        # Create a Point object with SRID 4326 (WGS 84)
        location = Point(longitude, latitude, srid=4326)
        
        # Update the volunteer's location
        user_profile = request.user.userprofile
        user_profile.location = location
        user_profile.save()
        
        print("Location updated successfully")  # Debug print

        return Response({'status': 'success'})
    except Exception as e:
        return Response({'status': 'error', 'message': str(e)}, status=400)

def get_volunteer_locations(request):
    locations = []
    for location in VolunteerLocation.objects.all():
        locations.append({
            'id': location.volunteer.id,
            'name': location.volunteer.username,
            'latitude': location.latitude,
            'longitude': location.longitude,
        })
    return JsonResponse(locations, safe=False)

@login_required
def complete_task(request, task_id):
    task = get_object_or_404(RescueTask, id=task_id, assigned_to=request.user)
    task.is_completed = True
    task.save()
    return redirect('volunteer_dashboard')  # Redirect back to the dashboard

@user_passes_test(lambda u: u.is_staff)  # Ensure only admins can access this view
def add_task(request):
    if request.method == 'POST':
        title = request.POST.get('title')
        description = request.POST.get('description')
        assigned_to = request.POST.get('assigned_to')  # Get the user ID from the form
        task = RescueTask.objects.create(
            title=title,
            description=description,
            assigned_to_id=assigned_to
        )
        return redirect('volunteer_dashboard')  # Redirect to the dashboard or task list

    # Fetch all volunteers for the assignment form
    volunteers = User.objects.filter(is_staff=False)  # Assuming non-staff are volunteers
    return render(request, 'rescue/add_task.html', {'volunteers': volunteers})
