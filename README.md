# bit-magic-huff-speedrun

Speedrun of [@saxenism](@saxenism)'s [Solidity - Bit Magic](https://saxenism.com/web3/solidity/language-tricks/bit-magic/intermediate/2022/09/06/Bit-Magic-Solidity.html) using [Huff](huff.sh).

## Getting Started

### Requirements

The following will need to be installed. Please follow the links and instructions.

-   [Foundry / Foundryup](https://github.com/gakonst/foundry)
    -   This will install `forge`, `cast`, and `anvil`
    -   You can test you've installed them right by running `forge --version` and get an output like: `forge 0.2.0 (92f8951 2022-08-06T00:09:32.96582Z)`
    -   To get the latest of each, just run `foundryup`
-   [Huff Compiler](https://docs.huff.sh/get-started/installing/)
    -   You'll know you've done it right if you can run `huffc --version` and get an output like: `huffc 0.3.0`

### Quickstart

1. Clone this repo or use template

```
git clone git@github.com:devtooligan/bit-magic-huff-speedrun.git
cd bit-magic-huff-speedrun
```

2. Install dependencies

Once you've cloned and entered into your repository, you need to install the necessary dependencies. In order to do so, simply run:

```shell
forge install
```

3. Build & Test

To build and test your contracts, you can run:

```shell
forge build
forge test
```

For more information on how to use Foundry, check out the [Foundry Github Repository](https://github.com/foundry-rs/foundry/tree/master/forge) and the [foundry-huff library repository](https://github.com/huff-language/foundry-huff).

