# Use Manjaro as the base image
FROM manjaro:latest

# Install system dependencies
RUN pacman -Sy --noconfirm \
    gdal \
    python \
    python-pip \
    python-virtualenv \
    proj \
    && pacman -Scc --noconfirm  # Clean package cache to reduce image size

# Set environment variables
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Create and activate virtual environment
RUN python -m venv $VIRTUAL_ENV

# Upgrade pip inside the virtual environment
RUN pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install dependencies inside the virtual environment
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gdal==3.10.1

# Set entrypoint
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
