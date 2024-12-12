from django import forms
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from .models import CustomUser
from .models import BatchAssignment
from .models import Task, Volunteer


class CustomUserCreationForm(UserCreationForm):
    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'password1', 'password2', 'role']

class CustomAuthenticationForm(AuthenticationForm):
    role = forms.ChoiceField(
        choices=CustomUser.ROLE_CHOICES,
        required=True,
        label='Login as',
    )

class BatchAssignmentForm(forms.ModelForm):
    class Meta:
        model = BatchAssignment
        fields = ['user', 'volunteer', 'batch_number']

class TaskForm(forms.ModelForm):
    class Meta:
        model = Task
        fields = ['volunteer', 'user', 'batch_number', 'task_details', 'status']
        widgets = {
            'volunteer': forms.Select(attrs={'class': 'form-control'}),
            'user': forms.Select(attrs={'class': 'form-control'}),
            'task_details': forms.Textarea(attrs={'class': 'form-control'}),
            'status': forms.Select(attrs={'class': 'form-control'}),
        }