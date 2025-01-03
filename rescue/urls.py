from django.urls import path
from . import views
from .views import ngo_list, donate_to_ngo, rescued_animals_today

urlpatterns = [
    path('', views.home, name='home'),
    path('signup/', views.signup, name='signup'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('login/', views.custom_login, name='login'),
    path('user-dashboard/', views.user_dashboard, name='user_dashboard'),
    path('volunteer-dashboard/', views.volunteer_dashboard, name='volunteer_dashboard'),
    path('admin-dashboard/', views.admin_dashboard, name='admin_dashboard'),
    path('animals/', views.animal_list, name='animal_list'),
    path('animal/new/', views.animal_create, name='animal_create'),
    path('animal/<int:pk>/', views.animal_detail, name='animal_detail'),
    path('animal/<int:pk>/edit/', views.animal_edit, name='animal_edit'),
    path('report-animal/', views.report_animal, name='report_animal'),
    path('api/nearby-volunteers/', views.nearby_volunteers, name='nearby_volunteers'),
    path('api/volunteer-locations/', views.volunteer_locations, name='volunteer_locations'),
    path('adopt-animal/', views.adopt_animal, name='adopt_animal'),
    path('donations/', views.donations, name='donations'),
    path('add-animal/', views.add_adoptable_animal, name='add_adoptable_animal'),
    path('donate/', views.donate_view, name='donate'),
    path('donation-success/', views.donation_success_view, name='donation_success'),  # Add a success view
    path('donations/', views.donation_list, name='donation_list'),
    path('ngos/', ngo_list, name='ngo_list'),  # List of NGOs
    path('donate/ngo/<int:ngo_id>/', donate_to_ngo, name='donate_to_ngo'),
    path('rescued-animals-today/', rescued_animals_today, name='rescued_animals_today'),  # Add this line
]