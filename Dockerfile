FROM python:3.8.1-alpine3.11
LABEL maintainer="Kai Struessmann <kstrusmann@craftingit.de>"

ARG HEALTHCHECKS_VERSION

# Install
USER root

RUN echo "**** install build packages ****" && \
 apk add --no-cache --upgrade --virtual=build-dependencies \
	git \
	postgresql-dev \
    gcc \
	musl-dev \
    curl

RUN echo "**** install runtime packages ****" && \
 apk add --no-cache --upgrade \
	mariadb-client \
	postgresql-client

RUN  echo "**** install healthchecks ****" && \
 mkdir -p /app/healthchecks && \
 if [ -z ${HEALTHCHECKS_VERSION+x} ]; then \
	HEALTHCHECKS_VERSION=$(curl -sX GET "https://api.github.com/repos/healthchecks/healthchecks/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 git clone https://github.com/healthchecks/healthchecks.git /app/healthchecks && \
    cd /app/healthchecks && \
    git checkout $HEALTHCHECKS_VERSION 
    

RUN  echo "**** install pip packages ****" && \
 cd /app/healthchecks && \
 pip3 install --no-cache-dir -r requirements.txt
 
RUN echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

ENTRYPOINT ["/entrypoint.sh"]