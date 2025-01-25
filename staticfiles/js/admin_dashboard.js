function viewVolunteerMap(username, phone, latitude, longitude, userType) {
    // Show the map container
    const mapContainer = document.getElementById('map');
    mapContainer.style.display = 'block';

    // Initialize the map
    const map = L.map('map').setView([latitude, longitude], 13); // Center the map on the volunteer's location

    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    // Create a marker for the volunteer
    const marker = L.marker([latitude, longitude]).addTo(map);

    // Create popup content
    const popupContent = `
        <div class="user-popup">
            <strong>Username:</strong> ${username}<br>
            <strong>Phone:</strong> ${phone}<br>
            <strong>Location:</strong> (${latitude.toFixed(6)}, ${longitude.toFixed(6)})<br>
            <strong>User Type:</strong> ${userType}
        </div>
    `;

    // Bind the popup to the marker
    marker.bindPopup(popupContent).openPopup();

    // Set the map view to the marker
    map.setView([latitude, longitude], 13);
}