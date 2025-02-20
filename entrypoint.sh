#!/bin/sh

echo "Waiting for PostgreSQL to be ready..."
while ! nc -z $DATABASE_HOST 5432; do
  sleep 1
done
echo "Database is ready!"

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate

# Apply migrations for specific apps
python manage.py migrate accounts --fake
python manage.py migrate rescue --fake
python manage.py migrate adoption --fake
python manage.py migrate donation --fake
python manage.py migrate subscription --fake

# Check if migrations were successful
if [ $? -ne 0 ]; then
  echo "Migrations failed. Exiting..."
  exit 1
fi

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput --verbosity 3

# Start Gunicorn server
echo "Starting Gunicorn server..."
exec gunicorn wesalvatore.wsgi:application --bind 0.0.0.0:8000 --workers 4 --timeout 120 --access-logfile -
