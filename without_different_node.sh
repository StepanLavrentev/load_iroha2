#!/usr/bin/env bash

set -e

CLI_PATH=/iroha_client_cli
CONF_JSON=/config.json
THREAD=1 #количество итераций в секунду
date
echo "rate: $THREAD calls / second"
START=$(date +%s);


get_asset () {
  $CLI_PATH -c $CONF_JSON asset get --account_id="Alice@Soramitsu" --id="XOR#Soramitsu"
}

add_domain () {
  random_domain=`openssl rand -base64 12`
  $CLI_PATH -c $CONF_JSON domain add --name="$random_domain" | awk -v date="$(date +'%r')" '{print $0"\n-----", date}' >> /tmp/log.txt
}

register_account () {
  random_name=`openssl rand -base64 12`
  $CLI_PATH -c $CONF_JSON account register --name="$random_name" --domain="Soramitsu" --key="[101, 170, 80, 164, 103, 38, 73, 61, 223, 133, 83, 139, 247, 77, 176, 84, 117, 15, 22, 28, 155, 125, 80, 226, 40, 26, 61, 248, 40, 159, 58, 53]" | awk -v date="$(date +'%r')" '{print $0"\n-----", date}' >> /tmp/log.txt
}

asset_register () {
  $CLI_PATH -c $CONF_JSON asset register --name="XOR" --domain="Soramitsu" | awk -v date="$(date +'%r')" '{print $0"\n-----", date}' >> /tmp/log.txt
}

asset_mint () {
  $CLI_PATH -c $CONF_JSON asset mint --account_id="Alice@Soramitsu" --id="XOR#Soramitsu" --quantity="1"
}

initiate () {
  $CLI_PATH -c $CONF_JSON domain add --name="Soramitsu"
  sleep 1
  $CLI_PATH -c $CONF_JSON account register --name="Alice" --domain="Soramitsu" --key="[101, 170, 80, 164, 103, 38, 73, 61, 223, 133, 83, 139, 247, 77, 176, 84, 117, 15, 22, 28, 155, 125, 80, 226, 40, 26, 61, 248, 40, 159, 58, 53]"
  sleep 1
  $CLI_PATH -c $CONF_JSON asset register --name="XOR" --domain="Soramitsu"
}

initiate
sleep 4
while true
do
  echo $(($(date +%s) - START)) | awk '{print int($max/60)":"int($max%60)}'
  sleep 2

  for i in `seq 1 $THREAD`
  do
    asset_mint &
  done
  get_asset &
done