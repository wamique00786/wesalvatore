from django.urls import path
from . import views

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
]