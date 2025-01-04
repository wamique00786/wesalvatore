from django import forms
from .models import AdoptableAnimal

class AdoptableAnimalForm(forms.ModelForm):
    class Meta:
        model = AdoptableAnimal
        fields = ['name', 'description', 'photo', 'is_adoptable']
        widgets = {
            'description': forms.Textarea(attrs={'rows': 4}),
        }

        labels = {
            'name': 'Animal Name',
            'description': 'Description',
            'photo': 'Photo',
            'is_adoptable': 'Is Adoptable',
        }