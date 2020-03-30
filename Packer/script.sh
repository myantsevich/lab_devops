#!/bin/bash
sudo apt-get update 
sudo apt-get install pip -y
sudo apt-get install ansible -y 
# gsutil cp gs://fileshare_mary/id_rsa
sudo ansible-pull -U git@github.com:myantsevich/ansible.git --key-file ~/id_rsa --checkout test1 -o --accept-host-key --tags apps
