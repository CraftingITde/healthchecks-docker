FROM python:3.10.0-alpine3.13 as build-env
ARG HEALTHCHECKS_VERSION=v1.23.1
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
	openssl-dev \
	linux-headers \
	build-dependencies \
	build-base \
	libressl-dev \
	libffi-dev \
	build-base \
	cairo \
	cairo-dev \
	cargo \
	freetype-dev \
	gcc \
	gdk-pixbuf-dev \
	gettext \
	jpeg-dev \
	lcms2-dev \
	libffi-dev \
	musl-dev \
	openjpeg-dev \
	openssl-dev \
	pango-dev \
	poppler-utils \
	postgresql-client \
	postgresql-dev \
	py-cffi \
	python3-dev \
	rust \
	tcl-dev \
	tiff-dev \
	tk-dev \
	zlib-dev

RUN  echo "## Get healthchecks from Github" && \
	mkdir -p /app && \
	# Clone Repo
	git clone https://github.com/healthchecks/healthchecks.git /app && \
	cd /app && \
	echo "#### Building Version: $HEALTHCHECKS_VERSION" && \
	git checkout $HEALTHCHECKS_VERSION 


RUN  echo "## Pip requirements" && \
	cd /app && \
	mkdir -p /build && \
	pip3 install --prefix="/build" --no-warn-script-location -r requirements.txt \
	uwsgi \
	cryptography

####################################
#Runtime!!##########################
####################################
FROM python:3.10.0-alpine3.13

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
ENTRYPOINT ["sh", "/entrypoint.sh"]
