from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from .models import UserLocation
from .utils import geocode_address, reverse_geocode, get_route

@login_required
def map_view(request):
    user_location = UserLocation.objects.filter(user=request.user).first()
    return render(request, 'geolocation/map.html', {'user_location': user_location})

@login_required
def save_location(request):
    if request.method == 'POST':
        lat = request.POST.get('latitude')
        lng = request.POST.get('longitude')
        address = reverse_geocode(lat, lng)
        
        UserLocation.objects.update_or_create(
            user=request.user,
            defaults={
                'latitude': lat,
                'longitude': lng,
                'address': address
            }
        )
        return JsonResponse({'status': 'success'})
    return JsonResponse({'status': 'error'}, status=400)

@login_required
def all_locations(request):
    if not request.user.is_staff:  # For admins/volunteers
        return redirect('map_view')
    
    locations = UserLocation.objects.all()
    return render(request, 'geolocation/all_locations.html', {'locations': locations})

# views.py
@login_required
def calculate_route(request):
    if request.method == 'POST':
        start_lat = request.POST.get('start_lat')
        start_lng = request.POST.get('start_lng')
        end_lat = request.POST.get('end_lat')
        end_lng = request.POST.get('end_lng')
        
        route = get_route(start_lat, start_lng, end_lat, end_lng)
        return JsonResponse(route)
    return JsonResponse({'error': 'Invalid request'}, status=400)