// static/js/dashboard_map.js

let map, userMarker;
let allUserMarkers = {};
let userPaths = {};

// Custom markers for different user types
const markerIcons = {
    'USER': L.icon({
        iconUrl: '/static/images/user-marker.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34]
    }),
    'VOLUNTEER': L.icon({
        iconUrl: '/static/images/volunteer-marker.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34]
    }),
    'ADMIN': L.icon({
        iconUrl: '/static/images/admin-marker.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34]
    })
};

// Initialize map
function initMap() {
    map = L.map('map').setView([0, 0], 2);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    watchLocation();
    setInterval(updateAllUsersLocations, 10000); // Update every 10 seconds
}

// Update user location
async function updateUserLocation(latitude, longitude) {
    try {
        const response = await fetch('/api/save-location/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': csrfToken,
            },
            body: JSON.stringify({ latitude, longitude })
        });

        if (!response.ok) throw new Error('Failed to update location');

        if (!userMarker) {
            userMarker = L.marker([latitude, longitude], {
                icon: markerIcons[currentUserType]
            }).addTo(map);
            map.setView([latitude, longitude], 13);
        } else {
            userMarker.setLatLng([latitude, longitude]);
        }

        const popupContent = `
            <div class="user-popup">
                <strong>You</strong><br>
                <strong>Type:</strong> ${currentUserType}<br>
                <strong>Phone:</strong> ${currentUserPhone}
            </div>
        `;
        userMarker.bindPopup(popupContent);

    } catch (error) {
        console.error('Error updating location:', error);
    }
}

// Update all users' locations
async function updateAllUsersLocations() {
    try {
        const response = await fetch('/api/all-users-locations/');
        const data = await response.json();

        if (data.status === 'success') {
            updateMarkersAndPaths(data.users);
        }
    } catch (error) {
        console.error('Error updating all users:', error);
    }
}

// Watch user's location
function watchLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.watchPosition(
            handlePositionSuccess,
            handlePositionError,
            {
                enableHighAccuracy: true,
                timeout: 5000,
                maximumAge: 0
            }
        );
    } else {
        alert("Geolocation is not supported by this browser.");
    }
}

// Handle successful position update
function handlePositionSuccess(position) {
    const latitude = position.coords.latitude;
    const longitude = position.coords.longitude;
    
    document.getElementById('latitude').value = latitude;
    document.getElementById('longitude').value = longitude;
    
    updateUserLocation(latitude, longitude);
}

// Handle position error
function handlePositionError(error) {
    console.error("Error getting location:", error);
    alert("Please enable location services to use the map.");
}

// Update markers and paths for all users
function updateMarkersAndPaths(users) {
    users.forEach(user => {
        const markerId = `user-${user.id}`;
        const markerLatLng = [user.location.latitude, user.location.longitude];

        updateUserPath(user, markerId);
        updateUserMarker(user, markerId, markerLatLng);
    });

    removeInactiveUsers(users);
}

// Helper functions
function getUserColor(userType) {
    const colors = {
        'USER': '#3388ff',
        'VOLUNTEER': '#33ff33',
        'ADMIN': '#ff3333'
    };
    return colors[userType] || '#3388ff';
}

function formatTimestamp(isoString) {
    return new Date(isoString).toLocaleString();
}

// Initialize when document is ready
document.addEventListener('DOMContentLoaded', initMap);