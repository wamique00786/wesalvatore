# urls.py

from django.urls import path
from .views import custom_logout

urlpatterns = [
    path('logout/', custom_logout, name='logout'),
]