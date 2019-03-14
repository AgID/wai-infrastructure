ARG MATOMO_WAI_VERSION=3.8.1

FROM matomo:${MATOMO_WAI_VERSION}-fpm
LABEL maintainer = "Agenzia per l'Italia Digitale"
LABEL author = "Fares Gianluca <gfares@indracompany.com>"
LABEL org.label-schema.name = "Web Analytics Italia - Matomo"
LABEL org.label-schema.vendor = "Agenzia per l'Italia Digitale"
LABEL org.label-schema.url = "https://www.agid.gov.it"
LABEL org.label-schema.schema-version = "1.0.0-rc.1"

ENV MATOMO_VERSION=$MATOMO_VERSION

ARG WAI_QT_VER=3.3.3
ENV WAI_QT_VER=$WAI_QT_VER

# Add GeoLite2 city
ADD https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz /usr/src/

# Add Queuetracking
ADD "https://plugins.matomo.org/api/2.0/plugins/QueuedTracking/download/${WAI_QT_VER}" /usr/src/QueuedTracking.zip

# Add unzip
RUN apt-get update && apt-get install -y unzip wget \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

