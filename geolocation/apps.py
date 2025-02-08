from django.apps import AppConfig

class GeolocationConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'geolocation'

    def ready(self):
        import geolocation.signals  # Import signals when app is ready
