sudo add-apt-repository ppa:jre-phoenix/ppa --yes > /dev/null
sudo apt-get update > /dev/null 
# Since PeerGuardian uses debconf to configure boot options post install
# so set debconf to noninteractive
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' -f -q -y install pgld pglcmd pglgui
which pgld > /dev/null
if [ $? -ne 0 ] ; then
  exit 1
fi
which pglcmd > /dev/null
if [ $? -ne 0 ] ; then
  exit 1
fi
which pglgui > /dev/null
exit $?
