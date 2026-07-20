FROM perl:5.44-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN cpanm App::cpanminus

COPY cpanfile /app/
RUN cpanm --notest --installdeps .

FROM perl:5.44-slim

WORKDIR /app

COPY --from=builder /usr/local/lib/perl5 /usr/local/lib/perl5
COPY --from=builder /usr/local/bin/cpanm /usr/local/bin/

COPY lib ./lib
COPY resources ./resources
COPY scripts ./scripts
COPY perceptio.pl ./perceptio.pl

ENTRYPOINT ["perl", "./perceptio.pl"]
CMD ["--help"]
