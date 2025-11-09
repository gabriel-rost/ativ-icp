FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data

COPY client.sh /usr/local/bin/client.sh
RUN chmod +x /usr/local/bin/client.sh

CMD ["/usr/local/bin/client.sh"]