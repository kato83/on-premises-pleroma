FROM elixir:1.11.4-alpine

ARG PLEROMA_VER=develop
ARG UID=1000
ARG GID=1000
ARG DATA=/var/lib/pleroma

ENV MIX_ENV=prod
ENV HOME=/usr/local/pleroma
ENV PLEROMA_CONFIG_PATH=${HOME}/config/${MIX_ENV}.exs

RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/main" >> /etc/apk/repositories \
    && apk update \
    && apk add git gcc g++ musl-dev make cmake file-dev exiftool imagemagick libmagic ncurses postgresql-client ffmpeg \
    && addgroup -g ${GID} pleroma \
    && adduser -h ${HOME} -s /bin/false -D -G pleroma -u ${UID} pleroma \
    && mkdir -p ${DATA}/uploads \
    && mkdir -p ${DATA}/static \
    && chown -R pleroma ${DATA} \
    && ln -s ${HOME}/bin/pleroma /usr/local/bin/pleroma \
    && ln -s ${HOME}/bin/pleroma_ctl /usr/local/bin/pleroma_ctl \
    && ln -s ${HOME}/docker-entrypoint.sh /usr/local/bin/pleroma-entrypoint

USER pleroma
WORKDIR ${HOME}

RUN git clone -b develop https://git.pleroma.social/pleroma/pleroma.git ${HOME} \
    && git checkout ${PLEROMA_VER} \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only prod \
    && mkdir release \
    && mix release --path ${HOME}

EXPOSE 4000

ENTRYPOINT ["/usr/local/bin/pleroma-entrypoint"]
