FROM python:3.13.5-bookworm as build-env
ARG HEALTHCHECKS_VERSION=v3.10
# Install
USER root

RUN echo "## build packages" && \
	apt update && apt install -y \
	build-essential \
	libpq-dev \
	libmariadb-dev \
	libffi-dev \
	libssl-dev  \
	libcurl4-openssl-dev \
	libpython3-dev \
	git \
	curl 

ENV CARGO_NET_GIT_FETCH_WITH_CLI true
RUN  echo "## Get healthchecks from Github" && \
	mkdir -p /app && \
	# Clone Repo
	git clone https://github.com/healthchecks/healthchecks.git /app && \
	cd /app && \
	echo "#### Building Version: $HEALTHCHECKS_VERSION" && \
	git checkout $HEALTHCHECKS_VERSION 


RUN  echo "## Pip requirements" && \
	cd /app && \
    pip install --upgrade pip && \
	pip wheel --wheel-dir /wheels apprise uwsgi mysqlclient minio && \
	pip wheel --wheel-dir /wheels -r requirements.txt 

####################################
#Runtime!!##########################
####################################
FROM python:3.13.5-slim-bookworm

LABEL maintainer="Kai Struessmann <kstrusmann@craftingit.de>"

ENV DEBUG False
ENV DEVELOPMENT_MODE False
ENV USE_PAYMENTS False
ENV DB_NAME /data/hc.sqlite
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN echo "## runtime packages" \
	&&  apt update && \
	apt install -y --no-install-recommends libpq5 \
	libcurl4 \
	libmariadb3 \
	supervisor \
	curl \
	uwsgi && \
    rm -rf /var/apt/cache

RUN groupadd  -g 1000 healthchecks && \
	useradd -u 1000 -g healthchecks healthchecks 

COPY --from=build-env /app /app
COPY --from=build-env /wheels /wheels

RUN mkdir /data && chown healthchecks:healthchecks /data && chown healthchecks:healthchecks -R /app

RUN pip install --no-cache /wheels/*

VOLUME /data

COPY container-fs /

RUN chmod +x /*.sh

RUN chmod +x /app/fetchstatus.py

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD python /app/fetchstatus.py

EXPOSE 8000/tcp
EXPOSE 2525/tcp
ENTRYPOINT ["sh", "/entrypoint.sh"]
