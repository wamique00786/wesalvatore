from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('dashboard/', views.dashboard, name='dashboard'),
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
    path('rescued-animals-today/', views.rescued_animals_today, name='rescued_animals_today'),  # Add this line
    path('api/accounts/volunteers/nearby/', views.nearby_volunteers, name='nearby_volunteers'),
    path('api/update-volunteer-location/', views.update_volunteer_location, name='update_volunteer_location'),
    path('api/volunteers/locations/', views.get_volunteer_locations, name='get_volunteer_locations'),
    path('complete-task/<int:task_id>/', views.complete_task, name='complete_task'),
]