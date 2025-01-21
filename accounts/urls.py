from django.urls import path
from . import views
from .views import SignUpView, LoginView, PasswordResetRequestView, password_reset_request
from django.contrib.auth import views as auth_views  # Import Django's auth views

urlpatterns = [
    path('signup/', views.signup, name='signup'),
    path('login/', views.custom_login, name='login'),
    path('password_reset/', password_reset_request, name='password_reset'),  # Add this line
    path('password_reset/done/', auth_views.PasswordResetDoneView.as_view(), name='password_reset_done'),  # Password reset done
    path('reset/<uidb64>/<token>/', auth_views.PasswordResetConfirmView.as_view(), name='password_reset_confirm'),  # Password reset confirm
    path('reset/done/', auth_views.PasswordResetCompleteView.as_view(), name='password_reset_complete'),  # Password reset complete
    path('signup/api/', SignUpView.as_view(), name='signup_api'),
    path('login/api/', LoginView.as_view(), name='login_api'),  # Login API
    path('password_reset/api/', PasswordResetRequestView.as_view(), name='password_reset_api'),
    
]