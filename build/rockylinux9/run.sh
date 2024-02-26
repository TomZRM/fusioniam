#!/bin/bash

microdnf update -y
microdnf install yum-utils -y
microdnf install rpm dnf-plugins-core -y
microdnf install glibc-common policycoreutils -y

# powertools has moved to crb in rockylinux 9
#yum-config-manager --set-enabled powertools
dnf config-manager --enable crb

# Requirements for ansible
microdnf -y install \
      initscripts \
      sudo \
      which \
      hostname \
      python3 \
      python3-pip \
      python3-pyyaml \
      iproute

# Set python version for compatibility with ansible
#dnf module -y install python39
#alternatives --set python3 /usr/bin/python3.9
microdnf update -y

pip3 install --upgrade pip
pip3 install ansible-core

useradd fusioniam

# postgresql module needed for lemonldap image
ansible-galaxy collection install community.postgresql -p /usr/share/ansible/collections

microdnf clean all

