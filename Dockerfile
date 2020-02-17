FROM golang:latest
MAINTAINER Jerome <haodima521@126.com>
WORKDIR /
ADD main /
ENV PORT 8081
EXPOSE 8082
ENTRYPOINT ["./main"]
