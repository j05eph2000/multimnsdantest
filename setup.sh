#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your Transcendence  masternodes.  *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [ $DOSETUP = "y" ]  
then
 
apt-get update -y
#DEBIAN_FRONTEND=noninteractive apt-get update 
#DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade
apt install -y software-properties-common 
apt-add-repository -y ppa:bitcoin/bitcoin 
apt-get update -y
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget pwgen curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip lib32stdc++6 lib32z1 libzmq5
apt-get update -y
apt-get upgrade -y



fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
echo "/swapfile none swap sw 0 0" >> /etc/fstab

fi
  #wget https://github.com/wagerr/wagerr/releases/download/v3.0.1/wagerr-3.0.1-x86_64-linux-gnu.tar.gz
  wget https://github.com/dngrcoin/dngrcoin/releases/download/v1.7.3/dngrcoind-for-ubuntu-16.04.tar.gz
  #wget https://github.com/wagerr/Wagerr-Blockchain-Snapshots/releases/download/Block-826819/826819.zip -O bootstrap.zip
  #export fileid=1cCOIb-Xqs_MxsIPiwEAtvQps_6R1Ww13
  #export filename=Streamies-2.0.0-x86_64-pc-linux-gnu.zip
  #wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
  #   | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt

  #wget --load-cookies cookies.txt -O $filename \
  #   'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)

  #export fileid=1q6w9x77bgXNtDaF1acGwYm6IEIEK7eCJ
  #export filename=bootstrap.zip
  #wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- \
  #   | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt

  #wget --load-cookies cookies.txt -O $filename \
  #   'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<confirm.txt)
  tar xvzf dngrcoind-for-ubuntu-16.04.tar.gz
  sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
  sudo apt -y update
  sudo apt -y upgrade
  sudo apt -y install gcc-6

  sudo apt -y install g++-6

  sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6 
  sudo apt -y update
  sudo apt -y upgrade
  
  chmod +x dngrcoind
  chmod +x dngrcoin-cli
  sudo cp  dngrcoind /usr/local/bin
  sudo cp  dngrcoin-cli /usr/local/bin
  rm -rf dngrcoind-for-ubuntu-16.04.tar.gz
  rm -rf dngrcoin-cli
  rm -rf dngrcoind
  rm -rf dngrcoin-tx
  rm -rf dngrcoin-qt
  
  sudo apt install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc


 ## Setup conf
 IP=$(curl -s4 api.ipify.org)
 mkdir -p ~/bin
 echo ""
 echo "Configure your masternodes now!"
 echo "Detecting IP address:$IP"

echo ""
echo "How many nodes do you want to create on this server? [min:1 Max:20]  followed by [ENTER]:"
read MNCOUNT


for i in `seq 1 1 $MNCOUNT`; do
  echo ""
  echo "Enter alias for new node"
  read ALIAS  

  echo ""
  echo "Enter port for node $ALIAS"
  read PORT

  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  RPCPORT=$(($PORT*10))
  echo "The RPC port is $RPCPORT"

  ALIAS=${ALIAS}
  CONF_DIR=~/.dngrcoin_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/dngrcoind_$ALIAS.sh
  echo "dngrcoind -daemon -conf=$CONF_DIR/dngrcoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/dngrcoind_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/dngrcoin-cli_$ALIAS.sh
  echo "dngrcoin-cli -conf=$CONF_DIR/dngrcoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/dngrcoin-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/dngrcoin-tx_$ALIAS.sh
  echo "dngrcoin-tx -conf=$CONF_DIR/dngrcoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/dngrcoin-tx_$ALIAS.sh 
  chmod 755 ~/bin/dngrcoin*.sh

  mkdir -p $CONF_DIR
  #unzip  bootstrap.zip -d $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> dngrcoin.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> dngrcoin.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> dngrcoin.conf_TEMP
  echo "rpcport=$RPCPORT" >> dngrcoin.conf_TEMP
  echo "listen=1" >> dngrcoin.conf_TEMP
  echo "server=1" >> dngrcoin.conf_TEMP
  echo "daemon=1" >> dngrcoin.conf_TEMP
  echo "logtimestamps=1" >> dngrcoin.conf_TEMP
  echo "maxconnections=256" >> dngrcoin.conf_TEMP
  echo "masternode=1" >> dngrcoin.conf_TEMP
  echo "" >> dngrcoin.conf_TEMP

  echo "" >> dngrcoin.conf_TEMP
  echo "port=$PORT" >> dngrcoin.conf_TEMP
  echo "masternodeaddr=$IP:49002" >> dngrcoin.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> dngrcoin.conf_TEMP
  
  
  sudo ufw allow $PORT/tcp

  mv dngrcoin.conf_TEMP $CONF_DIR/dngrcoin.conf
  
  #sh ~/bin/iond_$ALIAS.sh
  
  cat << EOF > /etc/systemd/system/dngrcoin_$ALIAS.service
[Unit]
Description=dngrcoin_$ALIAS service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=/usr/local/bin/dngrcoind -daemon -conf=$CONF_DIR/dngrcoin.conf -datadir=$CONF_DIR
ExecStop=/usr/local/bin/dngrcoin-cli -conf=$CONF_DIR/dngrcoin.conf -datadir=$CONF_DIR stop
Restart=always
PrivateTmp=true
TimeoutStartSec=10m
StartLimitInterval=0
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 10
  systemctl start dngrcoin_$ALIAS.service
  systemctl enable dngrcoin_$ALIAS.service >/dev/null 2>&1
 
  rm -rf setup.sh

  #(crontab -l 2>/dev/null; echo "@reboot sh ~/bin/wagerrd_$ALIAS.sh") | crontab -
#	   (crontab -l 2>/dev/null; echo "@reboot sh /root/bin/wagerrd_$ALIAS.sh") | crontab -
#	   sudo service cron reload
  
done
