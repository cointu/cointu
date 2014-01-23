which mksquashfs > /dev/null
if [ $? -eq 1 ] ; then 
  echo "mksquashfs not found, please install before running this build script."
  exit 1
fi

which mkisofs > /dev/null
if [ $? -eq 1 ]; then
  echo "mkisofs not found, please install."
  exit 1
fi
