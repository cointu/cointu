## Constants
TMP=".tmp"
SRC="$TMP/src"
LIVE="$TMP/live"
CUSTOM="$TMP/custom"
VERIFYISO=true
COPYSRC=true
ISO='ubuntu-13.10-desktop-i386.iso'
ISOUrl="http://releases.ubuntu.com/saucy/ubuntu-13.10-desktop-i386.iso"
SHA256URL="http://releases.ubuntu.com/saucy/SHA256SUMS"

## Get CLI options
## -s do not verify ISO integrity
while getopts ":sca" opt; do
  case $opt in
    s)
      VERIFYISO=false
      ;;
    c)
      COPYSRC=false
      ;;
    a)
      UPDATE_APT=false
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

## Download ubuntu-13.10-desktop-i386.ISO
if ! [ -e "$ISO" ] ; then 
  wget "$ISOUrl" -O $ISO
fi

## Ensure integrity of ISO with sha256sum
if $VERIFYISO ; then
  if [ -z "$VALIDSHA256" ] ; then
    echo "Getting checksum from $SHA256URL"
    VALIDSHA256=`curl -s $SHA256URL | grep $ISO | awk '{ print $1 }'`
  fi
  echo "Checking sum.."
  COMPUTEDSHA256=`sha256sum $ISO | awk '{print $1}'`
  if [ "$VALIDSHA256" != "$COMPUTEDSHA256" ]
  then
    echo "$ISO failed to match sha256sum. Computed: $COMPUTEDSHA256 - Valid: $VALIDSHA256"
    exit 1
  fi
  echo "Checksum passed"
fi
 

## Directory Setup
mkdir -p $TMP $LIVE $LIVE/squashfs $SRC $CUSTOM $TMP/squashfs

## Prepare for CUSTOMization
echo "Mounting source ISO $ISO to $SRC"
sudo mount -o loop $ISO $SRC
echo "rsync $SRC into $LIVE"
rsync --exclude=/casper/filesystem.squashfs -a $SRC $LIVE
sudo modprobe squashfs
echo "Mounting squashfs"
sudo mount -t squashfs -o loop $SRC/casper/filesystem.squashfs $LIVE/squashfs
if $COPYSRC ; then
  echo "Copying squashfs into $CUSTOM ..."
  sudo cp -a $LIVE/squashfs/* $CUSTOM
fi


## Enable guest distro network access
echo "Copy network access files into guest"
sudo cp /etc/resolv.conf /etc/hosts $CUSTOM/etc

## Customize guest distro 
sudo cp -r packages $CUSTOM/tmp
sudo cp guest.sh $CUSTOM/tmp
echo "Chroot into guest"
sudo chroot $CUSTOM /bin/bash /tmp/guest.sh
