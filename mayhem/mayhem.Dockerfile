# Build Stage
FROM rustlang/rust:nightly AS builder

RUN cargo install cargo-fuzz

## Add source code to the build stage.
ADD . /src
WORKDIR /src

# Pin hexpm and protobuf to the exact versions gleam-core was developed against
# (hexpm ^2.0.0 resolves to 2.4.1 which has incompatible http/protobuf deps).
RUN sed -i '/^libfuzzer-sys/a hexpm = "=2.0.0"\nprotobuf = "=2.27.1"' compiler-core/fuzz/Cargo.toml && \
    cd compiler-core/fuzz && cargo fuzz build

# Package Stage
FROM ubuntu:latest
COPY --from=builder /src/compiler-core/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_* /fuzz/
