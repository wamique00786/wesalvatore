# Use an official Python runtime as a parent image
FROM python:latest

# Set environment variables to prevent .pyc files and to set the Django settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    && rm -rf /var/lib/apt/lists/*

# Install Python GDAL bindings
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so
ENV LD_LIBRARY_PATH=/usr/lib
ENV GDAL_VERSION 3.1.4
ENV PATH /usr/lib/gdal:$PATH
ENV LD_LIBRARY_PATH /usr/lib/gdal:$LD_LIBRARY_PATH
# Install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Django project code
COPY . /app
# Expose port 8000 to the host
EXPOSE 8000

# Run Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
