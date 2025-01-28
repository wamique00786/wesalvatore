from django.shortcuts import render, get_object_or_404, redirect
from .models import SubscriptionPlan

def subscription_plans(request):
    plans = SubscriptionPlan.objects.all()
    return render(request, 'subscription/plans.html', {'plans': plans})

def buy_subscription(request, plan_id):
    plan = get_object_or_404(SubscriptionPlan, id=plan_id)
    # Handle the logic for processing the purchase, e.g., updating the user's subscription status
    # You can add a success message and redirect to a confirmation page or user dashboard
    return redirect('dashboard')  # Example redirect, replace with actual logic
