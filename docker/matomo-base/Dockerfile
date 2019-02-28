FROM matomo:3.7.0-fpm
LABEL mantainer="Fares Gianluca <gfares@indracompany.com>"

# Add GeoLite2 city
ADD https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz /usr/src/

# Add Queuetracking
ADD https://plugins.matomo.org/api/2.0/plugins/QueuedTracking/download/3.3.3 /usr/src/QueuedTracking.zip

# Add unzip
RUN apt-get update && apt-get install -y unzip \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

