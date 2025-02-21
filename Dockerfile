# Use official Arch Linux base image
FROM archlinux:latest

# Set environment variables
ENV GDAL_VERSION=3.10.1
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so

# Update package database and install dependencies
RUN pacman -Syu --noconfirm \
    gdal \
    python-pip \
    proj \
    libspatialite \
    sqlite \
    gcc \
    make \
    && rm -rf /var/cache/pacman/pkg/*

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
