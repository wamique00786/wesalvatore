# subscription/admin.py
from django.contrib import admin
from .models import SubscriptionPlan

@admin.register(SubscriptionPlan)
class SubscriptionPlanAdmin(admin.ModelAdmin):
    list_display = ('plan_type', 'monthly_prices', 'annual_prices')
    search_fields = ('plan_type',)