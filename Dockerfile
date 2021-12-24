FROM rust:1.56.1 as builder

RUN USER=root cargo new --bin cas-sync
WORKDIR ./cas-sync
COPY ./Cargo.toml ./Cargo.toml
RUN cargo build --release \
    && rm src/*.rs target/release/deps/cas_sync*

ADD . ./

RUN cargo build --release


FROM debian:bookworm-slim

ARG APP=/usr/src/app

RUN apt-get update \
    && apt-get install -y ca-certificates tzdata \
    && apt-get install libpq5 -y \
    && rm -rf /var/lib/apt/lists/*


EXPOSE 8006

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN groupadd $APP_USER \
    && useradd -g $APP_USER $APP_USER \
    && mkdir -p ${APP}

COPY --from=builder /cas-sync/target/release/cas-sync ${APP}/cas-sync

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

ENV DATABASE_URL=postgresql://postgres:icp123@localhost:5432/icp123_sync \
    IC_URL=https://ic0.app \
    CANISTER_ID=hzpfi-laaaa-aaaah-aa4cq-cai \
    ROCKET_PORT=8006 \
    ROCKET_ADDRESS=0.0.0.0 \
    RUST_LOG=info

CMD ["./cas-sync"]