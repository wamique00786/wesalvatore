# subscription/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('plans/', views.subscription_plans, name='subscription_plans'),
    path('buy/<int:plan_id>/', views.buy_subscription, name='buy_subscription'),
    path('update_prices/', views.update_prices, name='update_prices'),  # Dynamic price update endpoint
]