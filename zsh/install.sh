#!/bin/bash

echo "Updating yum and installing zsh..."
sudo yum update && sudo yum -y install zsh
echo "install oh my zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
