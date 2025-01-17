from django.contrib.auth.models import User
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib import messages
from .models import Animal, MedicalRecord, AnimalReport, RescueTask
from accounts.models import UserProfile, VolunteerLocation
from donation.models import Donation
from adoption.models import AdoptableAnimal
from .forms import AnimalForm, MedicalRecordForm
from django.http import JsonResponse
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from django.contrib.gis.db.models.functions import Distance
from django.views.decorators.http import require_http_methods
import base64
from django.core.files.base import ContentFile
from .utils import send_notification_to_volunteer
from math import radians, sin, cos, sqrt, atan2
from django.utils import timezone
import logging

logger = logging.getLogger(__name__)

def home(request):
    if request.user.is_authenticated:
        return redirect('dashboard')
    return redirect('login')

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

    # Fetch donations and adoptable animals
    donations = Donation.objects.filter(user=request.user).order_by('-date')[:5]
    adoptable_animals = AdoptableAnimal.objects.all()[:5]

    context = {
        'user_profile': user_profile,
        'recent_reports': recent_reports,
        'donations': donations,
        'adoptable_animals': adoptable_animals,
    }

    response = render(request, 'rescue/user_dashboard.html', context)
    response['Content-Security-Policy'] = (
        "default-src 'self'; "
        "script-src 'self' https://unpkg.com https://cdn.jsdelivr.net; "
        "style-src 'self' https://unpkg.com https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; "
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

@login_required
@require_http_methods(["POST"])
def report_animal(request):
    try:
        # Get data from request
        photo_data = request.POST.get('photo')
        description = request.POST.get('description')
        latitude = float(request.POST.get('latitude'))
        longitude = float(request.POST.get('longitude'))

        # Convert base64 to image file
        format, imgstr = photo_data.split(';base64,')
        ext = format.split('/')[-1]
        photo = ContentFile(base64.b64decode(imgstr), name=f'report_{request.user.id}.{ext}')

        # Create report
        report = AnimalReport.objects.create(
            user=request.user,
            photo=photo,
            description=description,
            latitude=latitude,
            longitude=longitude
        )

        # Find nearest volunteer
        user_location = Point(longitude, latitude)
        nearest_volunteer = UserProfile.objects.filter(
            user_type='VOLUNTEER'
        ).annotate(
            distance=Distance('location', user_location)
        ).order_by('distance').first()

        if nearest_volunteer:
            report.assigned_to = nearest_volunteer.user
            report.status = 'ASSIGNED'
            report.save()

             # Send notification to volunteer (implement your notification system)
            send_notification_to_volunteer(nearest_volunteer, report)

        return JsonResponse({'status': 'success', 'volunteer': nearest_volunteer.user.username if nearest_volunteer else 'None'})
    except Exception as e:
        logger.error(f"Error reporting animal: {str(e)}")  # Log the error
        return JsonResponse({'status': 'error', 'message': str(e)})
    
@login_required
def nearby_volunteers(request):
    try:
        lat = request.GET.get('lat')
        lng = request.GET.get('lng')

        if lat is None or lng is None:
            return JsonResponse({'error': 'Missing latitude or longitude'}, status=400)

        # Validate latitude and longitude
        latitude = float(lat)
        longitude = float(lng)

        if not (-90 <= latitude <= 90) or not (-180 <= longitude <= 180):
            return JsonResponse({'error': 'Invalid latitude or longitude'}, status=400)

        user_location = Point(longitude, latitude)

        # Get volunteers within 10km radius
        nearby = UserProfile.objects.filter(
            user_type='VOLUNTEER'
        ).annotate(
            distance=Distance('location', user_location)
        ).filter(distance__lte=10000).order_by('distance')

        volunteers = [{
            'name': v.user.get_full_name() or v.user.username,
            'latitude': v.location.y,
            'longitude': v.location.x,
            'distance': round(v.distance.m / 1000, 2)  # Convert to km
        } for v in nearby]

        return JsonResponse(volunteers, safe=False)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

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

@login_required
def update_volunteer_location(request):
    if request.method == 'POST':
        latitude = request.POST.get('latitude')
        longitude = request.POST.get('longitude')

        # Update or create volunteer location
        volunteer_location, created = VolunteerLocation.objects.update_or_create(
            volunteer=request.user,
            defaults={'latitude': latitude, 'longitude': longitude}
        )

        return JsonResponse({'status': 'success', 'latitude': latitude, 'longitude': longitude})
    return JsonResponse({'status': 'error'}, status=400)

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