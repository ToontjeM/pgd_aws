#!/bin/bash

########################################################################################################################
# Author:      Sergio Romera                                                                                           #
# Date:        15/01/2024                                                                                              #
# Subject:     Install TPA in a VM                                                                                     #
# Description: Install TPA in a VM. This VM willpilot all the deployments in AWS                                       #
########################################################################################################################

if [[ -z "${credentials}" ]]; then
    echo "Please set credentails variable"
else

    # Repo
    curl -1sLf "https://downloads.enterprisedb.com/$credentials/postgres_distributed/setup.rpm.sh" | sudo -E bash

    # TPA
    sudo yum -y install python39 python3-pip epel-release git openvpn patch libselinux-python
    sudo rm /etc/alternatives/python3
    sudo ln /usr/bin/python3.9 /etc/alternatives/python3

    if [ -d $HOME/tpa ]; then
        echo "TPA exists. Removing..."
        sudo rm -rf $HOME/tpa
    fi
    git clone https://github.com/enterprisedb/tpa.git $HOME/tpa
    sudo /home/vagrant/tpa/bin/tpaexec setup --use-2q-ansible

    #yum -y install wget chrony tpaexec tpaexec-dep
    # Config file: /etc/chrony.conf
    sudo systemctl enable --now chronyd
    chronyc sources

    cat >> $HOME/.bash_profile <<EOF
export PATH=$PATH:$HOME/tpa/bin
export EDB_SUBSCRIPTION_TOKEN=${credentials}
EOF

source ~/.bash_profile
tpaexec selftest

fi