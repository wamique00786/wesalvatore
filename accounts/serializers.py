# rescue/serializers.py
from django.contrib.auth.models import User
from rest_framework import serializers
from .models import UserProfile  # Import your UserProfile model if you have one

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['user', 'user_type', 'mobile_number', 'location']

    def create(self, validated_data):
        user = validated_data.pop('user')
        user_profile = UserProfile.objects.create(user=user, **validated_data)
        return user_profile

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(required=True)
    password = serializers.CharField(required=True)
    user_type = serializers.ChoiceField(choices=[
        ('USER', 'Regular User'),
        ('VOLUNTEER', 'Volunteer'),
        ('ADMIN', 'Administrator')
    ], required=True)

class SignUpSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    user_type = serializers.ChoiceField(choices=[
        ('USER', 'Regular User'),
        ('VOLUNTEER', 'Volunteer'),
        ('ADMIN', 'Administrator')
    ])
    mobile_number = serializers.CharField(max_length=15)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'user_type', 'mobile_number']

    def create(self, validated_data):
        if User.objects.filter(username=validated_data['username']).exists():
            raise serializers.ValidationError({"username": "This username is already taken."})
        if User.objects.filter(email=validated_data['email']).exists():
            raise serializers.ValidationError({"email": "This email is already registered."})

        user = User(
            username=validated_data['username'],
            email=validated_data['email'],
        )
        user.set_password(validated_data['password'])  # Hash the password
        user.save()

        # Create UserProfile
        UserProfile.objects.create(
            user=user,
            user_type=validated_data['user_type'],
            mobile_number=validated_data['mobile_number']
        )

        return user

class PasswordResetRequestSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)

    def validate_email(self, value):
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError("No user is associated with this email address.")
        return value
    
class UserReportSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=15, required=True)
    image = serializers.ImageField(required=True)  # Image captured from the camera
    description = serializers.CharField(required=True)