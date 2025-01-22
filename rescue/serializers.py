from rest_framework import serializers
from .models import AnimalReport
from django.contrib.gis.geos import Point

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