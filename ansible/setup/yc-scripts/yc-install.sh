#!/bin/bash

curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash -s -- -a
echo 'source /home/admin/yandex-cloud/completion.zsh.inc' >>  ~/.zshrc
source "/home/admin/.bashrc"
