#!/usr/bin/env bash
#
# Scan availible wifi networks
# https://unix.stackexchange.com/questions/399222/jq-parse-colon-separated-value-pairs

# TODO see if you can pipe this directly into jq
nmcli_output=$(nmcli --mode multiline dev wifi)

# set all variables from nmcli
network=$(echo "$nmcli_output" | grep SSID: \
	| cut -d" " -f 2- | sed "s/^[ \t]*//")
mode=$(echo "$nmcli_output" | grep MODE: \
	| cut -d" " -f 2- | sed "s/^[ \t]*//" )
chan=$(echo "$nmcli_output" | grep CHAN: \
	| cut -d" " -f 2- | sed "s/^[ \t]*//" )
rate=$(echo "$nmcli_output" | grep RATE: \
	| cut -d" " -f 2- | sed "s/^[ \t]*//" )
signal=$(echo "$nmcli_output" | grep SIGNAL: \
	| cut -d" " -f 2- | sed "s/^[ \t]*//" )
bars=$(echo "$nmcli_output" | grep BARS: \
	| cut -d" " -f 2- | sed "s/^[ \t]*//" )
security=$(echo "$nmcli_output" | grep SECURITY: \
	| cut -d" " -f 2- | sed "s/^[ \t]*//" )

# generate json
echo "[" > /tmp/gen_json
network_iter=0
for i in $(echo $network | sed "s/,/ /g")
do
  network_iter=$(expr $network_iter + 1)

  # Get values for each attribute on each network
  network_instance=$(echo $network | cut -d"," -f $network_iter)
  mode_instance=$(echo $mode | cut -d" " -f $network_iter)
  chan_instance=$(echo $chan | cut -d" " -f $network_iter)
  rate_instance=$(echo $rate | cut -d" " -f $network_iter)
  signal_instance=$(echo $signal | cut -d" " -f $network_iter)
  bars_instance=$(echo $bars | cut -d" " -f $network_iter)
  security=$(echo $security | cut -d" " -f $network_iter)

  # Parse into json
  json="{
    \"network\": \"$network_instance\",
    \"mode\": \"$mode_instance\",
    \"chan\": \"$chan_instance\",
    \"rate\": \"$rate_instance\",
    \"signal\": \"$signal_instance\",
    \"bars\": \"$bars_instance\",
    \"security\": \"$security_instance\"
  }"
  echo "$json", >> /tmp/gen_json
done

# Remove last comma, change later?
perl -0777 -pi -e 's/(.*),(.*?)/\1\2/s' /tmp/gen_json
echo "]" >> /tmp/gen_json

# output json
cat /tmp/gen_json