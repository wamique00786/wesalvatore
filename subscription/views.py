from django.shortcuts import render, get_object_or_404, redirect
from .models import SubscriptionPlan
import requests
from django.http import JsonResponse

def subscription_plans(request):
    plans = SubscriptionPlan.objects.all()
    return render(request, 'subscription/plans.html', {'plans': plans})

def buy_subscription(request, plan_id):
    plan = get_object_or_404(SubscriptionPlan, id=plan_id)
    # Handle the logic for processing the purchase, e.g., updating the user's subscription status
    # You can add a success message and redirect to a confirmation page or user dashboard
    return redirect('dashboard')  # Example redirect, replace with actual logic

def get_exchange_rate(request):
    try:
        response = requests.get("https://api.exchangerate-api.com/v4/latest/INR")
        if response.status_code == 200:
            data = response.json()
            rates = data.get("rates", {})
            
            if not rates:
                return JsonResponse({"error": "Exchange rates unavailable"}, status=500)
            
            return JsonResponse({"rates": rates}) 
        
        return JsonResponse({"error": "Failed to fetch exchange rates"}, status=500)
    
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)