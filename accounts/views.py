from django.contrib.auth.models import User
from django.contrib.auth.tokens import default_token_generator
from django.contrib.auth import authenticate, login
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from django.contrib import messages
from django.core.mail import send_mail
from django.conf import settings
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
from django.template.loader import render_to_string
from django.shortcuts import render, redirect
from django.views.decorators.csrf import csrf_exempt
from .models import UserProfile
from .forms import SignUpForm, PasswordResetForm
import logging
from rest_framework import generics
from rest_framework.response import Response
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.permissions import AllowAny  # Import AllowAny
from .serializers import SignUpSerializer, LoginSerializer, PasswordResetRequestSerializer, UserReportSerializer, UserProfileSerializer

logger = logging.getLogger(__name__)

class UserRegistrationView(generics.CreateAPIView):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [AllowAny]

class NearbyVolunteersView(generics.ListAPIView):
    serializer_class = UserProfileSerializer  # Use the same serializer or create a new one for volunteers
    permission_classes = [AllowAny]

    def get_queryset(self):
        user = self.request.user
        lat = self.request.query_params.get('lat')
        lng = self.request.query_params.get('lng')
        if lat and lng:
            return UserProfile.objects.filter(user_type='VOLUNTEER', location__distance_lte=(Point(float(lng), float(lat)), D(km=10)))  # Adjust distance as needed
        return UserProfile.objects.none()

class AdminReportView(generics.CreateAPIView):
    
    # Assuming you have a model for reports
    def post(self, request, *args, **kwargs):
        # Handle the report submission logic here
        return Response({"message": "Report sent to admin."}, status=201)
    

class UserReportView(generics.GenericAPIView):
    serializer_class = UserReportSerializer
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            phone_number = serializer.validated_data['phone_number']
            image = serializer.validated_data['image']
            description = serializer.validated_data['description']

            # Find the nearest volunteer
            nearest_volunteers = UserProfile.objects.filter(user_type='VOLUNTEER').annotate(
                distance=Distance('location', request.user.location)  # Assuming request.user has a location
            ).order_by('distance')[:1]  # Get the nearest volunteer

            # Send report to the nearest volunteer
            if nearest_volunteers.exists():
                volunteer_email = nearest_volunteers[0].user.email  # Assuming UserProfile has a related User model
                subject = "New Animal Report"
                message = f"Phone Number: {phone_number}\nDescription: {description}"
                # Send email with the image as an attachment
                send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, [volunteer_email], fail_silently=False)
            else:
                # If no volunteer is available, send the report to the admin
                admin_email = settings.ADMIN_EMAIL  # Replace with your admin email
                subject = "New Animal Report - No Volunteers Available"
                message = f"Phone Number: {phone_number}\nDescription: {description}\nNo volunteers available."
                send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, [admin_email], fail_silently=False)

            return Response({"message": "Report submitted successfully."}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class PasswordResetRequestView(generics.GenericAPIView):
    serializer_class = PasswordResetRequestSerializer
    permission_classes = [AllowAny]  # Allow any user to access this view

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            user = User.objects.get(email=email)
            subject = "Password Reset Requested"
            email_template_name = "registration/password_reset_email.html"
            context = {
                "email": user.email,
                "domain": request.get_host(),
                "site_name": "Wesalvatore",
                "uid": urlsafe_base64_encode(force_bytes(user.pk)),
                "token": default_token_generator.make_token(user),
                "protocol": "http",
            }
            email = render_to_string(email_template_name, context)
            send_mail(subject, email, settings.DEFAULT_FROM_EMAIL, [user.email], fail_silently=False)
            return Response({"message": "A password reset link has been sent to your email."}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(generics.GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = [AllowAny]  # Allow any user to access this view

    def get(self, request, *args, **kwargs):
        # Example response: returning a message or available fields
        return Response({
            "message": "Please provide your username, password, and user type to log in."
        }, status=status.HTTP_200_OK)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            username = serializer.validated_data['username']
            password = serializer.validated_data['password']
            user_type = serializer.validated_data['user_type']

            user = authenticate(request, username=username, password=password)
            if user is not None:
                try:
                    profile = UserProfile.objects.get(user=user)
                    if profile.user_type == user_type:
                        login(request, user)  # Optional: Only needed if you want to maintain session
                        token, created = Token.objects.get_or_create(user=user)  # Get or create token
                        return Response({
                            "message": "Login successful.",
                            "user_type": profile.user_type,
                            "token": token.key  # Return the token
                        }, status=status.HTTP_200_OK)
                    else:
                        return Response({
                            "error": f"This account is not registered as {user_type}."
                        }, status=status.HTTP_403_FORBIDDEN)
                except UserProfile.DoesNotExist:
                    return Response({
                        "error": "User profile not found."
                    }, status=status.HTTP_404_NOT_FOUND)
            else:
                return Response({
                    "error": "Invalid username or password."
                }, status=status.HTTP_401_UNAUTHORIZED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class SignUpView(generics.CreateAPIView):
    serializer_class = SignUpSerializer
    permission_classes = [AllowAny]  # Allow any user to access this view

    def get(self, request, *args, **kwargs):
        return Response({
            "message": "Please provide the following fields to sign up: username, email, password, user_type, mobile_number."
        }, status=status.HTTP_200_OK)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response({
                "user": serializer.data,
                "message": "User created successfully."
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

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

@csrf_exempt
def password_reset_request(request):
    if request.method == "POST":
        form = PasswordResetForm(request.POST)
        if form.is_valid():
            email = form.cleaned_data['email']
            associated_users = User.objects.filter(email=email)
            if associated_users.exists():
                for user in associated_users:
                    subject = "Password Reset Requested"
                    email_template_name = "registration/password_reset_email.html"
                    context = {
                        "email": user.email,
                        "domain": request.get_host(),
                        "site_name": "Wesalvatore",
                        "uid": urlsafe_base64_encode(force_bytes(user.pk)),
                        "token": default_token_generator.make_token(user),
                        "protocol": "http",
                    }
                    email = render_to_string(email_template_name, context)
                    send_mail(subject, email, settings.DEFAULT_FROM_EMAIL, [user.email], fail_silently=False)
                messages.success(request, "A password reset link has been sent to your email.")
                return redirect("login")
            else:
                messages.error(request, "No user is associated with this email address.")
    else:
        form = PasswordResetForm()
    return render(request, "registration/password_reset.html", {"form": form})