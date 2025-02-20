#!/bin/sh

echo "Waiting for database to be ready..."
while ! nc -z postgres_db  5432; do
  sleep 1
done
echo "Database is ready!"

#!/bin/sh

echo "Waiting for database to be ready..."
while ! nc -z postgres_db 5432; do
  sleep 1
done
echo "Database is ready!"

echo "Applying database migrations..."
python manage.py makemigrations

# Apply migrations for all apps, handling existing schema properly
python manage.py migrate --fake-initial

if [ $? -ne 0 ]; then
  echo "Migrations failed. Exiting..."
  exit 1
fi

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn server..."
exec gunicorn wesalvatore.wsgi:application --bind 0.0.0.0:8000 --workers 4




if [ $? -ne 0 ]; then
  echo "Migrations failed. Exiting..."
  exit 1
fi

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn server..."
exec gunicorn wesalvatore.wsgi:application --bind 0.0.0.0:8000 --workers 4

