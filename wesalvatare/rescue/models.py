from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.gis.db import models

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    user_type = models.CharField(max_length=20, choices=[('USER', 'User'), ('VOLUNTEER', 'Volunteer'), ('ADMIN', 'Admin')])
    location = models.PointField(null=True, blank=True)  # Use PointField for geographic data

    def __str__(self):
        return self.user.username

# Signal to create user profile
@receiver(post_save, sender=User)
def create_or_update_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.get_or_create(user=instance)

class Animal(models.Model):
    SPECIES_CHOICES = [
        ('DOG', 'Dog'),
        ('CAT', 'Cat'),
        ('BIRD', 'Bird'),
        ('OTHER', 'Other'),
    ]
    
    STATUS_CHOICES = [
        ('RESCUED', 'Rescued'),
        ('TREATMENT', 'Under Treatment'),
        ('RECOVERED', 'Recovered'),
        ('ADOPTED', 'Adopted'),
    ]

    name = models.CharField(max_length=100)
    species = models.CharField(max_length=50, choices=SPECIES_CHOICES)
    rescue_date = models.DateField()
    status = models.CharField(max_length=50, choices=STATUS_CHOICES)
    medical_needs = models.TextField()
    rescue_location = models.CharField(max_length=200)
    assigned_to = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    photo = models.ImageField(upload_to='animal_photos/', null=True, blank=True)

class MedicalRecord(models.Model):
    animal = models.ForeignKey(Animal, on_delete=models.CASCADE)
    date = models.DateField()
    treatment = models.TextField()
    notes = models.TextField()
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)

# rescue/models.py
class AnimalReport(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    photo = models.ImageField(upload_to='animal_reports/')
    description = models.TextField()
    latitude = models.FloatField()
    longitude = models.FloatField()
    timestamp = models.DateTimeField(auto_now_add=True)
    assigned_to = models.ForeignKey(
        User, 
        on_delete=models.SET_NULL, 
        null=True, 
        related_name='assigned_reports'
    )
    status = models.CharField(
        max_length=20,
        choices=[
            ('PENDING', 'Pending'),
            ('ASSIGNED', 'Assigned'),
            ('RESOLVED', 'Resolved')
        ],
        default='PENDING'
    )

    def __str__(self):
        return f"Report by {self.user.username} at {self.timestamp}"