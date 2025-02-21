echo "Waiting for database to be ready..."
while ! nc -z postgres_db  5432; do
  sleep 1
done
echo "Database is ready!"

echo "Applying database migrations..."
#!/bin/sh

echo "Waiting for PostgreSQL to be ready..."
while ! nc -z postgres_db 5432; do
  sleep 1
done
echo "Database is ready!"

echo "Applying database migrations..."
python manage.py makemigrations || true
python manage.py migrate || true

# Apply migrations for specific apps (skipping if failed)
python manage.py migrate accounts --fake || true
python manage.py migrate rescue  --fake || true
python manage.py migrate adoption --fake || true
python manage.py migrate donation --fake || true
python manage.py migrate subscription --fake || true

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput --verbosity 3

# Start Gunicorn server
echo "Starting Gunicorn server..."
exec gunicorn wesalvatore.wsgi:application --bind 0.0.0.0:8000 --workers 4 --timeout 120 --access-logfile -

if [ $? -ne 0 ]; then
  echo "Migrations failed. Exiting..."
  exit 1
fi

echo "Collecting static files..."
python manage.py collectstatic --noinput --clear


echo "Starting Gunicorn server..."
exec gunicorn wesalvatore.wsgi:application --bind 0.0.0.0:8000 --workers 4
