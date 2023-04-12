PRIVKEY=${PRIVKEY:-$(cat ~/.bitcoin/PRIVKEY.txt)}
DATADIR=${DATADIR:-~/.bitcoin/}
bitcoind -datadir=$DATADIR --daemonwait -persistmempool
bitcoin-cli -datadir=$DATADIR -named createwallet wallet_name="custom_signet" load_on_startup=true descriptors=false

#only used in case of mining node
if [[ "$MINERENABLED" == "1" ]]; then
    bitcoin-cli -datadir=$DATADIR importprivkey $PRIVKEY

  # Descriptors take private keys in WIF format

#   # Add the testnet prefix 'ef'
#   prefix_key="ef$PRIVKEY"
#   # Double sha256 hash of prefix key
#   double_hash=$(echo -n $prefix_key | xxd -r -p | openssl sha256 | awk '{print $2}' | xxd -r -p | openssl sha256 | awk '{print $2}')
#   # Take first 4 bytes of double hash as checksum
#   checksum=${double_hash:0:8}
#   # Append checksum to prefix key
#   checksum_key="$prefix_key$checksum"
#   # Convert the final key into base58 encoding
#   WIF_KEY=$(echo -n $checksum_key | xxd -r -p | base58)

#     ## for future with descriptor wallets, cannot seem to get it working yet
#      descinfo=$(bitcoin-cli getdescriptorinfo "wpkh(${WIF_KEY})")
#      checksum=$(echo "$descinfo" | jq .checksum | tr -d '"' | tr -d "\n")
#      desc='[{"desc":"wpkh('$WIF_KEY')#'$checksum'","timestamp":0,"internal":false}]'
#      bitcoin-cli -datadir=$DATADIR importdescriptors $desc
fi