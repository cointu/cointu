sudo add-apt-repository ppa:bitcoin/bitcoin --yes  > /dev/null
sudo apt-get update -qq > /dev/null
sudo apt-get install bitcoin-qt -qq > /dev/null
which bitcoin-qt > /dev/null
exit $?
