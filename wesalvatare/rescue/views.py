from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib import messages
from .models import UserProfile, Animal, MedicalRecord, AnimalReport, Donation, AdoptableAnimal, VolunteerProfile
from .forms import SignUpForm, AnimalForm, MedicalRecordForm
from django.contrib.auth import authenticate, login
from django.http import JsonResponse
from django.contrib.gis.geos import Point
from django.contrib.gis.db.models.functions import Distance
from django.views.decorators.http import require_http_methods
import json
import base64
from django.core.files.base import ContentFile
from .utils import send_notification_to_volunteer
from math import radians, sin, cos, sqrt, atan2

def signup(request):
    if request.method == 'POST':
        form = SignUpForm(request.POST)
        if form.is_valid():
            # Create user but don't save to database yet
            user = form.save(commit=False)
            user.save()  # Now save the user

            # Update the UserProfile that was automatically created by the signal
            user_type = form.cleaned_data.get('user_type')
            try:
                user_profile = UserProfile.objects.get(user=user)
                user_profile.user_type = user_type
                user_profile.save()
            except UserProfile.DoesNotExist:
                UserProfile.objects.create(user=user, user_type=user_type)

            messages.success(request, 'Account created successfully. Please login.')
            return redirect('login')
    else:
        form = SignUpForm()
    return render(request, 'registration/signup.html', {'form': form})

def home(request):
    if request.user.is_authenticated:
        return redirect('dashboard')
    return redirect('login')

def custom_login(request):
    if request.user.is_authenticated:
        profile = UserProfile.objects.get(user=request.user)
        if profile.user_type == 'VOLUNTEER':
            return redirect('volunteer_dashboard')
        elif profile.user_type == 'ADMIN':
            return redirect('admin_dashboard')
        return redirect('user_dashboard')

    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        user_type = request.POST['user_type']
        
        print(f"Login attempt - Username: {username}, User Type: {user_type}")  # Debug print
        
        user = authenticate(request, username=username, password=password)
        
        if user is not None:
            try:
                profile = UserProfile.objects.get(user=user)
                print(f"Found profile type: {profile.user_type}")  # Debug print
                
                if profile.user_type == user_type:
                    login(request, user)
                    print(f"Login successful, redirecting to {user_type} dashboard")  # Debug print
                    
                    if user_type == 'VOLUNTEER':
                        print("Redirecting to volunteer dashboard")  # Debug print
                        return redirect('volunteer_dashboard')
                    elif user_type == 'ADMIN':
                        return redirect('admin_dashboard')
                    else:
                        return redirect('user_dashboard')
                else:
                    messages.error(request, f'This account is not registered as {user_type}')
            except UserProfile.DoesNotExist:
                messages.error(request, 'User profile not found')
        else:
            messages.error(request, 'Invalid username or password')
    
    return render(request, 'registration/login.html')

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
    print("Accessing volunteer dashboard view")  # Debug print
    try:
        user_profile = UserProfile.objects.get(user=request.user)
        print(f"User profile type: {user_profile.user_type}")  # Debug print
        
        if user_profile.user_type != 'VOLUNTEER':
            messages.error(request, 'Access denied. Volunteer privileges required.')
            return redirect('user_dashboard')
        
        context = {
            'user_profile': user_profile,
            'total_animals': Animal.objects.count(),
            'under_treatment': Animal.objects.filter(status='TREATMENT').count(),
            'recovered': Animal.objects.filter(status='RECOVERED').count(),
            'recent_animals': Animal.objects.order_by('-rescue_date')[:5],
        }
        return render(request, 'rescue/volunteer_dashboard.html', context)
    except UserProfile.DoesNotExist:
        messages.error(request, 'User profile not found')
        return redirect('login')

@login_required
def admin_dashboard(request):
    user_profile = UserProfile.objects.get(user=request.user)
    if user_profile.user_type != 'ADMIN':
        return redirect(f'{user_profile.user_type.lower()}_dashboard')
    
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
    medical_records = animal.medicalrecord_set.all()
    
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

        return JsonResponse({'status': 'success'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})

@login_required
def nearby_volunteers(request):
    try:
        latitude = float(request.GET.get('lat'))
        longitude = float(request.GET.get('lng'))
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

def adopt_animal(request):
    # Fetch all adoptable animals
    adoptable_animals = AdoptableAnimal.objects.filter(is_adoptable=True)

    context = {
        'adoptable_animals': adoptable_animals,
    }

    return render(request, 'rescue/adopt_animal.html', context)

def donations(request):
    # Fetch all donations
    donations_list = Donation.objects.all().order_by('-date')

    context = {
        'donations': donations_list,
    }

    return render(request, 'rescue/donations.html', context)

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
    volunteers = VolunteerProfile.objects.all()
    nearby_volunteers = []

    for volunteer in volunteers:
        distance = calculate_distance(animal_lat, animal_lon, volunteer.latitude, volunteer.longitude)
        if distance <= radius_km:
            nearby_volunteers.append(volunteer)

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