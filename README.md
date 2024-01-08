# Proveably Random raffle contract

## About

This code is to create a proveably random smart contract lottery.

## What we want it to do?

1. Users can enter by paying for a ticket
   1. The ticket fees are going to go to the winner during the draw
2. After X period of time the lottery will automatically draw a winner
   1. And This will be done programatically
3. Using Chainlink VRF and Chainlink Automation
   1. Chainlink VRF -> randomness
   2. Chainling Automation -> Time based trigger

## Tests!

1. Write some deploy scripts
2. Write tests
   1. On local chain
   2. On forked testnet
   3. On forked mainnet