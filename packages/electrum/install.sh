echo "Installing electrum dependencies.."
sudo apt-get install python-qt4 python-pip python-slowaes  --assume-yes
echo "Installing electrum.."
sudo pip install "https://download.electrum.org/Electrum-1.9.7.tar.gz#md5=5764f38d6e4bc287a577c8d16e797882" --quiet 
which electrum 
exit $?
