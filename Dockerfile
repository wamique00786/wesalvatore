# Use a Debian-based image
FROM debian:bullseye

# Set environment variables for GDAL
ENV DEBIAN_FRONTEND=noninteractive
ENV GDAL_VERSION=3.10.1
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so

# Update package list and install system dependencies
RUN apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    python3-pip \
    software-properties-common \
    dbus \
    netcat-openbsd \
    binutils \
    libproj-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, and install Python GDAL bindings
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir gdal==${GDAL_VERSION}

# Set the working directory
WORKDIR /app

# Copy project files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set entrypoint
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
