#!/bin/bash

# Path to the Git repository
repo_url="https://github.com/ttu-bburchfield/swollenhippofinal.git"

# Directory where the application will be deployed
deploy_dir="/var/www/html"

#Checks if index.html exists, if so removes it out of the way so then swollenhippefinal file will be only thing shown

if [ -f "$deploy_dir/index.html" ]; then
    rm -f "$deploy_dir/index.html"
fi


# Clone or pull the latest changes from the Git repository
if [ -d "$deploy_dir/swollenhippofinal" ]; then
    cd "$deploy_dir/swollenhippofinal"
    (git pull > /dev/null 2>&1) || (git config --global --add safe.directory /var/www/html/swollenhippofinal && git pull > /dev/null 2>&1)
else
    git clone "$repo_url" "$deploy_dir/swollenhippofinal"
fi
systemctl restart apache2
