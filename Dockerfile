# ---- Build Stage ----
FROM elixir:1.10-alpine AS app_builder

ENV MIX_ENV=prod

RUN apk add build-base

# Install hex and rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# Create the application build directory
RUN mkdir /app
WORKDIR /app

# Fetch the application dependencies and build the application
COPY apps/buzzcms/mix.exs ./apps/buzzcms/mix.exs
COPY apps/buzzcms_web/mix.exs ./apps/buzzcms_web/mix.exs
COPY mix.* ./
RUN mix do deps.get --only $MIX_ENV, deps.compile

# Copy over all the necessary application files and directories
COPY config ./config
COPY apps ./apps

RUN mix release

# Build Production App
FROM alpine

ENV LANG=C.UTF-8

# Install openssl
RUN apk update && apk add openssl ncurses-libs

# RUN useradd --create-home app
WORKDIR /home/app
COPY --from=app_builder /app/_build .
# RUN chown -R app: ./prod
# USER app

# Run the Phoenix app
CMD ["prod/rel/web/bin/web", "start"]
