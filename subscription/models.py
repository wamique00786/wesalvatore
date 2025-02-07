# subscription/models.py
from django.db import models

class SubscriptionPlan(models.Model):
    PLAN_CHOICES = [
        ('bronze', 'Bronze'),
        ('silver', 'Silver'),
        ('gold', 'Gold'),
    ]
    
    plan_type = models.CharField(max_length=6, choices=PLAN_CHOICES)

    # JSON fields to store country-wise prices
    monthly_prices = models.JSONField(default=dict)  # Example: {"US": 10.0, "IN": 750.0, "GB": 8.0}
    annual_prices = models.JSONField(default=dict)   # Example: {"US": 100.0, "IN": 7500.0, "GB": 80.0}

    def __str__(self):
        return f"{self.plan_type.capitalize()} Plan"

    def update_prices(self, country, monthly_price, annual_price):
        """ Update or add prices dynamically for a country """
        self.monthly_prices[country] = monthly_price
        self.annual_prices[country] = annual_price
        self.save()