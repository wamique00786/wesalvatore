FROM python:3.10

# Install GDAL and other dependencies
RUN apt-get update && apt-get install -y \
    netcat-openbsd \
    binutils \
    libproj-dev \
    gdal-bin \
    libgdal-dev \
    && rm -rf /var/lib/apt/lists/*

# Verify GDAL installation
RUN gdalinfo --version

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install GDAL Python bindings
RUN pip install --no-cache-dir GDAL

# Make sure entrypoint.sh is executable
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
