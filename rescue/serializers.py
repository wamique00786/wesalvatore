from rest_framework import serializers

class UserReportSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=15, required=True)
    image = serializers.ImageField(required=True)  # Image captured from the camera
    description = serializers.CharField(required=True)