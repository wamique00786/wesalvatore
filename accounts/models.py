from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.gis.db import models as geomodels

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    user_type = models.CharField(max_length=20, choices=[('USER', 'User'), ('VOLUNTEER', 'Volunteer'), ('ADMIN', 'Admin')])
    mobile_number = models.CharField(max_length=15, default='0000000000')  # Set a default value
    location = geomodels.PointField(null=True, blank=True, srid=4326)  # Use PointField for geographic data

    def __str__(self):
        return f"{self.user.username} - {self.get_user_type_display()}"

# Signal to create user profile
@receiver(post_save, sender=User)
def create_or_update_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.get_or_create(user=instance)



