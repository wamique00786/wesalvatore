from django.urls import path
from . import views
from .views import ngo_list, donate_to_ngo

urlpatterns = [
    path('donations/', views.donations, name='donations'),
    path('donate/', views.donate_view, name='donate'),
    path('donation-success/', views.donation_success_view, name='donation_success'),  # Add a success view
    path('donations/', views.donation_list, name='donation_list'),
    path('ngos/', ngo_list, name='ngo_list'),  # List of NGOs
    path('donate/ngo/<int:ngo_id>/', donate_to_ngo, name='donate_to_ngo'),
]