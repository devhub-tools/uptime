# build app
FROM hexpm/elixir:1.17.2-erlang-27.0.1-ubuntu-noble-20240801 AS builder

# Used to differentiate staging and production
ARG DEPLOY_CONTEXT
ENV DEPLOY_CONTEXT $DEPLOY_CONTEXT

ARG BUILD_VERSION
ENV BUILD_VERSION $BUILD_VERSION

ARG MIX_ENV
ENV MIX_ENV $MIX_ENV

WORKDIR /app

RUN mix local.hex --force && \
  mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
COPY config/config.exs config/prod.exs config/runtime.exs config/
COPY lib lib
COPY priv priv

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN MIX_ENV=prod mix deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN MIX_ENV=prod mix phx.digest

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

ENV MIX_ENV="prod"

COPY --from=builder --chown=nonroot:nonroot /app/release ./

USER nonroot

CMD ["./bin/socket", "start"]
