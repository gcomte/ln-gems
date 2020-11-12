#!/bin/bash

##############################################################################
# COLORING
##############################################################################

YELLOW=`tput setaf 3`
RESET=`tput sgr0`
GREEN=`tput setaf 2`
RED=`tput setaf 1`

##############################################################################
# CALCULATIONS
##############################################################################

LN_REMOTE_BALANCE=$(lncli listchannels | jq -r '.[][].remote_balance' | awk '{s+=$1} END {print s}')
LN_LOCAL_BALANCE=$(lncli listchannels | jq -r '.[][].local_balance' | awk '{s+=$1} END {print s}')
LN_TOTAL_BALANCE=$((LN_REMOTE_BALANCE + LN_LOCAL_BALANCE))
LN_COMMIT_FEES=$(lncli listchannels | jq -r '.[][] | select(.initiator==true) | .commit_fee' | awk '{s+=$1} END {print s}')
LN_INVOICES=$(lncli listinvoices | jq -r '.invoices[] | select(.settled==true) | .value' | awk '{s+=$1} END {print s}')
LN_PAYMENTS=$(lncli listpayments | jq -r '.payments[] | select(.status=="SUCCEEDED") | .value' | awk '{s+=$1} END {print s}')
LN_PAYMENTS_FEES=$(lncli listpayments | jq -r '.payments[] | select(.status=="SUCCEEDED") | .fee' | awk '{s+=$1} END {print s}')
LN_EARNED_FEES_IN_MSATS=$(lncli fwdinghistory 0 | jq -r '.forwarding_events[] | .fee_msat' | awk '{s+=$1} END {print s}')
LN_EARNED_FEES_IN_SATS=$((LN_EARNED_FEES_IN_MSATS / 1000))

ONCHAIN_FUNDS_CONFIRMED=$(lncli walletbalance | jq -r '.confirmed_balance')
ONCHAIN_FUNDS_UNCONFIRMED=$(lncli walletbalance | jq -r '.unconfirmed_balance')
ONCHAIN_FUNDS_TOTAL=$(lncli walletbalance | jq -r '.total_balance')


ONCHAIN_FUNDS_CONFIRMED_BTC=$(printf %.8f\\n "$((ONCHAIN_FUNDS_CONFIRMED))e-8")
ONCHAIN_FUNDS_UNCONFIRMED_BTC=$(printf %.8f\\n "$((ONCHAIN_FUNDS_UNCONFIRMED))e-8")
ONCHAIN_FUNDS_TOTAL_BTC=$(printf %.8f\\n "$((ONCHAIN_FUNDS_TOTAL))e-8")
ONCHAIN_TX_FEES=$(lncli listchaintxns | jq -r '.transactions[] | .total_fees' | awk '{s+=$1} END {print s}')

LN_LOCAL_BALANCE_PERCENTAGE=$((100 * LN_LOCAL_BALANCE / LN_TOTAL_BALANCE))
LN_REMOTE_BALANCE_PERCENTAGE=$((100 * LN_REMOTE_BALANCE / LN_TOTAL_BALANCE))
TOTAL_BALANCE_PERCENTAGE=100

ONCHAIN_FUNDS_CONFIRMED_PERCENTAGE=$((100 * ONCHAIN_FUNDS_CONFIRMED / ONCHAIN_FUNDS_TOTAL))
ONCHAIN_FUNDS_UNCONFIRMED_PERCENTAGE=$((100 * ONCHAIN_FUNDS_UNCONFIRMED / ONCHAIN_FUNDS_TOTAL))

TOTAL_BALANCE=$((ONCHAIN_FUNDS_TOTAL + LN_LOCAL_BALANCE))

CONTROL_SUM=$((\
  ONCHAIN_FUNDS_CONFIRMED\
  + ONCHAIN_FUNDS_UNCONFIRMED\
  + ONCHAIN_TX_FEES
  + LN_LOCAL_BALANCE\
  + LN_COMMIT_FEES\
  - LN_INVOICES\
  + LN_PAYMENTS\
  + LN_PAYMENTS_FEES
  - LN_EARNED_FEES_IN_SATS
))

PROFIT_AND_LOSS=$((LN_EARNED_FEES_IN_SATS - ONCHAIN_TX_FEES))
LN_SPEND=$((LN_PAYMENTS + LN_PAYMENTS_FEES))

##############################################################################
# Sats to BTC
##############################################################################

TOTAL_BALANCE_BTC=$(printf %.8f\\n "$((TOTAL_BALANCE))e-8")
LN_LOCAL_BALANCE_BTC=$(printf %.8f\\n "$((LN_LOCAL_BALANCE))e-8")
LN_REMOTE_BALANCE_BTC=$(printf %.8f\\n "$((LN_REMOTE_BALANCE))e-8")
LN_TOTAL_BALANCE_BTC=$(printf %.8f\\n "$((LN_TOTAL_BALANCE))e-8")

##############################################################################
# PRINT
##############################################################################

echo -e "\n${YELLOW}LN BALANCE${RESET}"
echo -e "LOCAL             REMOTE            TOTAL           "
echo -e "----------------  ----------------  ----------------"
echo -e "$(printf %11s "$LN_LOCAL_BALANCE") sats  $(printf %11s "$LN_REMOTE_BALANCE") sats  $(printf %11s $LN_TOTAL_BALANCE) sats"
echo -e "$(printf %11s "$LN_LOCAL_BALANCE_BTC") BTC   $(printf %11s "$LN_REMOTE_BALANCE_BTC") BTC   $(printf %11s "$LN_TOTAL_BALANCE_BTC") BTC"
echo -e "$(printf %11s $LN_LOCAL_BALANCE_PERCENTAGE) %     $(printf %11s $LN_REMOTE_BALANCE_PERCENTAGE) %     $(printf %11s $TOTAL_BALANCE_PERCENTAGE) %"

echo -e "\n${YELLOW}ON-CHAIN BALANCE${RESET}"
echo -e "CONFIRMED         UNCONFIRMED       TOTAL           "
echo -e "----------------  ----------------  ----------------"
echo -e "$(printf %11s "$ONCHAIN_FUNDS_CONFIRMED") sats  $(printf %11s "$ONCHAIN_FUNDS_UNCONFIRMED") sats  $(printf %11s "$ONCHAIN_FUNDS_TOTAL") sats"
echo -e "$(printf %11s "$ONCHAIN_FUNDS_CONFIRMED_BTC") BTC   $(printf %11s "$ONCHAIN_FUNDS_UNCONFIRMED_BTC") BTC   $(printf %11s "$ONCHAIN_FUNDS_TOTAL_BTC") BTC"
echo -e "$(printf %11s $ONCHAIN_FUNDS_CONFIRMED_PERCENTAGE) %     $(printf %11s $ONCHAIN_FUNDS_UNCONFIRMED_PERCENTAGE) %     $(printf %11s $TOTAL_BALANCE_PERCENTAGE) %"

echo -e "\n${YELLOW}OWNED BALANCE [LN + ON-CHAIN]${RESET}"
echo -e "$(printf %11s "$TOTAL_BALANCE") sats"
echo -e "$(printf %11s "$TOTAL_BALANCE_BTC") BTC"
echo -e ""

echo -e "\n${YELLOW}AUDIT${RESET}"
echo -e "---------------------------------------------"
echo -e "ON-CHAIN CONFIRMED           $(printf %10s "$ONCHAIN_FUNDS_CONFIRMED") sats"
echo -e "ON-CHAIN UNCONFIRMED         $(printf %10s "$ONCHAIN_FUNDS_UNCONFIRMED") sats"
echo -e "ON-CHAIN FEES                ${RED}$(printf %10s "-$ONCHAIN_TX_FEES")${RESET} sats"
echo -e "---------------------------------------------"
echo -e "LN LOCAL BALANCE             $(printf %10s "$LN_LOCAL_BALANCE") sats"
echo -e "LN LOCKED IN COMMIT FEES     $(printf %10s "$LN_COMMIT_FEES") sats"
echo -e "LN INVOICES (RECEIVED)       $(printf %10s "$LN_INVOICES") sats"
echo -e "LN PAYMENTS (PAID)           $(printf %10s "-$LN_PAYMENTS") sats"
echo -e "LN PAYMENTS FEES             $(printf %10s "-$LN_PAYMENTS_FEES") sats"
echo -e "LN EARNED (FORWARD) FEES     ${GREEN}$(printf %10s $LN_EARNED_FEES_IN_SATS)${RESET} sats"
echo -e "---------------------------------------------"

if [ $PROFIT_AND_LOSS -gt 0 ]; then
  COLORED_PNL=${GREEN}$(printf %10s "$PROFIT_AND_LOSS")${RESET}
else
  COLORED_PNL=${RED}$(printf %10s "$PROFIT_AND_LOSS")${RESET}
fi

echo -e "${YELLOW}PROFIT AND LOSS${RESET}              $COLORED_PNL sats"
echo -e "---------------------------------------------"
echo -e "CONTROL SUM\e[0;36m*\e[0m                 $(printf %10s $CONTROL_SUM) sats"
echo -e "LN SPEND                     $(printf %10s $LN_SPEND) sats"
echo -e ""
echo -e "\e[0;36m* CONTROL SUM is supposed to match amount"
echo -e "  of funds that had been put onto this node"
echo -e "  (can be off few sats due rounding).\e[0m"
echo -e ""
