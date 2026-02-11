#!/bin/bash

# It is common practice to install these tools on a virtual machine
# I take no credit nor responsibility for any of these applications, how they are used or how they effect your system
# Run with "sudo bash Pop_Shell.sh" (terminal must be open in the same directory as file)
# A new directory "PenTools" will be created in your present working directory (where ever you run this script) for some applications and seclists

set -eu -o pipefail
test $? -eq 0 || exit 1 "You need sudo privilege to run this script"

echo "Cleanup previous installs? (recommended for clean run) (y/n)"
read -r -p "" cleanup </dev/tty
if [[ "$cleanup" =~ ^[Yy]$ ]]; then
    echo "Cleaning up..."
    rm -rf ~/PenTools
    apt remove --purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y 2>/dev/null || true
    rm -rf /var/lib/docker
    rm -f /etc/apt/sources.list.d/docker.list
    apt autoremove -y
    apt autoclean
    systemctl daemon-reload
	# echo "Cleanup done. Reboot recommended before continuing."
    # read -r -p "Reboot now? (y/n): " reboot_now </dev/tty
    # if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
    #     reboot
    # fi
else
    echo "Skipping cleanup."
fi

echo -=mkdirPenTools=-
cd ~
mkdir -p PenTools
cd PenTools

echo -=UpdatingApt=-
apt-get update


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

echo -=WireShark=-
apt-get install -y wireshark

echo -=SecLists=-
echo "Do you want to install SecLists? (y/n)"
read -r -p "" answer </dev/tty
if [[ "$answer" =~ ^[Yy]$ ]]; then
    git clone https://github.com/danielmiessler/SecLists.git
else
    echo "Skipping SecLists."
fi

echo -=BloodhoundCE=-
echo "Do you want to install Bloodhound? (y/n)"
read -r -p "" answer </dev/tty
if [[ "$answer" =~ ^[Yy]$ ]]; then
	# Install Docker + Compose if not already
	echo "Adding Docker official repo for Compose/Buildx plugins..."
	apt-get update
	apt-get install -y ca-certificates curl gnupg
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	chmod a+r /etc/apt/keyrings/docker.asc
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt-get update
	apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	# Start and enable Docker
	systemctl start docker
	systemctl enable docker

	# Wait a few seconds for daemon to be ready
	sleep 5

	wget https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-linux-amd64.tar.gz
	tar -xvzf bloodhound-cli-linux-amd64.tar.gz
	rm bloodhound-cli-linux-amd64.tar.gz
	usermod -aG docker $USER
	newgrp docker
	./bloodhound-cli install
else
    echo "Skipping Bloodhound."
fi

echo -=Hydra=-
echo "Do you want to install Hydra? (y/n)"
read -r -p "" answer </dev/tty
if [[ "$answer" =~ ^[Yy]$ ]]; then
	apt-get install hydra -y
else
    echo "Skipping hydra."
fi

echo -=Metasploit=-
echo "Do you want to install Metasploit? (y/n)"
read -r -p "" answer </dev/tty
if [[ "$answer" =~ ^[Yy]$ ]]; then
	curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb -o msfinstall
	chmod 755 msfinstall
	./msfinstall
	rm msfinstall
	# Optional but recommended: initialize database
	msfdb init 2>/dev/null || true
else
    echo "Skipping Metasploit."
fi

# ... after all installs ...
echo "-==--==--==--==--==--==--==-"
echo "Post install instructions:"
echo "-==--==--==--==--==--==--==-"
echo "Metasploit installed. Launch with: msfconsole"
echo "Log out and back in NOW for docker group to apply (required for non-sudo docker use)."
echo "BloodHound CE installed via Docker. Access: http://localhost:8080/ui/login"
echo "Check terminal for admin password (or use bloodhound-cli status/logs)."
