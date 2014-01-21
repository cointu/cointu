mount -t proc none /proc
mount -t sysfs none /sys
export HOME=/root
export PACKAGES="/tmp/packages"


## Purge unnecessary packages
export PURGE=`cat $PACKAGES/purge.list`
echo "Purging unneeded packages"
sudo apt-get purge $PURGE --assume-yes 

## Install new packages
if $UPDATE_APT ; then
  echo "Adding universe apt repo..."
  sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe multiverse" 
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

## Clean up
echo "Cleaning up.."
echo "apt-get clean.."
sudo apt-get clean 
echo "apt-get autoremove"
sudo apt-get autoremove 
echo "Removing tmp files"
sudo rm -rf /tmp/*
sudo rm -f /etc/hosts /etc/resolv.conf

## Unmount proc, sys
sudo umount /proc || sudo umount -lf /proc
sudo umount /sys || sudo umount -lf /sys
