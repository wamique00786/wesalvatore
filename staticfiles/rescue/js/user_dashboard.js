let stream;
const camera = document.getElementById('camera');
const photoCanvas = document.getElementById('photoCanvas');
const photoPreview = document.getElementById('photoPreview');
const startButton = document.getElementById('startCamera');
const captureButton = document.getElementById('capturePhoto');
const retakeButton = document.getElementById('retakePhoto');
const photoData = document.getElementById('photoData');
const latitudeInput = document.getElementById('latitude');
const longitudeInput = document.getElementById('longitude');

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

function initMap() {
    map = L.map('map').setView([0, 0], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);

    // Get user's location
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            position => {
                const { latitude, longitude } = position.coords;
                latitudeInput.value = latitude;
                longitudeInput.value = longitude;

                // Update map center and add user marker
                map.setView([latitude, longitude], 13);
                userMarker = L.marker([latitude, longitude])
                    .addTo(map)
                    .bindPopup('Your Location')
                    .openPopup();

                // Fetch nearby volunteers
                fetchNearbyVolunteers(latitude, longitude);
            },
            error => {
                console.error('Error getting location:', error);
                alert('Could not get your location');
            }
        );
    } else {
        alert('Geolocation is not supported by this browser.');
    }
}

async function fetchNearbyVolunteers(latitude, longitude) {
    try {
        const response = await fetch(`/api/nearby-volunteers/?lat=${latitude}&lng=${longitude}`);
        if (!response.ok) throw new Error('Network response was not ok');
        const volunteers = await response.json();

        volunteers.forEach(volunteer => {
            L.marker([volunteer.latitude, volunteer.longitude])
                .addTo(map)
                .bindPopup(`Volunteer: ${volunteer.name}`);
        });
    } catch (err) {
        console.error('Error fetching volunteers:', err);
    }
}

// Initialize map when page loads
document.addEventListener('DOMContentLoaded', initMap);