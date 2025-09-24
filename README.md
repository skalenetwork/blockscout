<h1 align="center">Blockscout</h1>
<p align="center">Blockchain Explorer for inspecting and analyzing EVM Chains.</p>
<div align="center">

[![Blockscout](https://github.com/blockscout/blockscout/workflows/Blockscout/badge.svg?branch=master)](https://github.com/blockscout/blockscout/actions)
[![](https://dcbadge.vercel.app/api/server/blockscout?style=flat)](https://discord.gg/blockscout)

</div>


Blockscout provides a comprehensive, easy-to-use interface for users to view, confirm, and inspect transactions on EVM (Ethereum Virtual Machine) blockchains. This includes Ethereum Mainnet, Ethereum Classic, Optimism, Gnosis Chain and many other **Ethereum testnets, private networks, L2s and sidechains**.

See our [project documentation](https://docs.blockscout.com/) for detailed information and setup instructions.

For questions, comments and feature requests see the [discussions section](https://github.com/blockscout/blockscout/discussions) or via [Discord](https://discord.com/invite/blockscout).

## About Blockscout

Blockscout allows users to search transactions, view accounts and balances, verify and interact with smart contracts and view and interact with applications on the Ethereum network including many forks, sidechains, L2s and testnets.

Blockscout is an open-source alternative to centralized, closed source block explorers such as Etherscan, Etherchain and others.  As Ethereum sidechains and L2s continue to proliferate in both private and public settings, transparent, open-source tools are needed to analyze and validate all transactions.

## Supported Projects

Blockscout currently supports several hundred chains and rollups throughout the greater blockchain ecosystem. Ethereum, Cosmos, Polkadot, Avalanche, Near and many others include Blockscout integrations. [A comprehensive list is available here](https://docs.blockscout.com/about/projects). If your project is not listed, please submit a PR or [contact the team in Discord](https://discord.com/invite/blockscout).

## Getting Started

See the [project documentation](https://docs.blockscout.com/) for instructions:

- [Manual deployment](https://docs.blockscout.com/for-developers/deployment/manual-deployment-guide)
- [Docker-compose deployment](https://docs.blockscout.com/for-developers/deployment/docker-compose-deployment)
- [Kubernetes deployment](https://docs.blockscout.com/for-developers/deployment/kubernetes-deployment)
- [Manual deployment (backend + old UI)](https://docs.blockscout.com/for-developers/deployment/manual-old-ui)
- [Ansible deployment](https://docs.blockscout.com/for-developers/ansible-deployment)
- [ENV variables](https://docs.blockscout.com/setup/env-variables)
- [Configuration options](https://docs.blockscout.com/for-developers/configuration-options)

# FAIR Network Blockscout Configuration

To deploy Blockscout for FAIR network, an `.env` file should be created based on this template.

## Arguments
### Required
- **HOST** - hostname where the explorer will be accessible _(required)_
- **CHAIN_ID** - chain ID for the FAIR network _(required)_
- **ENDPOINT** - RPC endpoint for blockchain interaction _(required)_
- **WS_ENDPOINT** - WebSocket endpoint for real-time data _(required)_
- **SCHAIN_NAME** - name of the FAIR chain for flexibility purposes _(required)_
- **COMPOSE_PROJECT_NAME** - Docker Compose project name (affects container naming) _(required)_
- **SCHAIN_APP_NAME** - application name shown in the UI _(required)_
- **PROXY_PORT** - HTTP/HTTPS proxy port for external access _(required)_
- **DB_PORT** - database port for main app _(required)_
- **STATS_PORT** - statistics service port _(required)_
- **STATS_DB_PORT** - statistics database port _(required)_
- **WALLET_CONNECT_PROJECT_ID** - WalletConnect project ID for wallet integration _(required)_
### Optional
- **IS_TESTNET** - whether this is a testnet deployment (true/false) _(optional)_
- **BLOCKSCOUT_BACKEND_DOCKER_TAG** - version of blockscout backend container to use _(optional)_
- **BLOCKSCOUT_FRONTEND_DOCKER_TAG** - version of blockscout frontend container to use _(optional)_
- **STATIC_BLOCK_REWARD** - static block reward in wei for emission calculations _(optional)_
- **BURNT_FEE_FRACTION** - fraction of gas fees that are burnt (0.0 to 1.0) _(optional)_
### Required for production
- **DB_PASSWORD** - password for PostgreSQL database _(required for production)_
- **RE_CAPTCHA_SECRET_KEY** - private key used on blockscout server side to securely verify that user interactions are performed by humans _(required for production)_

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution and pull request protocol. We expect contributors to follow our [code of conduct](CODE_OF_CONDUCT.md) when submitting code or comments.

## License

[![License: GPL v3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
