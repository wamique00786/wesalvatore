FROM python:3.10

# Install GDAL and dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
    && apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV GDAL_VERSION=3.10.2
ENV GDAL_DATA=/usr/share/gdal/${GDAL_VERSION}
ENV PROJ_LIB=/usr/share/proj

# Set working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Ensure entrypoint.sh is executable
RUN chmod +x /app/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
