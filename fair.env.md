# FAIR Network Blockscout Configuration

To deploy Blockscout for FAIR network, an `.env` file should be created based on this template.

### Arguments

- **HOST** - hostname where the explorer will be accessible _(required)_
- **CHAIN_ID** - chain ID for the FAIR network _(required)_
- **ENDPOINT** - RPC endpoint for blockchain interaction _(required)_
- **WS_ENDPOINT** - WebSocket endpoint for real-time data _(required)_
- **IS_TESTNET** - whether this is a testnet deployment (true/false) _(optional)_
- **SCHAIN_NAME** - name of the FAIR chain for flexibility purposes _(required)_
- **COMPOSE_PROJECT_NAME** - Docker Compose project name (affects container naming) _(required)_
- **SCHAIN_APP_NAME** - application name shown in the UI _(required)_
- **PROXY_PORT** - HTTP/HTTPS proxy port for external access _(required)_
- **DB_PORT** - database port for main app _(required)_
- **STATS_PORT** - statistics service port _(required)_
- **STATS_DB_PORT** - statistics database port _(required)_
- **BLOCKSCOUT_BACKEND_DOCKER_TAG** - version of blockscout backend container to use _(optional)_
- **BLOCKSCOUT_FRONTEND_DOCKER_TAG** - version of blockscout frontend container to use _(optional)_
- **STATIC_BLOCK_REWARD** - static block reward in wei for emission calculations _(optional)_
- **BURNT_FEE_FRACTION** - fraction of gas fees that are burnt (0.0 to 1.0) _(optional)_
- **WALLET_CONNECT_PROJECT_ID** - WalletConnect project ID for wallet integration _(required for production)_
- **DB_PASSWORD** - password for PostgreSQL database _(required for production)_
- **RE_CAPTCHA_SECRET_KEY** - private key used on blockscout server side to securely verify that user interactions are performed by humans _(optional)_
