FROM alpine:3.19

# install networking and system diagnostic tools
RUN apk add --no-cache \
    bash coreutils procps util-linux \
    iputils bind-tools iproute2 net-tools

WORKDIR /app
COPY app/ .
RUN chmod +x diagnostic.sh health-check.sh

RUN addgroup -S app && adduser -S app -G app
USER app

ENTRYPOINT ["./diagnostic.sh"]
CMD ["help"]
