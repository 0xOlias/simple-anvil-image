FROM ghcr.io/foundry-rs/foundry

EXPOSE 8545

ENV ANVIL_FORK_URL ""
ENV ANVIL_FORK_BLOCK_NUMBER ""

ENTRYPOINT \
  if ! [ -z $ANVIL_FORK_URL ]; then \
    if ! [ -z $ANVIL_FORK_BLOCK_NUMBER ]; then \
      anvil --host 0.0.0.0 --fork-url $ANVIL_FORK_URL --fork-block-number $ANVIL_FORK_BLOCK_NUMBER; \
    else \
      anvil --host 0.0.0.0 --fork-url $ANVIL_FORK_URL; \
    fi; \
  else \
    anvil --host 0.0.0.0; \
  fi;