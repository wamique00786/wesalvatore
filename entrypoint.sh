#!/bin/sh

echo "Waiting for database to be ready..."
while ! nc -z postgres_db  5432; do
  sleep 1
done
echo "Database is ready!"

echo "Applying database migrations..."
python manage.py makemigrations 
python manage.py migrate subscription --fake 
python manage.py migrate recuse --fake 



if [ $? -ne 0 ]; then
  echo "Migrations failed. Exiting..."
  exit 1
fi

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn server..."
exec gunicorn wesalvatore.wsgi:application --bind 0.0.0.0:8000 --workers 4

