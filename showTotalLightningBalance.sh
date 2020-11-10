#!/bin/bash

##############################################################################
# COLORING
##############################################################################

YELLOW=`tput setaf 3`
RESET=`tput sgr0`

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

ONCHAIN_FUNDS_CONFIRMED=$(lncli walletbalance | jq -r '.confirmed_balance')
ONCHAIN_FUNDS_UNCONFIRMED=$(lncli walletbalance | jq -r '.unconfirmed_balance')
ONCHAIN_FUNDS_TOTAL=$(lncli walletbalance | jq -r '.total_balance')

ONCHAIN_FUNDS_CONFIRMED_BTC=$(printf %.3f\\n "$(($ONCHAIN_FUNDS_CONFIRMED))e-8")
ONCHAIN_FUNDS_UNCONFIRMED_BTC=$(printf %.3f\\n "$(($ONCHAIN_FUNDS_UNCONFIRMED))e-8")
ONCHAIN_FUNDS_TOTAL_BTC=$(printf %.3f\\n "$(($ONCHAIN_FUNDS_TOTAL))e-8")

LN_LOCAL_BALANCE_PERCENTAGE=$((100 * $LN_LOCAL_BALANCE / $LN_TOTAL_BALANCE))
LN_REMOTE_BALANCE_PERCENTAGE=$((100 * $LN_REMOTE_BALANCE / $LN_TOTAL_BALANCE))
TOTAL_BALANCE_PERCENTAGE=100

ONCHAIN_FUNDS_CONFIRMED_PERCENTAGE=$((100 * $ONCHAIN_FUNDS_CONFIRMED / $ONCHAIN_FUNDS_TOTAL))
ONCHAIN_FUNDS_UNCONFIRMED_PERCENTAGE=$((100 * $ONCHAIN_FUNDS_UNCONFIRMED / $ONCHAIN_FUNDS_TOTAL))

TOTAL_BALANCE=$((LN_LOCAL_BALANCE + ONCHAIN_FUNDS_TOTAL))
LN_IN_AND_OUT=$((LN_INVOICES + LN_PAYMENTS + LN_PAYMENTS_FEES))

# This should be amount of funds put into cleared of paid/recieved LN payments
CONTROL_SUM=$((TOTAL_BALANCE + LN_COMMIT_FEES - LN_IN_AND_OUT))

##############################################################################
# Sats to BTC 
##############################################################################

CONTROL_SUM_BTC=$(printf %.3f\\n "$(($CONTROL_SUM))e-8")
TOTAL_BALANCE_BTC=$(printf %.3f\\n "$(($TOTAL_BALANCE))e-8")
LN_LOCAL_BALANCE_BTC=$(printf %.3f\\n "$(($LN_LOCAL_BALANCE))e-8")
LN_REMOTE_BALANCE_BTC=$(printf %.3f\\n "$(($LN_REMOTE_BALANCE))e-8")
LN_TOTAL_BALANCE_BTC=$(printf %.3f\\n "$(($LN_TOTAL_BALANCE))e-8")
LN_INVOICES_BTC=$(printf %.3f\\n "$(($LN_INVOICES))e-8")
LN_COMMIT_FEES_BTC=$(printf %.3f\\n "$(($LN_COMMIT_FEES))e-8")
LN_PAYMENTS_BTC=$(printf %.3f\\n "$(($LN_PAYMENTS))e-8")
LN_PAYMENTS_FEES_BTC=$(printf %.3f\\n "$(($LN_PAYMENTS_FEES))e-8")

##############################################################################
# PRINT 
##############################################################################

# turn '0 sats' into '0.000 sats' to keep table nicely formatted
if [ $LN_LOCAL_BALANCE -eq 0 ]; then
    LN_LOCAL_BALANCE="0.000"
fi
if [ $LN_REMOTE_BALANCE -eq 0 ]; then
    LN_REMOTE_BALANCE="0.000"
fi
if [ $LN_COMMIT_FEES -eq 0 ]; then
    LN_COMMIT_FEES="0.000"
fi
if [ $LN_INVOICES -eq 0 ]; then
    LN_INVOICES="0.000"
fi
if [ $LN_PAYMENTS -eq 0 ]; then
    LN_PAYMENTS="0.000"
fi
if [ $LN_PAYMENTS_FEES -eq 0 ]; then
    LN_PAYMENTS_FEES="0.000"
fi
if [ $ONCHAIN_FUNDS_CONFIRMED -eq 0 ]; then
    ONCHAIN_FUNDS_CONFIRMED="0.000"
fi
if [ $ONCHAIN_FUNDS_UNCONFIRMED -eq 0 ]; then
    ONCHAIN_FUNDS_UNCONFIRMED="0.000"
fi

echo -e "\n${YELLOW}LN BALANCE${RESET}"
echo -e "LOCAL\t\tREMOTE\t\tTOTAL"
echo -e "--------------\t---------------\t---------------"
echo -e "$LN_LOCAL_BALANCE sats\t$LN_REMOTE_BALANCE sats\t$LN_TOTAL_BALANCE sats"
echo -e "$LN_LOCAL_BALANCE_BTC BTC\t$LN_REMOTE_BALANCE_BTC BTC\t$LN_TOTAL_BALANCE_BTC BTC"
echo -e "$LN_LOCAL_BALANCE_PERCENTAGE%\t\t$LN_REMOTE_BALANCE_PERCENTAGE%\t\t$TOTAL_BALANCE_PERCENTAGE%"

echo -e "\n${YELLOW}ON-CHAIN BALANCE${RESET}"
echo -e "CONFIRMED\tUNCONFIRMED\tTOTAL"
echo -e "--------------\t---------------\t---------------"
echo -e "$ONCHAIN_FUNDS_CONFIRMED sats\t$ONCHAIN_FUNDS_UNCONFIRMED sats\t$ONCHAIN_FUNDS_TOTAL sats"
echo -e "$ONCHAIN_FUNDS_CONFIRMED_BTC BTC\t$ONCHAIN_FUNDS_UNCONFIRMED_BTC BTC\t$ONCHAIN_FUNDS_TOTAL_BTC BTC"
echo -e "$ONCHAIN_FUNDS_CONFIRMED_PERCENTAGE%\t\t$ONCHAIN_FUNDS_UNCONFIRMED_PERCENTAGE%\t\t$TOTAL_BALANCE_PERCENTAGE%"

echo -e "\n${YELLOW}OWNED BALANCE [LN + ON-CHAIN]${RESET}"
echo -e "$TOTAL_BALANCE sats | $TOTAL_BALANCE_BTC BTC\n"


echo -e "${YELLOW}LOCKED IN COMMIT FEES${RESET}\n$LN_COMMIT_FEES sats | $LN_COMMIT_FEES_BTC BTC\n"
echo -e "${YELLOW}INVOICES RECIEVED${RESET}\n$LN_INVOICES sats | $LN_INVOICES_BTC BTC\n"
echo -e "${YELLOW}PAYMENTS PAID (FEES)${RESET}\n$LN_PAYMENTS ($LN_PAYMENTS_FEES) sats | $LN_PAYMENTS_BTC ($LN_PAYMENTS_FEES_BTC) BTC\n"

echo -e "${YELLOW}CONTROL SUM${RESET}"
echo -e "${CONTROL_SUM} sats | ${CONTROL_SUM_BTC} BTC\n"
