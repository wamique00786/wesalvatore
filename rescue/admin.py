from django.contrib import admin
from .models import AdoptableAnimal

@admin.register(AdoptableAnimal)
class AdoptableAnimalAdmin(admin.ModelAdmin):
    list_display = ('name', 'is_adoptable')
    search_fields = ('name', 'description')
    list_filter = ('is_adoptable',)