## Constants
VERSION="0.0.1"
ARCH="i386"
BASE_DIR=$PWD
COINTU="cointu-$VERSION-$ARCH"
COINTU_ISO="$COINTU.iso"

TMP=".tmp"
SRC="$TMP/src"
LIVE="$TMP/live"
CUSTOM="$TMP/custom"
CD="$TMP/cd"
ISO='ubuntu-13.10-desktop-i386.iso'

ISOUrl="http://releases.ubuntu.com/saucy/ubuntu-13.10-desktop-i386.iso"
SHA256URL="http://releases.ubuntu.com/saucy/SHA256SUMS"

## Get CLI options
## -s do not verify ISO integrity
while getopts ":sa" opt; do
  case $opt in
    s)
      SKIPVERIFY=true
      ;;
    a)
      SKIPUPDATE=true
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
if ! $SKIPVERIFY ; then
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
mkdir -p $TMP $CD $LIVE $LIVE/squashfs $SRC $CUSTOM

## Prepare for customization
echo "Mounting source ISO $ISO to $SRC"
sudo mount -o loop $ISO $SRC
echo "Unpacking ISO into $CD This might take a minute."
rsync --exclude="casper/filesystem.squashfs" -a $SRC/ $CD
sudo modprobe squashfs
echo "Mounting squashfs"
sudo mount -t squashfs -o loop $SRC/casper/filesystem.squashfs $LIVE/squashfs
echo "Syncing $LIVE/squashfs with $CUSTOM. This might take a minute."
sudo rsync -a $LIVE/squashfs/ $CUSTOM


## Enable guest distro network access
echo "Copy network access files into guest"
sudo cp /etc/resolv.conf /etc/hosts $CUSTOM/etc

## Customize guest distro 
sudo cp -r packages $CUSTOM/tmp
sudo cp guest.sh $CUSTOM/tmp
echo "Chroot into guest"
sudo chroot $CUSTOM /bin/bash /tmp/guest.sh

## Rebuild filesystem manifest
echo "Rebuilding filesystem manifest.."
sudo chmod +w $CD/casper/filesystem.manifest
sudo chroot $CUSTOM dpkg-query -W --showformat='${Package} ${Version}\n' > $CD/casper/filesystem.manifest
sudo cp $CD/casper/filesystem.manifest $CD/casper/filesystem.manifest-desktop

## Regenerate squashfs
echo "Regenerating squashfs.."
sudo mksquashfs $CUSTOM $CD/casper/filesystem.squashfs
sudo rm -f $CD/md5sum.txt
cd $CD
echo "Regnerating md5sums.."
sudo find . -type f -print0 | xargs -0 md5sum > md5sum.txt
echo "Building iso $COINTU_ISO"
mkisofs -D -r -V "$COINTU" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $BASE_DIR/$COINTU_ISO .
echo "Generating sha256 checksum of $COINTU_ISO"
sha256sum $COINTU_ISO > $BASE_DIR/$COINTU.sha256
