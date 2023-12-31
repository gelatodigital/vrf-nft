# Gelato-NFT

Template project using Gelato VRF to generate randomized NFTs.

## Setup

1. Clone the repo
2. Install forge modules `forge install`
3. Build the project: `forge build`

## Test

Run `forge test -vvv`

## Deploy

```console
forge script ./script/DeployIceCreamNFT.s.sol --rpc-url ${rpcurl}
```

## Verify contract

Populate `ETHERSCAN_MUMBAI_API_KEY` in `.env` or add a new network's etherscan api key in `foundry.toml`

```toml
mumbai = { key = "${ETHERSCAN_MUMBAI_API_KEY}" }
polygon = {key = "${ETHERSCAN_POLYGON_API_KEY}"}
```

In `/broadcast/DeployIceCreamNFT.s.sol/${chainId}/run-latest.json`, copy and note down

- `"contractAddress"` - Deployed `IceCreamNFT` address.
- `"arguments"` - Constructor argument (single address in the array).

Run the command

```console
forge verify-contract ${contractAddress} IceCreamNFT --chain-id ${chainid} --constructor-args $(cast abi-encode "constructor(address)" "${constructor argument}")
```

e.g.

```console
forge verify-contract 0xbde9e58E2D796e84502A68b8494faE1eb4c92CC2 IceCreamNFT --chain-id mumbai --constructor-args $(cast abi-encode "constructor(address)" "0xFD7089D182cB7b0005fF7dFdf8a86C828179a483")
```

## Create VRF Task

Replace `consumerAddress` in `CreateTask.s.sol` with your consumer address.

```ts
    function run() public payable broadcast {
        address consumerAddress = address(0); // Replace this
        require(consumerAddress != address(0), "CreateTask.s.sol: Replace consumerAddress");
    }
```

Make sure the constructor argument for `AutomateTaskCreator` is correct.
You can find the correct Automate address in the [docs](https://docs.gelato.network/developer-services/web3-functions/contract-addresses)

```ts
    constructor() AutomateTaskCreator(address(0x2A6C106ae13B558BB9E2Ec64Bd2f1f7BEFF3A5E0)) {}
```

Run this command to create a VRF task.

```console
forge script ./script/CreateTask.s.sol --rpc-url ${rpurl}
```

You can find the task id in the logs

```ts
== Logs ==
  Broadcaster:  0x5ce6047a715B1919A58C549E6FBc1921B4d9287D
  TaskId:
  0x02a07660d4312b8a6f794592c25daf1c31ae03e71d60bbb8aaa06bb2fd26cb36
```
