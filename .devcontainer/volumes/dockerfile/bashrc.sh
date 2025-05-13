#!/bin/bash

echo "alias ll='ls -al --color'" >> /etc/profile.d/my_aliases.sh
echo "alias l='ls -l --color'" >> /etc/profile.d/my_aliases.sh
echo "alias la='ls -A --color'" >> /etc/profile.d/my_aliases.sh
echo "alias ls='ls -F --color'" >> /etc/profile.d/my_aliases.sh
echo "alias grep='grep --color=auto'" >> /etc/profile.d/my_aliases.sh
# echo "alias vi='vim'" >> /etc/profile.d/my_aliases.sh
# echo "alias vimdiff='vim -d'" >> /etc/profile.d/my_aliases.sh
# echo "alias v='vim'" >> /etc/profile.d/my_aliases.sh

# Kullanıcının bashrc dosyası, alias'ların otomatik yüklenmesi için:
echo 'source /etc/profile.d/my_aliases.sh' >> ~/.bashrc

chmod +x /etc/profile.d/my_aliases.sh
