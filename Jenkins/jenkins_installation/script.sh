#!/bin/bash
sudo apt-get update 
sudo apt-get install python-pip -y
sudo apt-get install ansible -y 
sudo ansible-pull -U git@github.com:myantsevich/ansible.git --key-file ~/id_rsa --checkout jenkins -o --accept-host-key --tags jenkins
