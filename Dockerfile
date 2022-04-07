FROM golang:1.18.0 AS build
WORKDIR /app
RUN go get github.com/gomodule/redigo/redis
RUN go get google.golang.org/appengine
COPY . .
RUN ls -l
RUN export GO111MODULE=auto
RUN go build . -o /golang-redis
RUN ls -l

# DEPLOY 
FROM alpine:3.14.6
WORKDIR /
COPY --from=build /golang-redis /golang-redis
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/golang-redis"]