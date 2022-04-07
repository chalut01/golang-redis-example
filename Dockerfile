FROM golang:1.18.0 AS build
WORKDIR /app
RUN go install github.com/gomodule/redigo/redis@latest
RUN go install google.golang.org/appengine@latest
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