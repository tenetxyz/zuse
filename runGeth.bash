geth \
  --datadir geth-datadir\
  --dev \
  --dev.gaslimit 2000000000 \
  --rpc.gascap 2000000000 \
  --miner.gaslimit 2000000000 \
  --http \
  --http.api eth,web3,net \
  --http.addr "0.0.0.0" \
  --http.vhosts "*" \
  --http.port 8545 \
  --http.corsdomain "*" \
  --ws \
  --ws.addr "0.0.0.0" \
  --ws.api eth,web3,net \
  --ws.port 8545 \
  --ws.origins "*"

# node initAccounts.js
