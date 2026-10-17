FROM alpine:3.19

# install networking and system diagnostic tools
RUN apk add --no-cache \
    bash coreutils procps util-linux \
    iputils bind-tools iproute2 net-tools

WORKDIR /app
COPY app/ .
RUN chmod +x diagnostic.sh health-check.sh

ENTRYPOINT ["./diagnostic.sh"]
CMD ["help"]
