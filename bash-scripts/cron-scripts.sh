#!/bin/bash
pwdpath=`pwd`

echo ${pwdpath}

ansible-playbook ~/AutoWebApp/ansible-playbooks/vm1-install-nodejs-apache-git.yml > /dev/null 2>&1
ansible-playbook ~/AutoWebApp/ansible-playbooks/vm2-install-nodejs-apache-mariadb-git.yml > /dev/null 2>&1
ansible-playbook ~/AutoWebApp/ansible-playbooks/vm1-vm2-swollenhippo-deploy-apache.yml > /dev/null 2>&1
