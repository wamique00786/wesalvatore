# Use an official Python runtime as a parent image
FROM python:latest

# Set environment variables to prevent .pyc files and to set the Django settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Django project code
COPY . /app/
WORKDIR /app/wesalvatore
# Expose port 8000 to the host
EXPOSE 8000

# Run Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
