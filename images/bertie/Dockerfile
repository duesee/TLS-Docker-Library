FROM rust as bertie-base1
ARG VERSION
WORKDIR /src/
RUN git clone --depth=1 --branch=duesee/work https://github.com/cryspen/bertie
WORKDIR bertie
RUN cargo build --release --package simple_https_client

FROM debian:stable-slim as bertie-base2
FROM entrypoint as entrypoint

FROM bertie-base2 as bertie-client
ARG VERSION
LABEL "tls_implementation"="bertie"
LABEL "tls_implementation_version"="${VERSION}"
LABEL "tls_implementation_connectionRole"="client"
COPY --from=bertie-base1 /src/bertie/target/release/tls13client /usr/local/bin/
COPY --from=entrypoint /bin/client-entrypoint /usr/local/bin/
ENTRYPOINT ["client-entrypoint", "tls13client"]
