# subscription/models.py
from django.db import models

class SubscriptionPlan(models.Model):
    PLAN_CHOICES = [
        ('bronze', 'Bronze'),
        ('silver', 'Silver'),
        ('gold', 'Gold'),
    ]
    
    plan_type = models.CharField(max_length=6, choices=PLAN_CHOICES)
    monthly_price = models.DecimalField(max_digits=10, decimal_places=2)
    annual_price = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"{self.plan_type.capitalize()} Plan"