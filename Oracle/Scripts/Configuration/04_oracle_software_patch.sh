# This patch script should only be used for a clean installation.
# It doesn't patch existing databases.
export PATH=$ORACLE_HOME/OPatch:$PATH

echo "******************************************************************************"
echo "Patch Oracle Software." `date`
echo "******************************************************************************"

cd $PATCH_PATH2
opatch prereq CheckConflictAgainstOHWithDetail -ph ./
opatch apply -silent
