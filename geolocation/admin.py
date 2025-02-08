from django.contrib import admin
from .models import UserLocation

@admin.register(UserLocation)
class UserLocationAdmin(admin.ModelAdmin):
    list_display = ('user', 'address', 'last_updated')
    search_fields = ('user__username', 'address')