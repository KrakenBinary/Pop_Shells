#!/bin/bash

# It is common practice to install these tools on a virtual machine
# I take no credit nor responsibility for any of these applications, how they are used or how they effect your system
# Run with "sudo bash Pop_Shell.sh" (terminal must be open in the same directory as file)
# A new directory "PenTools" will be created in your present working directory (where ever you run this script) for some applications and seclists

set -eu -o pipefail
test $? -eq 0 || exit 1 "You need sudo privilege to run this script"

echo Installing 1337 H4X0R 700L$. . .
sleep 6

# install wireshark
echo -=WireShark=-
apt-get install -y wireshark

# loop to install "ez" packages
echo -=AptTools=-
while read -r p ; do apt-get install -y $p ; done < <(cat << "EOF"
	dirb
	dnsrecon
	gobuster
	hashcat
	iputils-arping
	medusa
	ncat
	ncrack
	nikto
	nmap
	npm
	openvas-scanner
	plocate
	python3-pip
	sqlmap
	tcpdump
	wfuzz
	whois
EOF
)

echo Creating new directory named PenTools for your applications and seclists. . .
sleep 6

# create directory for your new tools
mkdir -v PenTools
cd PenTools

# download common seclists
git clone https://github.com/danielmiessler/SecLists.git

# install bloodhound
echo -=Bloodhound=-
npm install -g electron-packager
git clone https://github.com/BloodHoundAD/Bloodhound
cd Bloodhound
npm install
echo -=BuildLinux=-
npm run build:linux

# install hydra
echo -=Hydra=-
pip install hydra-core --upgrade
apt-get install hydra -y

# install metasploit
echo -=Metasploit=-
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall
./msfinstall
