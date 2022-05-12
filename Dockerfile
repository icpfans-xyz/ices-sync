FROM ubuntu:22.04 as build
RUN apt-get update -qq && apt-get install -y \
    git \
    cmake \
    g++ \
    pkg-config \
    libssl-dev \
    curl \
    llvm \
    clang \
    libpq-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN cargo install diesel_cli --no-default-features --features "postgres" --bin diesel

WORKDIR /sync
RUN cargo new --bin cas-sync
WORKDIR /sync/cas-sync

COPY ./Cargo.toml ./Cargo.toml
COPY ./Cargo.lock ./Cargo.lock
COPY ./ ./

ENV CARGO_TARGET_DIR=/tmp/target
RUN cargo build --release

# ============================== EXECUTION ======================================
FROM ubuntu:22.04 as execution

RUN apt-get update -qq && apt-get install -y \
    libssl-dev \
    libpq-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /sync/cas-sync
COPY --from=build /tmp/target/release/ices-sync .

COPY --from=build /usr/local/cargo/bin/diesel .

COPY ./migrations ./migrations

ENV DATABASE_URL=postgresql://ices:password@localhost:5432/ices_sync \
    IC_URL=https://ic0.app \
    CANISTER_ID=hzpfi-laaaa-aaaah-aa4cq-cai \
    ROCKET_PORT=8006 \
    ROCKET_ADDRESS=0.0.0.0 \
    RUST_LOG=info

CMD ./diesel migration run && ./ices-sync
