FROM python:3.10

# Install dependencies and GDAL
RUN apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for GDAL
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV GDAL_DATA=/usr/share/gdal
ENV PROJ_LIB=/usr/share/proj
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Ensure entrypoint.sh is executable
RUN chmod +x /app/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
