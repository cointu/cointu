sudo add-apt-repository ppa:jre-phoenix/ppa --yes > /dev/null
sudo apt-get update > /dev/null 
sudo apt-get install pglcmd pglgui --yes --force-yes
which pgld
if [ $? -eq 1 ]; then 
  echo "Install of pgld failed"
  exit 1;
fi

which pglcmd
if [ $? -eq 1 ]; then 
  echo "Install of pgld failed"
  exit 1;
fi

which pglcmd
exit $?
