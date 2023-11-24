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
$ forge script ./script/DeployIceCreamNFT.s.sol --rpc-url ${rpcurl}
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
forge verify-contract 0xcD5Cc3a3cE0EdB77D51b6270908B1b2355B66797 IceCreamNFT --chain-id mumbai --constructor-args $(cast abi-encode "constructor(address)" "0xFD7089D182cB7b0005fF7dFdf8a86C828179a483")
```
