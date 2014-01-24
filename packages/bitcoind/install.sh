sudo add-apt-repository ppa:bitcoin/bitcoin --yes  > /dev/null
sudo apt-get update -qq > /dev/null
sudo apt-get install bitcoind --yes > /dev/null 
which bitcoind
exit $?
