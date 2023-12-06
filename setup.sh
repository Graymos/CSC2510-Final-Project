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

##Setting new root password for machines
read -p 'New root password for all VM machines (one set in /etc/ansible/hosts file): ' newpass
echo "$newpass" > setup/newpass
ansible-playbook ansible-playbooks/passwdchange.yml > /dev/null 2>&1

##write out current crontab
crontab -l > setup/mycron
#echo new cron into cron fille
pwdpath=`pwd`
cronpath="* * * * * ${pwdpath}/bash-scripts/cron-scripts.sh"

if [[ -z $(grep "${cronpath}" "${pwdpath}/setup/mycron") ]]; then
   echo "$cronpath" >> setup/mycron
   crontab setup/mycron
fi

#Replaces sshd_config on VM1 and VM2
ansible-playbook ansible-playbooks/replaceFiles.yml > /dev/null 2>&1

