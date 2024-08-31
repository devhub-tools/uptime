# syntax=docker/dockerfile:1.4

# ---- Build Stage ----
FROM golang:1.20-alpine AS build

WORKDIR /app

RUN apk add --no-cache build-base

COPY go.mod go.sum ./

RUN go mod download

COPY *.go ./
COPY --from=protobuf . protobuf

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o uptime_check

# ---- Application Stage ----
FROM alpine

COPY --from=build /app/uptime_check /uptime_check

USER 1000:1000
CMD ["/uptime_check"]
