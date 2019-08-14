#!/bin/bash
# Author: ValcanK

# This Script was designed to download the correct dependencies for the weapons comp
# it will update and install the correct pacakges, connect you to the range vpn
# and also ask if you would like to stand up a teamserver

# dependency installs
sudo apt-get -y install git
sudo apt-get install openjdk-11-jdk -y
sudo update-java-alternatives -s java-1.11.0-openjdk-amd64
sudo apt-get install openvpn -y
pwd
cd ~/Documents


# Asking the user if they would like to delete their old files
if [ -d "67-CW-Challenge" ]; then
	echo "67 CW Directory exists"
	echo "Would you like to remove and re-clone?(yes/no) "
	read answer
	if [ $answer == 'yes' ]; then
		echo "Removing 67-CW-Challenge Directory"
		sudo rm -rf 67-CW-Challenge
	fi
fi

# Cloning the repo
git clone https://github.com/KevinCooper/67-CW-Challenge.git

cd ~/Documents/67-CW-Challenge
git clone https://github.com/kimocoder/armitage

# unpacking CS
cd ~/Documents/67-CW-Challenge/CobaltStrike
tar zxvf cobaltstrike-trial.tgz
cd ~/Documents/67-CW-Challenge/CobaltStrike/cobaltstrike
pwd

# Asking the user if they would like to stand up a team server

echo "Would you like to set up a team server?(yes/no) "
read teamans
cd ~/Documents/67-CW-Challenge/lab-vpn/
sudo ./connect.sh &
cd ~/Documents/67-CW-Challenge/CobaltStrike/cobaltstrike
IPADDR=$(ifconfig tun0 | grep 'inet' | cut -d: -f2 | awk '{print $2}')
echo $IPaddr
cd ~/Documents/67-CW-Challenge/CobaltStrike/cobaltstrike
if [ $teamans == 'yes' ]; then	
	sudo ./teamserver $IPADDR 33NWSIsTheBest ~/Documents/67-CW-Challenge/CobaltStrike/cobalt.profile &
else
	echo "Starting up CobaltStrike App"
	./cobaltstrike &
fi
