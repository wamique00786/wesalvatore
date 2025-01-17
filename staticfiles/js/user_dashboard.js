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
const latitudeInput = document.getElementById('latitude');
const longitudeInput = document.getElementById('longitude');
const phoneInput = document.getElementById('phone');
const descriptionInput = document.getElementById('description');
const photoData = document.getElementById('photoData');

// Initialize the map
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

                // Start updating location
                setInterval(updateLocation, 5000); // Update every 5 seconds
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
        const response = await fetch(`/api/accounts/volunteers/nearby/?lat=${latitude}&lng=${longitude}`);
        if (!response.ok) throw new Error('Network response was not ok');
        const volunteers = await response.json();

        if (volunteers.length === 0) {
            alert('No nearby volunteers available.');
        } else {
            volunteers.forEach(volunteer => {
                L.marker([volunteer.location.coordinates[1], volunteer.location.coordinates[0]]) // Adjust based on your PointField
                    .addTo(map)
                    .bindPopup(`Volunteer: ${volunteer.user.username}`);
            });
        }
    } catch (err) {
        console.error('Error fetching volunteers:', err);
    }
}

// Function to send report to admin
async function sendReportToAdmin() {
    const formData = new FormData();
    formData.append('phone_number', phoneInput.value);
    formData.append('description', descriptionInput.value);
    formData.append('image', photoData.files[0]); // Assuming you have the image file
    formData.append('latitude', latitudeInput.value);
    formData.append('longitude', longitudeInput.value);

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
    const formData = new FormData();
    formData.append('phone_number', phoneInput.value);
    formData.append('description', descriptionInput.value);
    formData.append('image', photoData.files[0]); // Assuming you have the image file
    formData.append('latitude', latitudeInput.value);
    formData.append('longitude', longitudeInput.value);

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