#!/bin/bash

# COLORING
YELLOW=`tput setaf 3`
RESET=`tput sgr0`

REMOTE_BALANCE=$(lncli listchannels | jq -r '.[][].remote_balance' | awk '{s+=$1} END {print s}')
LOCAL_BALANCE=$(lncli listchannels | jq -r '.[][].local_balance' | awk '{s+=$1} END {print s}')
TOTAL_BALANCE=$((REMOTE_BALANCE + LOCAL_BALANCE))
ONCHAIN_FUNDS=$(lncli walletbalance | jq -r '.total_balance')

LOCAL_BALANCE_BTC=$(printf %.3f\\n "$(($LOCAL_BALANCE))e-8")
REMOTE_BALANCE_BTC=$(printf %.3f\\n "$(($REMOTE_BALANCE))e-8")
TOTAL_BALANCE_BTC=$(printf %.3f\\n "$(($TOTAL_BALANCE))e-8")
ONCHAIN_FUNDS_BTC=$(printf %.3f\\n "$(($ONCHAIN_FUNDS))e-8")

LOCAL_BALANCE_PERCENTAGE=$((100 * $LOCAL_BALANCE / $TOTAL_BALANCE))
REMOTE_BALANCE_PERCENTAGE=$((100 * $REMOTE_BALANCE / $TOTAL_BALANCE))
TOTAL_BALANCE_PERCENTAGE=100


echo -e "\n${YELLOW}LN BALANCE${RESET}"
echo -e "LOCAL\t\tREMOTE\t\tTOTAL"
echo -e "--------------\t---------------\t---------------"
echo -e "$LOCAL_BALANCE sats\t$REMOTE_BALANCE sats\t$TOTAL_BALANCE sats"
echo -e "$LOCAL_BALANCE_BTC BTC\t$REMOTE_BALANCE_BTC BTC\t$TOTAL_BALANCE_BTC BTC"
echo -e "$LOCAL_BALANCE_PERCENTAGE%\t\t$REMOTE_BALANCE_PERCENTAGE%\t\t$TOTAL_BALANCE_PERCENTAGE%"
echo -e "\n${YELLOW}ON-CHAIN BALANCE${RESET}"
echo -e "$ONCHAIN_FUNDS sats | $ONCHAIN_FUNDS_BTC BTC \n"
