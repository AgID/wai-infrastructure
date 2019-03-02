#!/bin/sh
set -e

if [ ! -e piwik.php ]; then
  tar cf - --one-file-system -C /usr/src/piwik . | tar xf -
  chown -R www-data .
fi

if [ -e /usr/src/GeoLite2-City.tar.gz ]; then
  if [ ! -d misc ]; then
    mkdir misc
  fi
  tar xzf /usr/src/GeoLite2-City.tar.gz --strip-components=1 -C misc --wildcards "*.mmdb" && rm -f GeoLite2-City.tar.gz
fi

if [ -e /usr/src/QueuedTracking.zip ]; then
  unzip -qq /usr/src/QueuedTracking.zip -d plugins/ && rm -f /usr/src/QueuedTracking.zip
fi

chown -R www-data . 

exec "$@"
