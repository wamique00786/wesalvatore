from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from .models import UserProfile
from phonenumber_field.formfields import PhoneNumberField

class SignUpForm(UserCreationForm):
    USER_TYPES = [
        ('USER', 'Regular User'),
        ('VOLUNTEER', 'Volunteer'),
        ('ADMIN', 'Administrator')
    ]
    
    user_type = forms.ChoiceField(
        choices=USER_TYPES,
        required=True,
        widget=forms.Select(attrs={'class': 'form-control'}),
        label='User Type'  # Explicit label
    )
    email = forms.EmailField(
        required=True,
        widget=forms.EmailInput(attrs={'class': 'form-control'}),
        label='Email Address'  # Explicit label
    )
    mobile_number = PhoneNumberField(
        required=True,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'Enter your phone number (e.g., +91 9876543210)'
        }),
        help_text='Include your country code (e.g., +91 for India)',
        label='Mobile Number'
    )
    username = forms.CharField(
        widget=forms.TextInput(attrs={'class': 'form-control'}),
        label='Username'  # Explicit label
    )
    password1 = forms.CharField(
        widget=forms.PasswordInput(attrs={'class': 'form-control'}),
        label='Password'  # Explicit label
    )
    password2 = forms.CharField(
        widget=forms.PasswordInput(attrs={'class': 'form-control'}),
        label='Confirm Password'  # Explicit label
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
    
class PasswordResetForm(forms.Form):
    email = forms.EmailField(label="Email", max_length=254)