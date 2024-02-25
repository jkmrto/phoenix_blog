FROM hexpm/elixir:1.14.3-erlang-25.1.1-alpine-3.16.2  AS builder

# install build dependencies
RUN apk add --no-cache build-base npm git

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile


FROM node:14.14.0-alpine as frontend

WORKDIR /app
COPY --from=builder /app/deps/phoenix /app/deps/phoenix
COPY --from=builder /app/deps/phoenix_html /app/deps/phoenix_html
COPY --from=builder /app/deps/phoenix_live_view /app/deps/phoenix_live_view
COPY assets /app/assets

WORKDIR /app/assets
RUN npm ci --progress=false --no-audit --loglevel=error
RUN npm run deploy 


FROM builder as releaser
COPY . /app/
COPY --from=frontend /app/priv/static /app/priv/static
RUN mix do compile, release

FROM alpine:3.16.2 AS app
RUN apk add --no-cache ncurses-libs openssl libstdc++ libcrypto3

COPY --from=releaser /app/_build/prod/rel/phoenix_blog/ /phoenix_blog
COPY --from=releaser /app/priv /phoenix_blog/priv

WORKDIR /phoenix_blog
CMD bin/phoenix_blog start
