from rest_framework import serializers
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from django.contrib.gis.db.models.functions import Distance
from accounts.models import UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(source='user.id')
    name = serializers.SerializerMethodField()
    distance = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = ['id', 'name', 'distance', 'location']

    def get_name(self, obj):
        return obj.user.get_full_name() or obj.user.username

    def get_distance(self, obj):
        # Ensure distance annotation exists before accessing it
        return f"{getattr(obj, 'distance', 0):.2f} km"

    def get_location(self, obj):
        return {
            "latitude": obj.location.y if obj.location else None,
            "longitude": obj.location.x if obj.location else None
        }
