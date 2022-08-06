FROM python:3.10.5-slim-buster as build-env
ARG HEALTHCHECKS_VERSION=v2.3
# Install
USER root

RUN echo "## build packages" && \
	apt update && apt install -y \
	build-essential \
	libpq-dev \
	git \
	curl 

RUN  echo "## Get healthchecks from Github" && \
	mkdir -p /app && \
	# Clone Repo
	git clone https://github.com/healthchecks/healthchecks.git /app && \
	cd /app && \
	echo "#### Building Version: $HEALTHCHECKS_VERSION" && \
	git checkout $HEALTHCHECKS_VERSION 


RUN  echo "## Pip requirements" && \
	cd /app && \
	pip wheel --wheel-dir /wheels -r requirements.txt \
	pip wheel --wheel-dir /wheels apprise uwsgi

####################################
#Runtime!!##########################
####################################
FROM python:3.10.5-slim-buster

LABEL maintainer="Kai Struessmann <kstrusmann@craftingit.de>"

ENV DEBUG False
ENV USE_PAYMENTS False
ENV DB_NAME /data/hc.sqlite
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN echo "## runtime packages" \
	&&  apt update && \
    apt install -y libpq5 \
	supervisor \
	curl \
	cron \
    uwsgi && \
    rm -rf /var/apt/cache

RUN groupadd  -g 1000 healthchecks && \
	useradd -u 1000 -g healthchecks healthchecks 

COPY --from=build-env /app /app
COPY --from=build-env /wheels /wheels

RUN mkdir /data && chown healthchecks:healthchecks /data && chown healthchecks:healthchecks -R /app

RUN pip install --no-cache /wheels/*

RUN mkdir -p /var/log/cron \
	&& touch /var/log/cron/cron.log \
	&& chown healthchecks:healthchecks /var/log/cron -R

VOLUME /data

COPY container-fs /

RUN chmod +x /*.sh

EXPOSE 8000/tcp
ENTRYPOINT ["sh", "/entrypoint.sh"]
