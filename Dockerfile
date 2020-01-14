FROM python:3.8.1-alpine3.11 as build-env
ARG HEALTHCHECKS_VERSION
# Install
USER root

RUN echo "## build packages" && \
	apk add --no-cache --upgrade --virtual=build-dependencies \
	git \
	curl \
	postgresql-dev \
	gcc \
	make \
	musl-dev \
	linux-headers \
	jq


RUN  echo "## Get healthchecks from Github" && \
	mkdir -p /app && \
	# If Version is not Set use Latest
	if [ -z ${HEALTHCHECKS_VERSION+x} ]; then \
		echo "#### Getting latest Release!!"; \
		HEALTHCHECKS_VERSION=$(curl -s 'https://api.github.com/repos/healthchecks/healthchecks/releases/latest' | jq -r '.tag_name'); \
	fi && \
	# Clone Repo
	git clone https://github.com/healthchecks/healthchecks.git /app && \
	cd /app && \
	echo "#### Building Version: $HEALTHCHECKS_VERSION" && \
	git checkout $HEALTHCHECKS_VERSION 


RUN  echo "## Pip requirements" && \
	cd /app && \
	mkdir -p /build && \
	pip install --prefix="/build" --no-warn-script-location -r requirements.txt   \
	uwsgi

####################################
#Runtime!!##########################
####################################
FROM python:3.8.1-alpine3.11

LABEL maintainer="Kai Struessmann <kstrusmann@craftingit.de>"

ENV DEBUG False
ENV USE_PAYMENTS False
ENV DB_NAME /data/hc.sqlite
WORKDIR /app

RUN echo "## runtime packages" \
	&& apk add --no-cache --upgrade \
	mariadb-client \
	postgresql-client \
	libpq \
	mailcap \
	supervisor \
	curl \
	dcron

RUN addgroup -g 1000 -S healthchecks && \
	adduser -u 1000 -S healthchecks -G healthchecks

COPY --from=build-env /build /usr/local
COPY --from=build-env /app /app

RUN mkdir /data && chown healthchecks:healthchecks /data && chown healthchecks:healthchecks -R /app

RUN mkdir -p /var/log/cron \
	&& touch /var/log/cron/cron.log \
	&& chown healthchecks:healthchecks /var/log/cron -R

VOLUME /data

COPY container-fs /

RUN chmod +x /*.sh

EXPOSE 8000/tcp
ENTRYPOINT ["/entrypoint.sh"]