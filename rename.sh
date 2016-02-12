#! /bin/bash

PLUG_DEFAULT_TEXT="PLUGIN-NAME"
PLUG_DEFAULT_CLASS="PluginClassName"
PLUG_NAME=$1
PLUG_CLASS_NAME=$2

if [ -z "$PLUG_NAME" ] || [ -z "$PLUG_CLASS_NAME" ]; then
	echo "Expected ./rename {PLUGIN_NAME} {PLUG_CLASS_NAME}"
	exit
fi

PLUG_FILES=$(find . -iname "$PLUG_DEFAULT_TEXT*")

echo -n "Modifying files:"
for FILE in $PLUG_FILES; do echo $FILE; done;

echo "New plugin file prefix: $PLUG_NAME"
echo "New plugin PHP class prefix: $PLUG_CLASS_NAME"
echo -e "\nIs this what you want?"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) echo -e "\nContinuing...\n"; break;;
		No ) echo "Exiting"; exit;;
		* ) exit;;
	esac
done

PLUG_FILES=$(find . -iname "$PLUG_DEFAULT_TEXT*")

for FILE in $PLUG_FILES; do
	NEW_FILE=$( echo "$FILE" | sed -e "s/$PLUG_DEFAULT_TEXT/$PLUG_NAME/g" )
	echo "== Modifying file: $FILE =="
	echo -e "\tReplacing text $PLUG_DEFAULT_CLASS with $PLUG_CLASS_NAME"
	echo -e "\tMoving $FILE to $NEW_FILE"
	echo ""
	sed -i "s/$PLUG_DEFAULT_CLASS/$PLUG_CLASS_NAME/g" $FILE
	mv $FILE $NEW_FILE;
done;
