mount -t proc none /proc
mount -t sysfs none /sys
export HOME=/root
export PACKAGES="/tmp/packages"


## Purge unnecessary packages
export PURGE=`cat $PACKAGES/purge.list`
sudo apt-get purge $PURGE --assume-yes

## Install new packages
if $UPDATE_APT ; then
  sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
  sudo apt-get update
fi
cd $PACKAGES
for package in `ls -d */ | sed 's/\///'` ; do
  echo "Installing $package"
  $package/install.sh
  if [ $? -ne 0 ] ;  then
    echo "$package failed to install"
    exit 1
  fi
done
