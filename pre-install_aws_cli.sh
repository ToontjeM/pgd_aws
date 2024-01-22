#!/bin/sh

########################################################################################################################
# Author:      Sergio Romera                                                                                           #
# Date:        15/01/2024                                                                                              #
# Subject:     Install AWS cli                                                                                         #
# Description: Install AWS cli in a VM that will pilot all the deployments in AWS                                      #
########################################################################################################################

# AWS CLI
sudo yum remove awscli

sudo yum install -y unzip jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
mv awscliv2.zip /tmp
cd /tmp 
unzip awscliv2.zip
sudo ./aws/install
/usr/local/bin/aws --version
cd -

# Update AWS CLI
#sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

# AWS CLI auto complete
complete -C '/usr/local/bin/aws_completer' aws

cat >> ~/.bash_profile <<EOF
export PATH=$PATH:/usr/local/bin/
EOF

