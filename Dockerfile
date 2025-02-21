FROM python:3.10-slim

# Install dependencies & add Ubuntugis PPA for latest GDAL
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
    && apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    dbus \
    netcat-openbsd \
    binutils \
    libproj-dev \
    && rm -rf /var/lib/apt/lists/*

# Set GDAL environment variables
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so
ENV GDAL_VERSION=3.10.1

# Set working directory
WORKDIR /app

# Upgrade pip & install Python dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir gdal==3.10.1

# Copy project files
COPY . .

# Set the entrypoint script
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
