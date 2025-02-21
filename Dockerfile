FROM python:3.10-slim

# Install GDAL dependencies (Ensure correct version)
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
    && apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    netcat-openbsd \
    binutils \
    libproj-dev \
    && rm -rf /var/lib/apt/lists/*

# Set GDAL environment variables
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so
ENV GDAL_CONFIG=/usr/bin/gdal-config

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Upgrade pip and install dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# Make sure entrypoint.sh is executable
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint script
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
