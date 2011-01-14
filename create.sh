#!/bin/bash
function pause(){
    read -p "Press any key to continue."
}

echo ~~~~~ \*nix Bukkit Plugin Generator by sli ~~~~~

read -p "Enter your name: " USERNAME
read -p "Enter your plugin's name: " PLUGINNAME

echo -n "Generating plugin..."

BLOCKLISTENER=BlockListener.java
YBLOCKLISTENER=${PLUGINNAME}BlockListener.java

PLAYERLISTENER=PlayerListener.java
YPLAYERLISTENER=${PLUGINNAME}PlayerListener.java 

PLUGINYML=plugin.yml

PLUGIN=YPlugin.java
YPLUGIN=${PLUGINNAME}.java
ENDPATH=${PLUGINNAME}/com/bukkit/${USERNAME}/${PLUGINNAME}

mkdir -p $ENDPATH
cd $ENDPATH

#touch ${PLUGINNAME}.java
#touch $YBLOCKLISTENER
#touch ${YPLAYERLISTENER}.java

cd ../../../../

touch $PLUGINYML

cd ../files/

cp $PLUGINYML ../${PLUGINNAME}/plugin.yml
cp $BLOCKLISTENER ../${ENDPATH}/$YBLOCKLISTENER
cp $PLAYERLISTENER ../${ENDPATH}/$YPLAYERLISTENER
cp $PLUGIN ../${ENDPATH}/${PLUGINNAME}.java

echo "Done!"