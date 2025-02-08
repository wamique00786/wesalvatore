from geopy.geocoders import Nominatim

def geocode_address(address):
    geolocator = Nominatim(user_agent="animal_rescue")
    location = geolocator.geocode(address)
    if location:
        return (location.latitude, location.longitude, location.address)
    return None

def reverse_geocode(lat, lon):
    geolocator = Nominatim(user_agent="animal_rescue")
    location = geolocator.reverse((lat, lon))
    return location.address if location else None

def get_route(start_lat, start_lon, end_lat, end_lon):
    import requests
    url = f"http://router.project-osrm.org/route/v1/driving/{start_lon},{start_lat};{end_lon},{end_lat}?overview=full"
    response = requests.get(url)
    return response.json() if response.status_code == 200 else None