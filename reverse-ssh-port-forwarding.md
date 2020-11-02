# Reverse SSH Port Forwarding for your Bitcoin full node
As of this writing, it is still recommended to connect your LND instance to a full node that is **not** pruned. Fortunately [it looks like](https://twitter.com/roasbeef/status/1319715126761566208) this is about to change soon!

However, as this is still not the case and you might not be willing to spend a whole lot of money on a server just to keep the whole Bitcoin Blockchain for your LND node this here could be a quick fix until we get support for pruned full nodes. Caveat: You need a full node somewhere else, maybe on your home computer or even better, on a dedicated Bitcoin node device.

The [idea](https://twitter.com/gcomxx/status/1322144085839355904) is to use that full node that's placed somewhere within your private network to connect to your LND node, which is installed on a server.

While this setup should work on every Linux, this setup is based on a [RaspiBlitz](https://github.com/rootzoll/raspiblitz)-based full node, as this is what I'm using. Also, I'm positive that such a scheme would work for Lightning Nodes based on implementations other than LND, like c-lightning. But I don't have any experience with that whatsoever.

### Caution
I'm by no means an expert in this field. In fact, I'm just a fool with a tool. What I'm describing here works, but it might not be the best way to do things.
For everyone who's smarter than me, your PRs are more than welcome!

### Advantages
- You fully own your full node, as you should. Remember: Not your keys, not your Bitcoin. Not your node, not your rules.
- You save your server [more than 300 GB](https://blockchair.com/bitcoin/charts/blockchain-size) of disk space

### Disadvantages
- Reliabality: You should make sure that your full node is running and connected to your server at all times. Short downtimes are negligible, long downtimes expose your funds to great danger!
- Professionality: This is a hack. It's not who you should run your lightning node if it's a significant one.
- Your wife doesn't like computers that are always on in her living room and even worse if they have a noisy cooling system.

## The setup

### SSH settings
Login to your RaspiBlitz (the device where your full node is running).

Edit your SSH config
```console
vim /home/admin/.ssh/config
```

Add the following lines
```console
Host lightning-server
   Hostname your-server-domain or IP
   User the-user-you-login-on-your-server-with
```

Check if the settings are correct
```console
ssh lightning-server
```
At this step you'll probably be asked whether the fingerprint of your server is okay or not. Use this opportunity to accept it now. If you have never accepted it, you will get problems later on, that are difficult to spot.

Copy your RaspiBlitz's public key into the servers `authorized_keys` directory. This will allow you to make password-less ssh connections.
```console
ssh-copy-id lightning-server
```
### Install bitcoin-cli on the server
In order to test whether you can access the full node later on, it might make sense to install the `bitcoin-cli` on the server. [Here](https://stadicus.github.io/RaspiBolt/raspibolt_30_bitcoin.html#installation) is a documentation for that, but for this purpose you only need to install the `bitcoin-cli` under `/usr/local/bin`, you don't need `bitcoind`. Also make sure to choose the right package for your CPU architecture. On this page, only the chapter *Installation* is relevant for you.

Furthermore you should add a configuration file on your server, so `bitcoin-cli` knows where to connect to
```console
vim ~/.bitcoin/bitcoin.conf
```
Add the following content, replacing the user and the password such that they fit the settings on the RaspiBlitz (`/home/admin/.bitcoin/bitcoin.conf`)
```console
# RPC
rpcuser=raspibolt
rpcpassword=v3ry-s3cr3t
rpcport=8332
```

### Reverse SSH tunneling
Now you [should be able to expose](https://www.howtoforge.com/reverse-ssh-tunneling) the Bitcoin full node towards the server by running the following line on your RaspiBlitz:
```console 
ssh -R 8332:127.0.0.1:8332 lightning-node
```
You could test whether this works on the server, by running `bitcoin-cli getblockchaininfo`. But while this works, it is not enough for us, we want to automate things. Also, port 8332 is not enough for LND. It also requires `zmqpubrawblock` (28332) and `zmqpubrawtx` (28333).

### Reverse SSH tunneling with autossh

For some reason, people on the internet mostly seem to agree, that the tool `autossh` seems to do the job better than `ssh` itself. Okay, we'll go with it. So if `autossh` is not installed on your full node yet, now is the time to install it.

Create a shell file somewhere (e.g. /home/admin/reverseSSH.sh) with the following content:
```console
#!/bin/bash

sleep 60 # wait until RaspiBlitz is ready

autossh -M 0 -f -N -R 8332:127.0.0.1:8332 cj
autossh -M 0 -f -N -R 28332:127.0.0.1:28332 cj
autossh -M 0 -f -N -R 28333:127.0.0.1:28333 cj
``` 

Explanation:
`-M 0` means *no monitoring*
`-f` means *run in background*
`-N` means *don't execute anything on the server*

#### Make sure the file is executable
Run the follwing command (on your full node device):
```console
sudo chmod +x /home/admin/reverseSSH.sh
```
**Caution**
If you use a RaspiBlitz as your full node like I do, be aware that the external HDD is mounted in a way that does not allow anything to be executed directly from the HDD. So make sure that you store this file somewhere on SD card (but also be aware that the next time you flash your SD card this script will be cleared too).

#### Run autossh at startup
Run `crontab -e` and add the following line:
```console
@reboot /home/admin/reverseSSH.sh
```

Now restart your RaspiBlitz and check on your server if everything works as desired:
```console
bitcoin-cli getblockchaininfo
```

#### Configure LND
On the server, make sure LND is configured correctly either by configuring your lnd.conf or by adding the following parameters when starting LND:
```console
lnd
--bitcoin.active \
--bitcoin.mainnet \
--bitcoin.node=bitcoind \
--bitcoind.rpchost=127.0.0.1 \
--bitcoind.rpcuser=raspibolt \
--bitcoind.rpcpass=v3ry-s3cr3t \
--bitcoind.zmqpubrawblock=tcp://127.0.0.1:28332 \
--bitcoind.zmqpubrawtx=tcp://127.0.0.1:28333 
```

Now restart your server or just LND and you should be connected to the full node. Test it as follows (you may need to unlock it):
```console
lncli getinfo
```

## You made it!
![You are amazing](https://media.giphy.com/media/fW4tuIxD2dqTTePxCD/giphy.gif)

