# Use the latest stable GDAL image as base
FROM osgeo/gdal:ubuntu-small-3.6.2  

# Set working directory
WORKDIR /app

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    netcat \
    && apt-get clean

# Copy application files
COPY . .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Ensure entrypoint script is executable
RUN chmod +x entrypoint.sh

# Set the entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]

# Expose the application port
EXPOSE 8001
