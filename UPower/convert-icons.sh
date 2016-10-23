#!/bin/bash

THEME_DIR="/usr/share/icons"
THEME_NAMES="Faenza,Faenza-Dark,Faenza-Darker,Faenza-Darkest"
THEME_SIZES="scalable,96,64,48,32,24,22,16"
FORCE=false # delete already existing linked icons, set on false for partial updates

declare -A ICONS
# Xfce
ICONS["xfce4-power-manager-settings"]="/apps/%size/gnome-power-manager"
# Xfce Power Manager 1.6....
ICONS["battery-empty-charging"]="/status/%size/gpm-primary-000-charging"
ICONS["battery-caution-charging"]="/status/%size/gpm-primary-000-charging"
ICONS["battery-low-charging"]="/status/%size/gpm-primary-020-charging"
ICONS["battery-mid-charging"]="/status/%size/gpm-primary-040-charging"
ICONS["battery-good-charging"]="/status/%size/gpm-primary-060-charging"
ICONS["battery-high-charging"]="/status/%size/gpm-primary-080-charging"
ICONS["battery-full-charging"]="/status/%size/gpm-primary-100-charging"
ICONS["battery-full-charged"]="/status/%size/gpm-primary-charged"
#ICONS["ac-adapter"]="/status/%size/gpm-primary-000-charging"
ICONS["ac-adapter"]="/status/%size/gpm-primary-charged"
ICONS["battery-missing"]="/status/%size/gpm-primary-missing"
ICONS["battery-empty"]="/status/%size/gpm-primary-000"
ICONS["battery-caution"]="/status/%size/gpm-primary-000"
ICONS["battery-low"]="/status/%size/gpm-primary-020"
ICONS["battery-mid"]="/status/%size/gpm-primary-040"
ICONS["battery-good"]="/status/%size/gpm-primary-060"
ICONS["battery-high"]="/status/%size/gpm-primary-080"
ICONS["battery-full"]="/status/%size/gpm-primary-100"
declare -A FAIL
declare -A DONE
for icon in ${!ICONS[@]}
do
	IMG_DIR=$(dirname "${ICONS[${icon}]}")
	IMG_SRC=$(basename "${ICONS[${icon}]}")
	for size in ${THEME_SIZES//,/ }
	do
		IMG_PATH="${IMG_DIR/\%size/$size}"           # replace %size in img path

		if [ $size = "scalable" ]; then
			IMG_EXT="svg"
		else
			IMG_EXT="png"
		fi

		for name in ${THEME_NAMES//,/ }
		do
			THEME_PATH="$THEME_DIR/$name"
			IMG_ORIG="${THEME_PATH}${IMG_PATH}/$IMG_SRC.$IMG_EXT"
			IMG_NEW="${THEME_PATH}${IMG_PATH}/$icon.$IMG_EXT"
			
			if [ ! -f "$IMG_ORIG" ]; then
				FAIL["$icon.$IMG_EXT"]="$IMG_ORIG"
			else
				if [[ -f "$IMG_NEW" ]]; then
					if $FORCE; then
					    gksu "rm $IMG_NEW" # delete old icon we want replace below
					else
						continue
					fi
				fi
	        	gksu "ln -s $IMG_ORIG $IMG_NEW"
	        	DONE["$icon.$IMG_EXT"]="$IMG_ORIG"
			fi
		done
	done
done

if [ ${#FAIL[@]} -gt 0 ]; then
    echo "/!\ ${#FAIL[@]} icon(s) can NOT being linked:"
    for icon in ${!FAIL[@]}
    do
        echo "> ${icon} -> ${FAIL[${icon}]}" 
    done
    echo "Anyway..."
fi

if [ ${#DONE[@]} -gt 0 ]; then
    echo ">** ${#DONE[@]} icon(s) has been SUCCESSFULLY linked:"
    for icon in ${!DONE[@]}
    do
        echo "> ${icon} -> ${DONE[${icon}]}" 
    done
fi

for name in ${THEME_NAMES//,/ }
do
	THEME_PATH="$THEME_DIR/$name"
	echo "> updating $name icon theme ($THEME_PATH)..."
	gksu gtk-update-icon-cache "$THEME_PATH"
done

echo "END."

exit
