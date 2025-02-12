from django.urls import path
from . import views
from .views import ngo_list, donate_to_ngo

urlpatterns = [
    path('donations/', views.donations, name='donations'),
    path('donation-success/', views.donation_success_view, name='donation_success'),  # Add a success view
    path('organizations/', ngo_list, name='ngo_list'),  # List of NGOs
    path('organization/<int:ngo_id>/', donate_to_ngo, name='donate_to_ngo'),
]