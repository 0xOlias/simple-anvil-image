# simple-anvil-image

A docker image that installs Foundry and runs an Anvil node. This package was developed to support Ponder's benchmarks.

## Usage

This image was designed to be used as a service in GitHub Action workflows. Services are preferable to running processes directly on the host machine, because they tend to start up faster and networking is simpler.

Notes:
- For networking to work properly, be sure to set the `ANVIL_IP_ADDR` environment variable to `0.0.0.0` as shown in the example below.
- The service will be available at `http://localhost:8545` in any workflow steps that run directly on the runner.
- The service will be available at `http://anvil:8545` in any other services (such as the `graph-node` service shown below).
- Rather than passing CLI flags to configure settings like the fork URL, fork block number, and automining behavior, configure these values after the service has already started using the `anvil_` RPC methods. The viem [Test Client](https://viem.sh/docs/clients/test.html) makes this very easy.

### Sample GitHub Action workflow

```yaml
name: Bench

on:
  workflow_dispatch:

jobs:
  bench:
    name: Bench
    runs-on: ubuntu-latest
    services:
      anvil:
        image: ghcr.io/0xolias/simple-anvil-image:main
        env:
          ANVIL_IP_ADDR: 0.0.0.0
        ports:
          - 8545:8545
      graph-node:
        image: graphprotocol/graph-node
        env:
          ethereum: mainnet:http://anvil:8545
        ports:
          - 8000:8000
    steps:
      - name: Clone repository
        uses: actions/checkout@v3

      # The Anvil node will now be available at http://localhost:8545 in your workflow steps.
      - name: Bench
        run: pnpm bench
        env:
          ANVIL_FORK_URL: ${{ secrets.ANVIL_FORK_URL }}
          ANVIL_BLOCK_NUMBER: 17500050
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/postgres


```