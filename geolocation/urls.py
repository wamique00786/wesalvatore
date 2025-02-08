from django.urls import path
from . import views

urlpatterns = [
    path('map/', views.map_view, name='map_view'),
    path('save-location/', views.save_location, name='save_location'),
]