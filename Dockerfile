# Use an official Python runtime as a parent image
FROM python:latest

# Set environment variables to prevent .pyc files and to set the Django settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app
RUN apt-get update \
    && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    nano \
    && rm -rf /var/lib/apt/lists/*
#ENV GDAL_VERSION 3.1.4
ENV PATH /usr/lib/gdal:$PATH
ENV LD_LIBRARY_PATH /usr/lib/gdal:$LD_LIBRARY_PATH

# Install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Django project code
COPY . /app

# Expose port 8000 to the host
EXPOSE 8000

# Run database migrations and Django development server
CMD ["sh", "-c", "python manage.py makemigrations && python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
