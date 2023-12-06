#!/bin/bash

#replaces sshd_config file with edited file (line 34: PermitRootLogin yes, line 58: PasswordAuthentication no)
cp sshd_config /etc/ssh/sshd_config
