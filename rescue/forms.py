from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from .models import UserProfile
from .models import Animal, MedicalRecord, AdoptableAnimal

class SignUpForm(UserCreationForm):
    USER_TYPES = [
        ('USER', 'Regular User'),
        ('VOLUNTEER', 'Volunteer'),
        ('ADMIN', 'Administrator')
    ]
    
    user_type = forms.ChoiceField(
        choices=USER_TYPES,
        required=True,
        widget=forms.Select(attrs={'class': 'form-control'})
    )
    email = forms.EmailField(
        required=True,
        widget=forms.EmailInput(attrs={'class': 'form-control'})
    )
    mobile_number = forms.CharField(
        max_length=15,
        required=True,
        widget=forms.TextInput(attrs={'class': 'form-control'}),
        help_text='Enter your mobile number.'
    )
    username = forms.CharField(
        widget=forms.TextInput(attrs={'class': 'form-control'})
    )
    password1 = forms.CharField(
        widget=forms.PasswordInput(attrs={'class': 'form-control'})
    )
    password2 = forms.CharField(
        widget=forms.PasswordInput(attrs={'class': 'form-control'})
    )

    class Meta:
        model = User
        fields = ('username', 'email', 'mobile_number', 'password1', 'password2', 'user_type')

    def save(self, commit=True):
        user = super().save(commit=False)
        user.email = self.cleaned_data['email']
        if commit:
            user.save()
            # Create or update UserProfile
            UserProfile.objects.update_or_create(
                user=user,
                defaults={
                    'user_type': self.cleaned_data['user_type'],
                    'mobile_number': self.cleaned_data['mobile_number']
                }
            )
        return user
    
class AnimalForm(forms.ModelForm):
    class Meta:
        model = Animal
        fields = ['name', 'species', 'rescue_date', 'status', 'medical_needs', 
                 'rescue_location', 'assigned_to', 'photo']
        widgets = {
            'rescue_date': forms.DateInput(attrs={'type': 'date'}),
            'medical_needs': forms.Textarea(attrs={'rows': 3}),
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

class AdoptableAnimalForm(forms.ModelForm):
    class Meta:
        model = AdoptableAnimal
        fields = ['name', 'description', 'photo', 'is_adoptable']
        widgets = {
            'description': forms.Textarea(attrs={'rows': 4}),
        }