from django import forms
from .models import Animal, MedicalRecord
    
class AnimalForm(forms.ModelForm):
    class Meta:
        model = Animal
        fields = ['name', 'species', 'rescue_date', 'status', 'medical_needs', 
                 'rescue_location', 'assigned_to', 'photo']
        widgets = {
            'rescue_date': forms.DateInput(attrs={'type': 'date'}),
            'medical_needs': forms.Textarea(attrs={'rows': 3}),
        }
        labels = {
            'name': 'Animal Name',
            'species': 'Species',
            'rescue_date': 'Rescue Date',
            'status': 'Status',
            'medical_needs': 'Medical Needs',
            'rescue_location': 'Rescue Location',
            'assigned_to': 'Assigned To',
            'photo': 'Photo',
        }

class MedicalRecordForm(forms.ModelForm):
    class Meta:
        model = MedicalRecord
        fields = ['date', 'treatment', 'notes']
        widgets = {
            'date': forms.DateInput(attrs={'type': 'date'}),
            'treatment': forms.Textarea(attrs={'rows': 3}),
            'notes': forms.Textarea(attrs={'rows': 3}),
        }
        labels = {
            'date': 'Date',
            'treatment': 'Treatment',
            'notes': 'Notes',
        }