let stream;
const camera = document.getElementById('camera');
const photoCanvas = document.getElementById('photoCanvas');
const photoPreview = document.getElementById('photoPreview');
const startButton = document.getElementById('startCamera');
const captureButton = document.getElementById('capturePhoto');
const retakeButton = document.getElementById('retakePhoto');

// Camera handling
startButton.addEventListener('click', async () => {
    try {
        stream = await navigator.mediaDevices.getUserMedia({ video: true });
        camera.srcObject = stream;
        camera.style.display = 'block'; // Show the camera
        startButton.style.display = 'none'; // Hide the start button
        captureButton.style.display = 'block'; // Show the capture button
    } catch (err) {
        console.error('Error accessing camera:', err);
        alert('Could not access camera');
    }
});

captureButton.addEventListener('click', () => {
    if (!stream) {
        alert('Camera is not active');
        return;
    }
    photoCanvas.width = camera.videoWidth;
    photoCanvas.height = camera.videoHeight;
    photoCanvas.getContext('2d').drawImage(camera, 0, 0);

    // Convert canvas to base64 image data
    photoData.value = photoCanvas.toDataURL('image/jpeg');

    // Show preview and retake button
    photoPreview.src = photoData.value;
    photoPreview.style.display = 'block'; // Show the photo preview
    camera.style.display = 'none'; // Hide the camera
    captureButton.style.display = 'none'; // Hide the capture button
    retakeButton.style.display = 'block'; // Show the retake button

    // Stop camera stream
    stream.getTracks().forEach(track => track.stop());
    stream = null; // Clear the stream variable
});

retakeButton.addEventListener('click', async () => {
    photoPreview.style.display = 'none'; // Hide the photo preview
    retakeButton.style.display = 'none'; // Hide the retake button
    startButton.style.display = 'block'; // Show the start button again
    try {
        stream = await navigator.mediaDevices.getUserMedia({ video: true });
        camera.srcObject = stream;
        camera.style.display = 'block'; // Show the camera again
        startButton.style.display = 'none'; // Hide the start button
        captureButton.style.display = 'block'; // Show the capture button
    } catch (err) {
        console.error('Error accessing camera:', err);
        alert('Could not access camera');
    }
});

// Location handling
let map;
let userMarker;
let userPopup = null;
let allUserMarkers = {};
const markerIcons = {
    'USER': L.icon({
        iconUrl: '/static/images/user-marker.png',
        iconSize: [32, 32],
        iconAnchor: [16, 32],
        popupAnchor: [0, -32]
    }),
    'VOLUNTEER': L.icon({
        iconUrl: '/static/images/volunteer-marker.png',
        iconSize: [32, 32],
        iconAnchor: [16, 32],
        popupAnchor: [0, -32]
    }),
    'ADMIN': L.icon({
        iconUrl: '/static/images/admin-marker.png',
        iconSize: [32, 32],
        iconAnchor: [16, 32],
        popupAnchor: [0, -32]
    })
};

// Initialize the map
function initMap() {
    map = L.map('map').setView([0, 0], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);

    // Start watching location
    watchLocation();
    setInterval(updateUserInfo, 10000); // Update every 10 seconds
}

async function updateUserInfo(latitude, longitude) {
    try {
        // Save location to database
        const response = await fetch('/api/save-location/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': document.querySelector('[name=csrfmiddlewaretoken]').value,
            },
            body: JSON.stringify({
                latitude: latitude,
                longitude: longitude
            })
        });

        // Get user info
        const userInfoResponse = await fetch('/api/user-info/');
        const userInfo = await userInfoResponse.json();

        // Create or update marker with popup
        if (!userMarker) {
            userMarker = L.marker([latitude, longitude]).addTo(map);
            map.setView([latitude, longitude], 13);
        } else {
            userMarker.setLatLng([latitude, longitude]);
        }

        // Create popup content
        const popupContent = `
            <div class="user-popup">
                <strong>User:</strong> ${userInfo.username}<br>
                <strong>Phone:</strong> ${userInfo.phone}<br>
                <strong>Location:</strong> ${latitude.toFixed(6)}, ${longitude.toFixed(6)}<br>
                <strong>User Type:</strong> ${userInfo.user_type}
            </div>
        `;

        // Update popup
        if (userPopup) {
            userPopup.setContent(popupContent);
        } else {
            userPopup = userMarker.bindPopup(popupContent);
        }

        // Add click event to marker
        userMarker.on('click', function() {
            this.openPopup();
        });

    } catch (error) {
        console.error('Error updating user info:', error);
    }
}

function watchLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.watchPosition(
            function(position) {
                const latitude = position.coords.latitude;
                const longitude = position.coords.longitude;
                
                // Update hidden form fields
                document.getElementById('latitude').value = latitude;
                document.getElementById('longitude').value = longitude;
                
                // Update map marker and user info
                updateUserInfo(latitude, longitude);
            },
            function(error) {
                console.error("Error getting location:", error);
                alert("Please enable location services to use the map.");
            },
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

// Function to update user's location
function updateLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            position => {
                const { latitude, longitude } = position.coords;
                latitudeInput.value = latitude;
                longitudeInput.value = longitude;

                // Update marker position
                if (userMarker) {
                    userMarker.setLatLng([latitude, longitude]);
                    map.setView([latitude, longitude]); // Center the map on the user's location
                } else {
                    console.error('User marker is not defined.');
                }
            },
            error => {
                console.error('Error getting location:', error);
                alert('Could not get your location');
            }
        );
    }
}

// Function to fetch nearby volunteers
async function fetchNearbyVolunteers(latitude, longitude) {
    try {
        if (!latitude || !longitude) {
            console.error('Invalid coordinates');
            return;
        }

        const response = await fetch(
            `/api/volunteers/nearby/?lat=${latitude}&lng=${longitude}`,
            {
                method: 'GET',
                headers: {
                    'Accept': 'application/json',
                }
            }
        );

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        
        // Clear existing volunteer markers
        if (window.volunteerMarkers) {
            window.volunteerMarkers.forEach(marker => marker.remove());
        }
        window.volunteerMarkers = [];

        // Add markers for each volunteer
        data.forEach(volunteer => {
            if (volunteer.location && volunteer.location.coordinates) {
                const marker = L.marker([
                    volunteer.location.coordinates[1],  // latitude
                    volunteer.location.coordinates[0]   // longitude
                ]).addTo(map);

                const distance = volunteer.distance ? 
                    volunteer.distance.text : 
                    'Distance unknown';

                const name = volunteer.user ? 
                    (volunteer.user.first_name || volunteer.user.username) : 
                    'Volunteer';

                marker.bindPopup(
                    `<strong>${name}</strong><br>${distance}`
                );
                window.volunteerMarkers.push(marker);
            }
        });

    } catch (error) {
        console.error('Error fetching volunteers:', error);
    }
}

// Function to send report to admin
async function sendReportToAdmin() {
    const formData = new FormData();
    formData.append('photo', document.getElementById('imageData').value);  // Change to match the field name
    formData.append('description', document.getElementById('description').value);
    formData.append('latitude', document.getElementById('latitude').value);
    formData.append('longitude', document.getElementById('longitude').value);

    try {
        const response = await fetch('/api/admin/report/', {
            method: 'POST',
            body: formData,
        });
        if (!response.ok) throw new Error('Network response was not ok');
        const result = await response.json();
        alert(result.message);
    } catch (error) {
        console.error('Error sending report to admin:', error);
        alert('Failed to send report to admin.');
    }
}

// Function to submit the report
async function submitReport() {
    const descriptionInput = document.getElementById('description');
    const photoData = document.getElementById('image');

    // Ensure all elements are found
    if (!descriptionInput || !photoData) {
        alert('Required input elements are missing.');
        return;
    }

    // Check if all required fields are filled
    if (!descriptionInput.value || !photoData.files[0]) {
        alert('Please fill in all fields and ensure an image is selected.');
        return;
    }

    const latitudeInput = getCookie('user_latitude'); // Assuming you have a function to get cookies
    const longitudeInput = getCookie('user_longitude'); // Assuming you have a function to get cookies

    console.log('Latitude:', latitudeInput); // Debugging line
    console.log('Longitude:', longitudeInput); // Debugging line

    // Check if latitude and longitude are available
    if (!latitudeInput || !longitudeInput) {
        alert('Location is not available. Please enable location services.');
        return;
    }

    const formData = new FormData();
    formData.append('photo', photoData.files[0]); // Ensure this is the file input
    formData.append('description', descriptionInput.value);
    formData.append('latitude', latitudeInput); // Use the latitude from cookies or input
    formData.append('longitude', longitudeInput); // Use the longitude from cookies or input

    try {
        const response = await fetch('/api/user/report/', {
            method: 'POST',
            body: formData,
        });
        if (!response.ok) throw new Error('Network response was not ok');
        const result = await response.json();
        alert(result.message);
    } catch (error) {
        console.error('Error submitting report:', error);
        alert('Failed to submit report.');
    }
}

// Add event listener to the report form submission
document.getElementById('reportAnimalForm').addEventListener('submit', (event) => {
    event.preventDefault(); // Prevent default form submission
    submitReport(); // Call the submitReport function
});

// Initialize map when page loads
document.addEventListener('DOMContentLoaded', initMap);