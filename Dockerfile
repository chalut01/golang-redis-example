FROM golang:1.17.0 AS build
WORKDIR /app
COPY . .
RUN ls -l
RUN go env -w GO111MODULE=auto
RUN go get github.com/gomodule/redigo/redis
RUN go get google.golang.org/appengine
RUN go build -o /golang-redis .
RUN ls -l

# DEPLOY 
FROM ubuntu:18.04
WORKDIR /
COPY --from=build /golang-redis /golang-redis
EXPOSE 80
ENTRYPOINT ["/golang-redis"]