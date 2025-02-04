# rescue/serializers.py
from django.contrib.auth.models import User
from rest_framework import serializers
from .models import UserProfile
from rescue.models import AnimalReport
from phonenumber_field.serializerfields import PhoneNumberField
from django.contrib.gis.geos import Point

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name']

class UserProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    location = serializers.SerializerMethodField()
    distance = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = ['id', 'user', 'user_type', 'location', 'distance']

    def get_location(self, obj):
        """
        Custom method to serialize the GeoDjango Point field
        """
        if obj.location:
            return {
                'type': 'Point',
                'coordinates': [
                    obj.location.x,  # longitude
                    obj.location.y   # latitude
                ]
            }
        return None

    def get_distance(self, obj):
        """
        Include distance if it was annotated in the queryset
        """
        if hasattr(obj, 'distance'):
            return {
                'km': round(obj.distance.km, 2),
                'text': f"{round(obj.distance.km, 2)} km away"
            }
        return None
    
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

from rest_framework import serializers
from django.contrib.auth.models import User
from phonenumber_field.serializerfields import PhoneNumberField
from .models import UserProfile

class SignUpSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, style={'input_type': 'password'})
    user_type = serializers.ChoiceField(choices=[
        ('USER', 'Regular User'),
        ('VOLUNTEER', 'Volunteer'),
        ('ADMIN', 'Administrator')
    ])
    mobile_number = PhoneNumberField()  # Validate phone number with international format

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'user_type', 'mobile_number']

    def validate_username(self, value):
        """Ensure username is unique"""
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("This username is already taken.")
        return value

    def validate_email(self, value):
        """Ensure email is unique"""
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("This email is already registered.")
        return value

    def validate_mobile_number(self, value):
        """Ensure the phone number is valid and formatted correctly"""
        if not value.is_valid():
            raise serializers.ValidationError("Enter a valid phone number (e.g., +12125552368).")
        return value.as_e164  # Convert to standard E.164 format before saving

    def create(self, validated_data):
        """Create a new user and associated UserProfile"""
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']  # Hashing handled by `create_user`
        )

        # Create or update UserProfile
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
    
class AnimalReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnimalReport
        fields = ['photo', 'description']

    def validate(self, data):
        request = self.context.get('request')
        if not request:
            raise serializers.ValidationError("No request object found")

        # Validate photo
        if 'photo' not in data:
            raise serializers.ValidationError("A photo is required")

        # Validate description
        if 'description' not in data:
            raise serializers.ValidationError("A description is required")

        # Validate location
        try:
            latitude = float(request.data.get('latitude'))
            longitude = float(request.data.get('longitude'))
            if not (-90 <= latitude <= 90) or not (-180 <= longitude <= 180):
                raise serializers.ValidationError("Invalid coordinates")
        except (TypeError, ValueError):
            raise serializers.ValidationError("Valid latitude and longitude are required")

        return data

    def create(self, validated_data):
        request = self.context.get('request')
        if request:
            try:
                latitude = float(request.data.get('latitude'))
                longitude = float(request.data.get('longitude'))
                validated_data['location'] = Point(longitude, latitude, srid=4326)
                validated_data['user'] = request.user
            except (TypeError, ValueError) as e:
                raise serializers.ValidationError("Valid latitude and longitude are required")
        return super().create(validated_data)
    
    def create(self, validated_data):
        request = self.context.get('request')
        latitude = float(request.data.get('latitude'))
        longitude = float(request.data.get('longitude'))
        
        # Add additional data to validated_data
        validated_data['location'] = Point(longitude, latitude, srid=4326)
        validated_data['user'] = request.user
        validated_data['status'] = 'PENDING'
        
        return super().create(validated_data)
    
