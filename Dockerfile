# Use Python 3.10 as the base image
FROM python:3.10

# Install system dependencies
RUN apt-get update && apt-get install -y \
    netcat-openbsd \
    binutils \
    libproj-dev \
    gdal-bin \
    libgdal-dev \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for GDAL
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so
ENV PROJ_LIB=/usr/share/proj

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Ensure entrypoint.sh is executable
RUN chmod +x /app/entrypoint.sh

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gdal==3.10.1  # Ensure GDAL for Python is installed

# Set the entrypoint
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
