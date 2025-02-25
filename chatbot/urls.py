from django.urls import path
from . import views

urlpatterns = [
    path('', views.chat_home, name='chat_home'),
    path('get_response/', views.get_bot_response, name='get_bot_response'),
]