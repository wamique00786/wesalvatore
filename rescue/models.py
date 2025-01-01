from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.gis.db import models

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    user_type = models.CharField(max_length=20, choices=[('USER', 'User'), ('VOLUNTEER', 'Volunteer'), ('ADMIN', 'Admin')])
    mobile_number = models.CharField(max_length=15, default='0000000000')  # Set a default value
    location = models.PointField(null=True, blank=True)  # Use PointField for geographic data

    def __str__(self):
        return f"{self.user.username} - {self.get_user_type_display()}"

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
    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name='medical_records')
    date = models.DateField()
    treatment = models.TextField()
    notes = models.TextField()
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)

    def __str__(self):
        return f"Medical Record for {self.animal.name} on {self.date}"

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
    
class Donation(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateTimeField(auto_now_add=True)
    ngo = models.ForeignKey('NGO', on_delete=models.CASCADE, null=True)  # Assuming you have an NGO model

    def __str__(self):
        return f"{self.user.username} donated ${self.amount} on {self.date}"

class AdoptableAnimal(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    photo = models.ImageField(upload_to='animal_photos/')
    # Add this field if it doesn't exist
    is_adoptable = models.BooleanField(default=True)

    class Meta:
        permissions = [
            ("can_add_adoptable_animal", "Can add adoptable animal"),
        ]

    def __str__(self):
        return self.name
    
class VolunteerProfile(models.Model):
      user = models.OneToOneField(User, on_delete=models.CASCADE)
      latitude = models.FloatField()
      longitude = models.FloatField()
      # Other fields as necessary

class NGO(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    website = models.URLField(blank=True)

    def __str__(self):
        return self.name