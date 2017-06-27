#!/usr/bin/env bash
_YELLOW='\033[1;33m' # yellow color
_GREEN='\033[0;32m' # green color
_NC='\033[0m' # no color

printf "PHPQA installer started ...\n";

printf "Step 1: clonning the repository to ${_YELLOW}$HOME/.phpqa/bin/phpqa.sh${_NC}\n";
if [ -d "$HOME/.phpqa" ]; then
    rm -rf $HOME/.phpqa;
fi
git clone git@github.com:herdphp/docker-phpqa.git $HOME/.phpqa;

printf "Step 2: linking ${_YELLOW}phpqa.sh${_NC} to ${_YELLOW}/usr/local/bin/phpqa${_NC} ...\n";
if [ -L "/usr/local/bin/phpqa" ] ; then
    rm /usr/local/bin/phpqa;
fi
ln -s $HOME/.phpqa/bin/phpqa.sh /usr/local/bin/phpqa;

printf "Step 3: applying exec permissions ...\n";
chmod +x /usr/local/bin/phpqa;

printf "${_GREEN}Success! ${_NC}The ${_YELLOW}phpqa${_NC} command was added to your ${_YELLOW}/usr/local/bin${_NC} folder and can be used globally.\n";