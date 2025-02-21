FROM ubuntu:latest

RUN apt update && apt install -y \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

ENV GDAL_VERSION=3.10.1
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so

WORKDIR /app
COPY . .
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gdal==${GDAL_VERSION}

ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
