#!/bin/bash
### ****************************************************************************
###
### AWS/EC2 specific host changes
###
### ****************************************************************************

# Change hostname
sudo apt-get install cloud-utils --assume-yes
ec2metadata --instance-id | sudo tee /etc/hostname
sudo mv /etc/hosts /etc/hosts.old
echo -e "# host name\n$(ec2metadata --local-ipv4) $(ec2metadata --instance-id).aws $(ec2metadata --instance-id)" | sudo tee /etc/hosts
echo -e "127.0.0.1 $(ec2metadata --instance-id)\n\n# localhost\n127.0.0.1 localhost.localdomain" | sudo tee -a /etc/hosts
sudo cat /etc/hosts.old | sudo tee -a /etc/hosts
sudo rm /etc/hosts.old
sudo hostname -b -F /etc/hostname

# Set name of CLOUD specific profile changes (found in config/profile)
touch /var/tmp/server-build/cloudprofile
echo 73-cloud-prompt.sh >> /var/tmp/server-build/cloudprofile

# Set name of AWS specific profile changes (found in config/profile)
echo 72-aws-profile.sh >> /var/tmp/server-build/cloudprofile

# Add server verion/distribution details
echo 71-set-distro.sh >> /var/tmp/server-build/cloudprofile

# Set ssh public key to use
echo aws_openleaf_keypairA > /var/tmp/server-build/sshkey

# Link /mnt (EBS volume) to /data if it exists, otherwise just create /data
mount | grep --quiet 'on /mnt type ext3 (rw)' && sudo ln -s /mnt /data || sudo mkdir /data