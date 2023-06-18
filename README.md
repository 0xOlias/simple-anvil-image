# simple-anvil-image

A docker image that installs Foundry and runs an Anvil node. This package was developed to support [Ponder](https://ponder.sh)'s benchmarks.

## Usage

This image was designed to be used as a _service_ in GitHub Action workflows (rather than a workflow step that installs Foundry on the host machine). Services are sometimes preferable to running processes directly on the host machine, because they tend to start up faster and networking is simpler.

Notes:
- You can run this image locally, e.g. `docker run -p 8545:8545 -e ANVIL_FORK_URL=https://eth-mainnet.g.alchemy.com/v2/... simple-anvil-image` and it should serve requests at `http://localhost:8545`.
- The `--host` CLI flag is hard-coded to `0.0.0.0` (required for Docker networking to work as expected).
- To enable forking for the duration of the process, provide the ANVIL_FORK_URL env var.
- Rather than passing CLI flags to configure additional settings like the fork block number and automining behavior, configure these values after the service has already started using the `anvil_` RPC methods. The viem [Test Client](https://viem.sh/docs/clients/test.html) makes this very easy.

## Sample GitHub Action workflow

Notes:
- The service will be available at `http://localhost:8545` in any workflow steps that run directly on the runner (like `pnpm bench` shown below).
- The service will be available at `http://anvil:8545` in any other services (such as the `graph-node` service shown below).

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
          ANVIL_FORK_URL: ${{ secrets.ANVIL_FORK_URL }}
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


```

## Control using viem Test Client

For example, this code would run as expected in the `pnpm bench` step of the workflow above.

```ts
import { type Chain, createTestClient, http } from "viem";
import { mainnet } from "viem/chains";

const anvil = {
  ...mainnet, // We are using a mainnet fork for testing.
  id: 1,
  rpcUrls: {
    default: {
      http: [`http://localhost:8545`],
      webSocket: [`ws://localhost:8545`],
    },
    public: {
      http: [`http://localhost:8545`],
      webSocket: [`ws://localhost:8545`],
    },
  },
} as Chain;

const testClient = createTestClient({
  chain: anvil,
  mode: "anvil",
  transport: http(),
});

async function resetAnvil() {
  await testClient.setAutomine(false);
  await testClient.setRpcUrl("https://quiknode.pro/...");
  await testClient.reset({ blockNumber: 16_000_000n });
}
```
