from django.urls import path
from . import views
from .views import adopt_view

urlpatterns = [
    path('adopt/', adopt_view, name='adopt'),
    path('adopt-animal/', views.adopt_animal, name='adopt_animal'),
    path('add-animal/', views.add_adoptable_animal, name='add_adoptable_animal'),
    path('adoptable-animals/', views.adoptable_animals_list, name='adoptable_animals_list'),  # Ensure this line is present
]