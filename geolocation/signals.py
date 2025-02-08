from django.contrib.auth.signals import user_logged_in
from django.dispatch import receiver
from django.contrib import messages
from .models import UserLocation

@receiver(user_logged_in)
def handle_user_login(sender, user, request, **kwargs):
    """
    Signal handler to process user location when they log in
    """
    # Add a message to request location permission
    messages.info(
        request,
        'Please allow location access to help us provide better service.',
        extra_tags='location-permission'
    )
