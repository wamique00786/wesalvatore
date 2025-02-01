# subscription/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('plans/', views.subscription_plans, name='subscription_plans'),
    path('buy/<int:plan_id>/', views.buy_subscription, name='buy_subscription'),
    path('get-exchange-rate/', views.get_exchange_rate, name='get_exchange_rate'),
]