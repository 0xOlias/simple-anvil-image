FROM ghcr.io/foundry-rs/foundry

EXPOSE 8545

ENV ANVIL_FORK_URL ""

ENTRYPOINT if [ -z $ANVIL_FORK_URL ]; then anvil --host 0.0.0.0; else anvil --host 0.0.0.0 --fork-url $ANVIL_FORK_URL; fi;