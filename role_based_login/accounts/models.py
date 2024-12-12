from django.db import models
from django.contrib.auth.models import AbstractUser
from math import radians, sin, cos, sqrt, atan2
from django.conf import settings


# Custom User model with roles
class CustomUser(AbstractUser):
    ROLE_CHOICES = [
        ('admin', 'Admin'),
        ('volunteer', 'Volunteer'),
        ('user', 'User'),
    ]
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='user')

    def save(self, *args, **kwargs):
        # Ensure only users with the 'volunteer' role can have Volunteer records
        if self.role != 'volunteer' and hasattr(self, 'volunteer'):
            raise ValueError("Only users with the 'volunteer' role can have associated Volunteer records.")
        super().save(*args, **kwargs)


# Volunteer model associated with CustomUser
class Volunteer(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    latitude = models.FloatField()
    longitude = models.FloatField()

    def __str__(self):
        return self.user.username

    @staticmethod
    def get_nearest(user_lat, user_lon):
        """
        Get the nearest volunteer to the specified latitude and longitude using Haversine formula.
        """
        R = 6371  # Earth radius in kilometers
        user_lat_rad = radians(user_lat)
        user_lon_rad = radians(user_lon)

        nearest_volunteer = None
        min_distance = float('inf')

        for volunteer in Volunteer.objects.all():
            volunteer_lat_rad = radians(volunteer.latitude)
            volunteer_lon_rad = radians(volunteer.longitude)

            dlat = volunteer_lat_rad - user_lat_rad
            dlon = volunteer_lon_rad - user_lon_rad
            a = sin(dlat / 2) ** 2 + cos(user_lat_rad) * cos(volunteer_lat_rad) * sin(dlon / 2) ** 2
            c = 2 * atan2(sqrt(a), sqrt(1 - a))
            distance = R * c

            if distance < min_distance:
                min_distance = distance
                nearest_volunteer = volunteer

        return nearest_volunteer


# User Image model for storing uploaded images and related data
class UserImage(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='user_images')
    image = models.ImageField(upload_to='uploads/')
    location = models.CharField(max_length=255)
    latitude = models.FloatField()
    longitude = models.FloatField()
    volunteer = models.ForeignKey(
        'Volunteer',  # String-based reference to avoid circular import
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_images'
    )
    assigned_to_admin = models.BooleanField(default=False)  # Tracks if admin is handling this task
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Image uploaded by {self.user.username}"

    def save(self, *args, **kwargs):
        """
        Override save method to assign the nearest volunteer based on location.
        If no volunteer is available, assign the task to the admin.
        """
        if not self.volunteer and not self.assigned_to_admin:
            try:
                # Find the nearest volunteer
                nearest_volunteer = Volunteer.get_nearest(self.latitude, self.longitude)

                if nearest_volunteer:
                    self.volunteer = nearest_volunteer
                    self.assigned_to_admin = False
                else:
                    # No volunteer available; assign to admin
                    self.volunteer = None
                    self.assigned_to_admin = True
            except (ValueError, TypeError):
                # Handle invalid location data gracefully
                self.volunteer = None
                self.assigned_to_admin = True

        super().save(*args, **kwargs)


# Batch Assignment model for assigning tasks to volunteers
class BatchAssignment(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='user_assignments')
    volunteer = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='volunteer_assignments')
    batch_number = models.CharField(max_length=20)
    assigned_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Batch {self.batch_number} - {self.user.username} to {self.volunteer.username}"

    def clean(self):
        """
        Ensure the volunteer is indeed a user with the 'volunteer' role.
        """
        if self.volunteer.role != 'volunteer':
            raise ValueError("Assigned volunteer must have the 'volunteer' role.")


# Task model for assigning tasks to volunteers
class Task(models.Model):
    volunteer = models.ForeignKey('Volunteer', on_delete=models.CASCADE)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)  # Use CustomUser model
    batch_number = models.CharField(max_length=10)
    task_details = models.TextField()
    status = models.CharField(
        max_length=20,
        choices=[('Pending', 'Pending'), ('Completed', 'Completed')],
        default='Pending'
    )

    def __str__(self):
        return f"Task for {self.user.username} - {self.status}"
