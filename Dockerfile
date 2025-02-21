FROM python:3.10

# Install dependencies
# Install required system dependencies
RUN apt-get update && apt-get install -y \
    netcat-openbsd \  
    netcat-openbsd \
    binutils \
    libproj-dev \
    gdal-bin \
RUN pip install --no-cache-dir -r requirements.txt
# Make sure entrypoint.sh is executable
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint
# Set the entrypoint script
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
