# build app
FROM hexpm/elixir:1.17.2-erlang-27.0.1-ubuntu-noble-20240801 AS builder

ARG BUILD_VERSION
ENV BUILD_VERSION $BUILD_VERSION

ARG MIX_ENV=prod
ENV MIX_ENV $MIX_ENV

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

RUN apt-get update -y \
  && apt-get install --no-install-recommends -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN adduser --uid 1000 nonroot

WORKDIR "/app"
RUN chown nonroot /app

ARG MIX_ENV=prod
ENV MIX_ENV $MIX_ENV

COPY --from=builder --chown=nonroot:nonroot /app/release ./

USER nonroot

CMD ["./bin/uptime", "start"]
