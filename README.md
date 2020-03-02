# healthchecks-docker
Simple Docker image for https://github.com/healthchecks/healthchecks  

[![](https://badgen.net/badge/docker/Docker?icon&label=View%20on)](https://hub.docker.com/r/craftingit/healthchecks-docker) ![](https://badgen.net/docker/pulls/craftingit/healthchecks-docker?icon=docker&label=pulls) ![](https://badgen.net/docker/stars/craftingit/healthchecks-docker?icon=docker&label=stars)
![](https://badgen.net/docker/size/craftingit/healthchecks-docker?icon=docker)

## Docker Compose
````
---
version: "2"
services:
  healthchecks:
    image: craftingit/healthchecks-docker:latest
    container_name: healthchecks
    environment:
      - SITE_NAME=test
      - DEFAULT_FROM_EMAIL=test@test.local
      - REGISTRATION_OPEN=False
    # To monitor Healtchecks local and with healthchecks.io online service. 
    #  - FIFTEEN_MINUTES_WATCHDOG1=
    #  - FIFTEEN_MINUTES_WATCHDOG2=
    # Create Superuser
    #  - SUPERUSER_EMAIL=test@test.local
    #  - SUPERUSER_PASSWORD=123456
    volumes:
      - ./data:/data
    ports:
      - 8000:8000
    restart: unless-stopped

````