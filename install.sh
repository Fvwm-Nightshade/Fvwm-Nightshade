#!/bin/bash
#-----------------------------------------------------------------------
# File:		install.sh
# Version:	0.1.0
# Licence: 	GPL 2
#
# Description:	install script for Fvwm-Nightshade
#
# Author:	Thomas Funk <t.funk@web.de>	
# Created:	06/10/2012
# Changed:	
#-----------------------------------------------------------------------
installer_version=0.1
nightshade_version=`grep ns_version config |sed q |cut -d" " -f3`
apps2install=''
timer=0.3

function clear
{
    local CLEAR=''

    type -p clear >/dev/null && CLEAR=$(exec clear)
    [[ -z $CLEAR ]] && type -p tput >/dev/null && CLEAR=$(exec tput clear)
    [[ -z $CLEAR ]] && CLEAR=$'\e[H\e[2J'

    echo -en "$CLEAR"
}

function checkRoot
{
if [ "$(whoami)" != "root" ];
then
    echo -e "Script must be run with root privilegs! Exiting ...\n"
    exit
fi
}

function search_app
{
    package=''
    if [ "$2" == "" ]
    then
	package=$1
    else
	package=$2
    fi
			
    if [ "$2" == "" ]
    then
	printf "search for %-30s" $1
    else
	printf "search for %-30s" $2
    fi

    sleep $timer
    
    if [ `which $1` ]
    then
	echo -e "found"
    else
	echo -e "not found"
	if [ "$apps2install" == '' ]
	then
	    apps2install=$package
	else
	    apps2install = ${apps2install}' '${package}
	fi
    fi

}

function search_fvwm
{
    fvwm=`which fvwm`
    
    if [ "$fvwm" == "" ]
    then
	search_app fvwm
    else
	version=`$fvwm -V |cut -d" " -f2 |sed q`
	major1=`echo $version |cut -d"." -f1`
	major2=`echo $version |cut -d"." -f2`
	minor=`echo $version |cut -d"." -f2`
	wrong=0
	if [ $major1 -gt 1 ]
	then
	    if [ $major2 -gt 5 ]
	    then
		if [ $minor -gt 2 ]
		then
		    wrong=1
		fi
	    fi
	fi

	string='Fvwm_>=_2.6.3'
	echo -n "search for Fvwm >= 2.6.3                 "
	sleep $timer
	if [ $wrong -eq 0 ]
	then
	    echo -e "not found"
	else
	    echo -e "found"
	fi
    fi
}

function search_py_module
{
    module_found=`python -c "import $1" 2>/dev/null && echo "1"`
    printf "search for %-30s" $2
    sleep $timer
    if [ "$module_found" == "" ]
    then
	echo -e "not found"
    else
	echo -e "found"
    fi	
}

########################################################################
#                           M A I N
########################################################################

clear
echo ''
echo '             _____________________________ '
echo '            / ___________________________/ '
echo '           / /_   ___      ______ ___'
echo '          / __/| / / | /| / / __ `__ \   ___'
echo '         / / | |/ /| |/ |/ / / / / / /  /__/'
echo '        /_/  |___/ |__/|__/_/ /_/ /_/ '
echo ''
echo '       _   ___        __    __       __              __    '
echo '      / | / (_)____ _/ /_  / /______/ /_  ____ _____/ /___ '
echo '     /  |/ / // __ `/ __ \/ __/ ___/ __ \/ __ `/ __  // _ \'
echo '    / /|  / // /_/ / / / / /_(__  ) / / / /_/ / /_/ //  __/'
echo '   /_/ |_/_/ \__, /_/ /_/\__/____/_/ /_/\__,_/\__,_/ \___/ '
echo '            /____/                                         '
echo ''
echo "         Install script for Fvwm-Nightshade V $nightshade_version"
echo ''
echo '------------------------------------------------------------------'
echo ''
echo ""

#=======================================================================
# Installing Nightshade
#=======================================================================

echo "FIRST step: installing Fvwm-Nightshade"
echo "--------------------------------------"
sleep 1

# rename .fvwm if exist
if [ -d ${HOME}/.fvwm ]
then
    echo -n "rename ${HOME}/.fvwm/ ... "
    mv ${HOME}/.fvwm ${HOME}/fvwm_orig_`date +%Y%m%d%H%M`
    sleep $timer
    echo -e "done."
fi

# create new fvwm home
echo -n "create new fvwm home ... "
mkdir ${HOME}/.fvwm
sleep $timer
echo -e "done."

# copy all to the right place
echo -n "copy Nightshade files to ${HOME}/.fvwm/ ... "
cp -r * ${HOME}/.fvwm/

# delete all Changelog files and install.sh
cd ${HOME}/.fvwm/
for file in `find . -name Changelog_*`
do
    rm $file
done
rm install.sh
rm ToDo
cd - > /dev/null

# create wallpaper dir and move wallpapers
mkdir ${HOME}/.fvwm/wallpapers
mv ${HOME}/.fvwm/artwork/wp_* ${HOME}/.fvwm/wallpapers/

sleep $timer
echo -e "done.\n"

#=======================================================================
# Search for applications needed for full functionality
#=======================================================================

echo -e "\nSECOND step: checking programs which should be installed"
echo    "----------------------------------------------------------"
sleep 1

echo -e "\nRequired:"
echo "---------"
sleep 1
# fvwm
search_fvwm
# python module xdg
search_py_module xdg python-xdg
# xterm
search_app xterm
# xclock
search_app xclock
# xscreensaver-command
search_app xscreensaver-command xscreensaver
# Esetroot
search_app Esetroot eterm
# import
search_app import imagemagick
# stalonetray
search_app stalonetray

echo -e "\nRecommended:"
echo "--------------------"
sleep 1
# volumeicon
search_app volumeicon
# nm-applet
search_app nm-applet network-manager-gnome

echo -e "\nOptional but useful:"
echo "--------------------"
sleep 1
# fdpowermon
search_app fdpowermon
# bluetooth-applet
search_app bluetooth-applet gnome-bluetooth
# pm-is-supported
search_app pm-is-supported pm-utils
# lxappearance
search_app lxappearance
# qtconfig-qt3
search_app qtconfig-qt3 qtconfig-qt3
# qt4-qtconfig
search_app qtconfig-qt4 qtconfig-qt4

echo -e "\nTHIRD step: What YOU should do:"
echo "-------------------------------"
sleep 1
echo "-> Please install the \"not found\" packages before starting Fvwm-Nightshade."
echo "-> Also add \"$HOME/.fvwm/bin\" to your PATH variable.\n"
echo -e "\nThanks for installing Fvwm-Nightshade :-)\n"
exit 0



