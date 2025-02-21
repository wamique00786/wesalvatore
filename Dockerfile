FROM python:3.10

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    gdal \
    netcat-openbsd \
    binutils \
    libproj-dev \
    gdal-bin \
    libgdal-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Make sure entrypoint.sh is executable
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint script
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
