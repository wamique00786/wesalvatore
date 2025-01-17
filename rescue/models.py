from django.db import models
from django.contrib.auth.models import User
from django.contrib.gis.db import models

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

    def __str__(self):
        return self.name

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
    
class RescueTask(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField()
    assigned_to = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='tasks')
    is_completed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title
    