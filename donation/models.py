from django.db import models
from django.contrib.auth.models import User

class Donation(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateTimeField(auto_now_add=True)
    ngo = models.ForeignKey('NGO', on_delete=models.CASCADE, null=True)  # Assuming you have an NGO model

    def __str__(self):
        return f"{self.user.username} donated ${self.amount} on {self.date}"
    
class NGO(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    website = models.URLField(blank=True)

    def __str__(self):
        return self.name
    
