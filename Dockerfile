FROM perl:5.42-slim AS builder

WORKDIR /app

RUN cpanm App::cpanminus

COPY cpanfile /app/
RUN cpanm --notest --installdeps .

FROM perl:5.42-slim

WORKDIR /app

COPY --from=builder /usr/local/lib/perl5 /usr/local/lib/perl5
COPY --from=builder /usr/local/bin/cpanm /usr/local/bin/

COPY lib ./lib
COPY resources ./resources
COPY scripts ./scripts
COPY calidoscopio.pl ./calidoscopio.pl

ENTRYPOINT ["perl", "./calidoscopio.pl"]

CMD ["--help"]
