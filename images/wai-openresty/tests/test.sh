#!/bin/bash
docker compose up -d && \
sleep 5 && \
docker compose exec redis sh -c "echo SET 1 \\\"www.site-one.it site-two.it site-three.it\\\" | redis-cli" && \
docker compose exec redis sh -c "echo \"CONFIG SET protected-mode no\" | redis-cli" && \
newman run WAI-Openresty.postman_collection.json && \
docker compose rm -f -s -v
