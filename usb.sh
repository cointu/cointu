## Get CLI options
## -i iso file
## -p partitoin to install iso to
while getopts i:p: opt; do
  case $opt in
    i)
      ISO=$OPTARG
      ;;
    p)
      PARTITION=$OPTARG
      ;;
  esac
done
shift $((OPTIND - 1))

if [ -z $ISO ] ; then
  echo "Must specify -i parameter"
  exit 1
fi

if [ -z $PARTITION ] ; then
  echo "Must specify -p parameter (partition). example: /dev/sdf1"
  exit 1
fi

MOUNTPOINT=`mount | grep $PARTITION | awk '{ print $3 }'`
echo "Cleaning $MOUNTPOINT"
sudo rm $MOUNTPOINT/* -rf
sudo rm $MOUNTPOINT/.* -rf
echo "Installing $ISO to $PARTITION using unetbootin"
sudo unetbootin lang=en method=diskimage isofile=$ISO installtype=USB targetdrive=$PARTITION autoinstall=yes
