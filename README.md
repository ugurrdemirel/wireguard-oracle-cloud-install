# WireGuard for Oracle Cloud
!!! WARNING !!!
This setup currently isn't working on the latest images provided by Oracle Cloud, check back soon for updates.

Wireguard VPN Setup for Oracle Cloud Instances  
Oracle Cloud instances need some additional configuration to get WireGuard up and running as expected. Here is how we do that:

NOTE: The wireguard kernel mod ships with the latest ubuntu image on Oracle Cloud.

Install dependancies:
```bash
sudo dnf install -y wireguard-tools qrencode
```

Download our scripts:
```bash
sudo cd /etc/wireguard
sudo git clone https://github.com/vaughngx4/wireguard-oracle-cloud-install.git
sudo mv wireguard-oracle-cloud-install/* ./
sudo rm -rf wireguard-oracle-cloud-install
```

Generate the config(follow the prompts, this will not start the server):
```bash
sudo ./wireguard-autoconfig.sh
```

Finally, add a peer and start the server:
```bash
sudo ./add-peer.sh
```

You can use the qr code that is ouput to the terminal or copy the configuration from `/etc/wireguard/peerX`('X' being the peer number)

The `add-peer.sh` script will automatically restart the server to apply changes. To add another peer, simply run the script again.

Peer configs can found in folders inside `/etc/wireguard/` starting with folder name `peer2`(the peer number corresponds with the peer's IP address).

That's it, you can now connect to the vpn using the auto generated configs.
