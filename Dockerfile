FROM python:3.10-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    software-properties-common \
    dbus \
    netcat-openbsd \
    binutils \
    libproj-dev \
    && rm -rf /var/lib/apt/lists/*

# Set GDAL environment variables

ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so


# Set working directory
WORKDIR /app
RUN pip install --no-cache-dir gdal==3.10.1
# Copy project files
COPY . .

# Upgrade pip & install dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# Set the entrypoint script
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
