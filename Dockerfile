# build app
FROM hexpm/elixir:1.17.2-erlang-27.0.1-ubuntu-noble-20240801 AS builder

RUN apt-get update -y && apt-get install --no-install-recommends -y build-essential git ca-certificates \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

ARG BUILD_VERSION
ENV BUILD_VERSION=$BUILD_VERSION

ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV

WORKDIR /app

RUN mix local.hex --force && \
  mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config config
COPY assets assets
COPY lib lib
COPY priv priv
COPY rel rel

RUN --mount=type=cache,target=/app/deps \
    --mount=type=cache,target=/app/_build/prod \
      rm -rf /app/_build/prod/rel && \
      mix do deps.get --only $MIX_ENV, clean, assets.deploy, release && \
      # copy out of the cache so it is available
      cp -r /app/_build/prod/rel/uptime ./release

# Build release image
FROM ubuntu:noble

ENV LANG=C.UTF-8

RUN set -xe \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y --no-install-recommends openssl \
  && rm -rf /var/lib/apt/lists/*

USER 1000
WORKDIR /home/app

COPY --from=builder --chown=1000:1000 /app/release ./


CMD ["./bin/uptime", "start"]
