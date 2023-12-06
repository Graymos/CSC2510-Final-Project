###############################
# Author: Grayson Mosley
# Purpose: Sets up passwords, ansible files, and crontabs
# Dependencies: ansible-playbooks/passwdchange.yml, ansible-playbooks/replaceFiles.yml, & bash-scripts/cron-scripts.sh
###############################



#!/bin/bash

if [ ! -d "setup" ]; then
   mkdir setup
fi



## Ask if dev, test, or prod

incorrectinput=1
uservar=""
while [[ $incorrectinput -eq 1 ]]
do
   read -p 'What environment are you running this setup on? (dev, test, prod): ' uservar
   if [[ ${uservar,,} = "dev" || ${uservar,,} = "test" || ${uservar,,} = "prod" ]]; then
      incorrectinput=0
      uservar=${uservar,,}
      echo "$uservar" > setup/uservar
   else
      echo "Incorrect input, try again."
   fi
done


##Setting up fresh ansible files
read -p 'Do you want to replace files? (ansible.cfg and hosts files) (y/n): ' user_yn
if [[ $user_yn = "y" || $user_yn = "Y" ]]; then
   echo "Inside replace"
   cp "replaceFiles/hosts/hosts-$uservar" "/etc/ansible/hosts"
   cp "replaceFiles/ansible.cfg" "/etc/ansible/ansible.cfg"

   #Inputs inputted ips into the hosts files in proper places
   read -p 'Enter ip of Ansible machine you are currently on: ' ansible_ip
   sed -i "46 a\ ${ansible_ip}" /etc/ansible/hosts
   read -p 'Enter ip of the webserver VM1 machine for the environment you selected: ' vm1_ip
   sed -i "50 a\ ${vm1_ip}" /etc/ansible/hosts
   read -p 'Enter ip of the web/database server VM2 machine for the environment you selected: ' vm2_ip
   sed -i "58 a\ ${vm2_ip}" /etc/ansible/hosts

   #Places password that is set for vm1 and vm2 in the hosts file
   pass=`cat "setup/newpass"`
  # sed -n "s/\ ansible_password=*/\ ansible_password=${pass}/" /etc/ansible/hosts
   sed -i "/\ ansible_password=/c\ ansible_password=${pass}" /etc/ansible/hosts
fi



newpass=""
##Setting new root password for machines
read -p 'Do you want to set new root password for all web/database servers in selected environment? (y/n): '  user_yn
if [[ $user_yn = "y" || $user_yn = "Y" ]]; then

   read -p 'New root password for all VM machines (one set in /etc/ansible/hosts file): ' newpass
   echo "${newpass}" > setup/newpass
   ansible-playbook ansible-playbooks/passwdchange.yml > /dev/null 2>&1

   #Places new password that is set for vm1 and vm2 in the hosts file
   pass=`cat "setup/newpass"`
   #sed -n "s/\ ansible_password=*/\ ansible_password=${pass}/" /etc/ansible/hosts
   sed -i "/\ ansible_password=/c\ ansible_password=${pass}" /etc/ansible/hosts
fi

##Setting up cron
#write out current crontab
crontab -l > setup/mycron
#echo new cron into cron fille
pwdpath=`pwd`
cronpath="* * * * * ${pwdpath}/bash-scripts/cron-scripts.sh"

if [[ -z $(grep "${cronpath}" "${pwdpath}/setup/mycron") ]]; then
   echo "$cronpath" >> setup/mycron
   crontab setup/mycron
fi

