from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.decorators import login_required
from django.contrib.auth import get_user_model
from django.contrib import messages
from django.core.files.base import ContentFile
from django.db import transaction
from django.http import JsonResponse
from .forms import CustomUserCreationForm, CustomAuthenticationForm, BatchAssignmentForm, TaskForm
from .models import CustomUser, UserImage, Volunteer, BatchAssignment, Task
import base64
import random
import json
import logging
from geopy.distance import geodesic

logger = logging.getLogger(__name__)

# Use the custom user model
User = get_user_model()

# Sign-up View
def signup_view(request):
    if request.method == 'POST':
        form = CustomUserCreationForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('login')
    else:
        form = CustomUserCreationForm()
    return render(request, 'accounts/signup.html', {'form': form})

# Login View
def login_view(request):
    if request.method == 'POST':
        form = CustomAuthenticationForm(data=request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            role = form.cleaned_data.get('role')
            user = authenticate(request, username=username, password=password)
            if user is not None and user.role == role:
                login(request, user)
                if role == 'admin':
                    return redirect('admin_dashboard')
                elif role == 'volunteer':
                    return redirect('volunteer_dashboard')
                return redirect('user_dashboard')
            else:
                form.add_error(None, "Invalid credentials or role.")
    else:
        form = CustomAuthenticationForm()
    return render(request, 'accounts/login.html', {'form': form})

# Logout View
@login_required
def logout_view(request):
    logout(request)
    return redirect('login')

# Admin Dashboard
@login_required
def admin_dashboard(request):
    if request.user.role != 'admin':
        return redirect('access_denied')

    if request.method == 'POST':
        volunteer_id = request.POST.get('volunteer_id')
        batch_no = random.randint(100000, 999999)
        while BatchAssignment.objects.filter(batch_number=batch_no).exists():
            batch_no = random.randint(100000, 999999)

        volunteer = Volunteer.objects.get(id=volunteer_id)
        BatchAssignment.objects.create(
            user=volunteer.user,
            volunteer=volunteer,
            batch_number=batch_no
        )
        messages.success(request, f"Batch Number {batch_no} assigned to {volunteer.user.username}")
        return redirect('admin_dashboard')

    volunteers = Volunteer.objects.all()
    return render(request, 'accounts/admin_dashboard.html', {'volunteers': volunteers})

# Volunteer Dashboard
@login_required
def volunteer_dashboard(request):
    if request.user.role != 'volunteer':
        return redirect('access_denied')

    tasks = Task.objects.filter(volunteer__user=request.user)
    return render(request, 'accounts/volunteer_dashboard.html', {'tasks': tasks})

@login_required
def mark_task_completed(request, task_id):
    if request.user.role != 'volunteer':
        return redirect('access_denied')

    task = Task.objects.get(id=task_id)
    if task.volunteer.user == request.user:
        task.status = 'Completed'
        task.save()
        return redirect('volunteer_dashboard')
    return redirect('access_denied')

# User Dashboard
@login_required
def user_dashboard(request):
    if request.method == "POST":
        uploaded_image = request.FILES.get('image')
        user_location = request.POST.get('location')

        if not uploaded_image or not user_location:
            return render(request, 'accounts/user_dashboard.html', {'error': 'Please upload an image and ensure your location is detected.'})

        try:
            latitude, longitude = map(float, user_location.split(","))
        except ValueError:
            return render(request, 'accounts/user_dashboard.html', {'error': 'Invalid location format.'})

        try:
            nearest_volunteer = Volunteer.get_nearest(latitude, longitude)
        except Exception as e:
            logger.error(f"Error finding nearest volunteer: {e}")
            nearest_volunteer = None

        UserImage.objects.create(
            user=request.user,
            image=uploaded_image,
            location=user_location,
            latitude=latitude,
            longitude=longitude,
            volunteer=nearest_volunteer
        )

        return redirect('picture_sent_successfully')

    user_tasks = request.user.user_images.all()
    return render(request, 'accounts/user_dashboard.html', {'user': request.user, 'user_tasks': user_tasks})

# Access Denied
def access_denied(request):
    return render(request, 'accounts/access_denied.html')

# Picture Sent Success View
def picture_sent_successfully(request):
    return render(request, 'accounts/picture_sent_successfully.html')

# Manage Volunteers
@login_required
def manage_volunteers(request):
    if request.user.role != 'admin':
        return redirect('access_denied')

    volunteers = Volunteer.objects.all()
    return render(request, 'accounts/manage_volunteers.html', {'volunteers': volunteers})

# Assign Tasks
@login_required
def assign_task(request):
    if request.user.role != 'admin':
        return redirect('access_denied')

    if request.method == 'POST':
        form = TaskForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, "Task assigned successfully!")
            return redirect('assign_task')
    else:
        form = TaskForm()

    tasks = Task.objects.all()
    return render(request, 'accounts/assign_task.html', {'form': form, 'tasks': tasks})

# Get Nearest Volunteers (API)
def get_nearest_volunteers(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            latitude = float(data.get('latitude'))
            longitude = float(data.get('longitude'))

            nearest_volunteer = Volunteer.get_nearest(latitude, longitude)
            if nearest_volunteer:
                response_data = {
                    'volunteer': {
                        'id': nearest_volunteer.id,
                        'username': nearest_volunteer.user.username,
                        'latitude': nearest_volunteer.latitude,
                        'longitude': nearest_volunteer.longitude,
                    }
                }
            else:
                response_data = {'message': 'No volunteers available nearby.'}

            return JsonResponse(response_data, status=200)
        except (ValueError, KeyError, TypeError):
            return JsonResponse({'error': 'Invalid data provided.'}, status=400)
    return JsonResponse({'error': 'Invalid request method.'}, status=405)

# Assign Batch
@login_required
def assign_batch(request):
    if request.user.role != 'admin':  # Ensure only admins can access
        return redirect('access_denied')

    volunteers = Volunteer.objects.all()

    if request.method == 'POST':
        volunteer_id = request.POST.get('volunteer_id')
        volunteer = Volunteer.objects.get(id=volunteer_id)
        batch_no = random.randint(100000, 999999)
        BatchAssignment.objects.create(volunteer=volunteer, batch_number=batch_no)

        messages.success(request, f"Batch number {batch_no} assigned to {volunteer.user.username}")
        return redirect('assign_batch')

    return render(request, 'accounts/assign_batch.html', {'volunteers': volunteers})

# Manage Users
@login_required
def manage_users(request):
    if request.user.role != 'admin':  # Ensure only admins can access this view
        return redirect('access_denied')

    users = User.objects.all()  # Retrieve all users
    return render(request, 'accounts/manage_users.html', {'users': users})

@login_required
def assign_volunteer(request, user_id):
    if request.user.role != 'admin':
        return redirect('access_denied')

    user = get_object_or_404(CustomUser, id=user_id)

    if request.method == 'POST':
        volunteer_id = request.POST.get('volunteer_id')
        volunteer = get_object_or_404(Volunteer, id=volunteer_id)
        user.volunteer = volunteer
        user.save()

        messages.success(request, f"Volunteer {volunteer.user.username} assigned to {user.username}.")
        return redirect('manage_users')

    volunteers = Volunteer.objects.all()
    return render(request, 'accounts/assign_volunteer.html', {'user': user, 'volunteers': volunteers})

@login_required
def submit_image(request):
    if request.method == 'POST' and request.FILES.get('image'):
        uploaded_image = request.FILES['image']
        user_location = request.POST.get('location')
        
        # Process the image and location here
        user_image = UserImage.objects.create(
            user=request.user,
            image=uploaded_image,
            location=user_location
        )
        return redirect('picture_sent_successfully')  # Redirect to a success page or another view

    return render(request, 'accounts/submit_image.html')