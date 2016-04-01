#! /bin/bash

PLUG_DEFAULT_TEXT="PLUGIN-NAME"
PLUG_DEFAULT_CLASS="PluginClassName"
PLUG_NAME=""
PLUG_CLASS_NAME=""

function print_help {
	echo -e "\nHelp:"
	echo -e "\t-n | --name : This will be the name or prefix for plug-in file names."
	echo -e "\t-c | --class : This will be the name of the PHP plug-in class."
	echo -e "\n-u and -c are required."
}

# Letters numbders and underscores only.
function clean_input {
	echo "$1" | sed -e "s/[^0-9A-Za-z_\-]//g"
}

while [[ $# > 1 ]]
do
	key="$1"
	case $key in
		-h|--help)
			print_help
			exit
			;;
		-n|--name)
			PLUG_NAME=$( clean_input "$2" )
			shift # past argument
			;;
		-c|--class)
			PLUG_CLASS_NAME=$( clean_input "$2" )
			shift # past argument
			;;
		*)
			print_help
			exit
			;;
	esac
	shift # past argument or value
done

echo $PLUG_NAME
echo $PLUG_CLASS_NAME

if [ -z "$PLUG_NAME" ] || [ -z "$PLUG_CLASS_NAME" ]; then
	echo "Plug-in name or class name not provided."
	print_help
	exit
fi

PLUG_FILES=$( find . -iname "$PLUG_DEFAULT_TEXT*" )

echo -e "Modifying files:"
for FILE in $PLUG_FILES; do echo -e "\t$FILE"; done;

echo -e "\nNew plugin file prefix: $PLUG_NAME"
echo "New plugin PHP class prefix: $PLUG_CLASS_NAME"
echo -e "\nIs this what you want?"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) echo -e "\nContinuing...\n"; break;;
		No ) echo "Exiting"; exit;;
		* ) exit;;
	esac
done

for FILE in $PLUG_FILES; do
	NEW_FILE=$( echo "$FILE" | sed -e "s/$PLUG_DEFAULT_TEXT/$PLUG_NAME/g" )
	echo "== Modifying file: $FILE =="
	echo -e "\tReplacing text $PLUG_DEFAULT_CLASS with $PLUG_CLASS_NAME"
	echo -e "\tReplacing text $PLUG_DEFAULT_TEXT with $PLUG_NAME"
	echo -e "\tMoving $FILE to $NEW_FILE"
	echo ""
	sed -i "s/$PLUG_DEFAULT_CLASS/$PLUG_CLASS_NAME/g" $FILE
	sed -i "s/$PLUG_DEFAULT_TEXT/$PLUG_NAME/g" $FILE
	mv $FILE $NEW_FILE;
done;

echo "== Modifying file: uninstall.php =="
echo -e "\tReplacing text $PLUG_DEFAULT_CLASS with $PLUG_CLASS_NAME"
sed -i "s/$PLUG_DEFAULT_CLASS/$PLUG_CLASS_NAME/g" uninstall.php

echo -e "\nDone."
