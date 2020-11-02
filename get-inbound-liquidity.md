# How to get Inbound Liquidity on LN

There are several ways you can find inbound liquidity on LN.

## 1. Wait

If your node is up 24x7 and you have some outgoing channels, the network will connect to you if you simply wait.

However, it might take a couple of weeks to get a significant amount of incoming liquidity, and ideally you want your outgoing liquidity to match too.

So open a few large channels, and simply wait a few weeks.

## 2. Purchase things or simulate purchasing things with on-chain payouts.

If you open a channel, and spend 50% of the channel capacity on something, perhaps even sending back to your own wallet via a service like
* https://zigzag.io
* https://www.coinplaza.it
* https://lightningconductor.net/invoice

then you could have at least one channel with inbound liquidity, plus the funds to open another channel elsewhere.

```
Step 1: open a channel to provider
Step 2: create a new deposit address to send bitcoin back to
Step 3: perform LN to onchain swap at provider for 50-80% of the channel capacity which you just opened
Step 4: wait 10-15 mins for your funds to arrive
Step 5: open a new channel to a different provider with the returned funds
```

This process could be repeated with several parties, including actual purchases of goods and services, and result in several channels with inbound liquidity as long as the channels remain active. 

## 3. Purchase inbound liquidity

The following services will allow you to purchase incoming liquidity to your node:

### Yalls

[Yalls](https://yalls.org/about/) sells inbound channels

```
Need an inbound channel? $0.45 USD for 2m sat
```

### Bitrefill Thor

[Thor](https://www.bitrefill.com/thor-lightning-network-channels/) sells inbound channels

```
Thor allows you to open private channels with our well-connected Lightning node,
on demand, with custom capacities (300,000 to 16,000,000 sats).

You can pay with any of our supported payment methods: Bitcoin, lightning, your
Coinbase balance, or with any of the 4 other currencies we support!
```

### LNBig

[LNBig openchannel service](https://lnbig.com/#/open-channel) sells inbound channels, first one free

```
We will open only one channel on you. The one node is the one channel. In next time we will run paid service too for more channels for an one unique node. 
```

### PeerNode

[PeerNode](https://peernode.net/) will consider requests for channels and open accordingly. Complete the form to find out.

```
Need an inbound liquidity? Please fill the form below and we will consider to open a channel to your node.
```

### Loop in/out of LN and onchain

[Lightning Loop](https://github.com/lightninglabs/loop) is a non-custodial service offered by Lightning Labs to bridge on-chain and off-chain Bitcoin using submarine swaps.

The service can be used in various situations:
* Acquiring inbound channel liquidity from arbitrary nodes on the Lightning network
* Depositing funds to a Bitcoin on-chain address without closing active channels
* Paying to on-chain fallback addresses in the case of insufficient route liquidity

> Author's note: when time allows a more detailed overview with examples may be provided  

### Market places

[Pool](https://lightning.engineering/pool/) is a non-custodial, peer-to-peer marketplace for Lightning node operators to buy and sell channels.
[Microlancer](https://microlancer.io) has some offerings for opening channels

#### 3rd party examples

* https://reckless.capital/swap

## 4. Open channels with parties who will reciprocate

The following parties will open channels back to you if you open channels to them:

* Singles ads at https://singles.shock.network/
* Advertise your node at https://jolt.market/
* https://lightningpowerusers.com/home/
* https://lightningconductor.net/channels
* https://lightningto.me/ | https://ln2me.com/
* https://ln.zone/

# Other documentation

There are other guides on this topic such as:

* This document itself is a [fork of bretton's work](https://gist.github.com/bretton/53bc511b6fdafef31951199dd25bbf88)
* https://wiki.ion.radar.tech/tutorials/troubleshooting/bootstrapping-channels
* https://lightningwiki.net/index.php/Incoming_liquidity
