# Add an empty package install script to the $PACKAGES_DIR directory for install
# Usage ./addPackage.sh <packagename>

PACKAGE_NAME=$1
PACKAGES_DIR="./packages"
INSTALL_BIN="install.sh"
mkdir -p $PACKAGES_DIR/$PACKAGE_NAME
touch $PACKAGES_DIR/$PACKAGE_NAME/install.sh
chmod +x $PACKAGES_DIR/$PACKAGE_NAME/install.sh
exit $?
