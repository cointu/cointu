## Constants
tmp=".tmp"
src="$tmp/src"
live="$tmp/live"
custom="$tmp/custom"
verifyIso=true
copySrc=true
iso='ubuntu-13.10-desktop-i386.iso'
isoUrl="http://releases.ubuntu.com/saucy/ubuntu-13.10-desktop-i386.iso"
sha256Url="http://releases.ubuntu.com/saucy/SHA256SUMS"

## Get CLI options
## -s do not verify iso integrity
while getopts ":sc" opt; do
  case $opt in
    s)
      verifyIso=false
      ;;
    c)
      copySrc=false
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

## Download ubuntu-13.10-desktop-i386.iso
if ! [ -e "$iso" ] ; then 
  wget "$isoUrl" -O $iso
fi

## Ensure integrity of iso with sha256sum
if $verifyIso ; then
  if [ -z "$validsha256" ] ; then
    echo "Getting checksum from $sha256Url"
    validsha256=`curl -s $sha256Url | grep $iso | awk '{ print $1 }'`
  fi
  echo "Checking sum.."
  computedsha256=`sha256sum $iso | awk '{print $1}'`
  if [ "$validsha256" != "$computedsha256" ]
  then
    echo "$iso failed to match sha256sum. Computed: $computedsha256 - Valid: $validsha256"
    exit 1
  fi
  echo "Checksum passed"
fi
 

## Directory Setup
mkdir -p $tmp $live $live/squashfs $src $custom $tmp/squashfs

## Prepare for customization
echo "Mounting source iso $iso to $src"
sudo mount -o loop $iso $src
echo "rsync $src into $live"
rsync --exclude=/casper/filesystem.squashfs -a $src $live
sudo modprobe squashfs
echo "Mounting squashfs"
sudo mount -t squashfs -o loop $src/casper/filesystem.squashfs $live/squashfs
if $copySrc ; then
  echo "Copying squashfs into $custom ..."
  sudo cp -a $live/squashfs/* $custom
fi


## Enable guest distro network access
echo "Copy network access files into guest"
sudo cp /etc/resolv.conf /etc/hosts $custom/etc

## Customize guest distro 
sudo cp purge_packages $custom/tmp
echo "Chrooting into guest"
sudo chroot $custom /bin/bash -x << 'ENDCUSTOM'
mount -t proc none /proc
mount -t sysfs none /sys
export HOME=/root
export PURGE_PACKAGES=`cat /tmp/purge_packages | grep -v "#"`
sudo apt-get purge $PURGE_PACKAGES --assume-yes
ENDCUSTOM
