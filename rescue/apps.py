from django.apps import AppConfig


class RescueConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "rescue"

    def ready(self):
        import rescue.models  # Import the signals