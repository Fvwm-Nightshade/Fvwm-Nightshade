#!/bin/bash
#-----------------------------------------------------------------------
# File:		install.sh
# Version:	0.2
# Licence: 	GPL 2
#
# Description:	install script for Fvwm-Nightshade
#
# Author:	Thomas Funk <t.funk@web.de>	
# Created:	06/10/2012
# Changed:	
#-----------------------------------------------------------------------
installer_version=`grep "\# Version\:" install.sh |cut -f2`
nightshade_version=`grep ns_version config |sed q |cut -d" " -f3`
apps2install=''
timer=0.3
step=1
mode=0
logpath=..
homedir=$HOME

function clear
{
    local CLEAR=''

    type -p clear >/dev/null && CLEAR=$(exec clear)
    [[ -z $CLEAR ]] && type -p tput >/dev/null && CLEAR=$(exec tput clear)
    [[ -z $CLEAR ]] && CLEAR=$'\e[H\e[2J'

    echo -en "$CLEAR"
}

function lecho
{
    if [ $# -eq 2 ]
    then
	echo $1 $2 |tee -a ${logpath}/log.txt
    else
	echo $1 |tee -a ${logpath}/log.txt
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
	printf "search for %-30s" $1 |tee -a ${logpath}/log.txt
    else
	printf "search for %-30s" $2 |tee -a ${logpath}/log.txt
    fi

    sleep $timer
    
    if [ `which $1 2> /dev/null` ]
    then
	lecho -e "found"
    else
	lecho -e "not found"
	if [ "$apps2install" == '' ]
	then
	    apps2install=$package
	else
	    apps2install=${apps2install}' '${package}
	fi
    fi

}

function search_fvwm
{
    fvwm=`which fvwm 2> /dev/null`
    
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
		if [ $minor -gt 3 ]
		then
		    wrong=1
		fi
	    fi
	fi

	printf "search for Fvwm >= %-22s" '2.6.4' |tee -a ${logpath}/log.txt
	sleep $timer
	if [ $wrong -eq 0 ]
	then
	    lecho -e "not found"
	else
	    lecho -e "found"
	fi
    fi
}

function search_py_module
{
    module_found=`python -c "import $1" 2>/dev/null && echo "1"`
    printf "search for %-30s" $2 |tee -a ${logpath}/log.txt
    sleep $timer
    if [ "$module_found" == "" ]
    then
	lecho -e "not found"
    else
	lecho -e "found"
    fi	
}

function search_folder
{
    folder_found=`find $1 -name $2`
    printf "search for %-30s" $2 |tee -a ${logpath}/log.txt
    sleep $timer
    if [ "$folder_found" == "" ]
    then
	lecho -e "not found"
    else
	lecho -e "found"
    fi	
}

function ask
{
    select yn in "Yes" "No"; do
	case $yn in
	    Yes ) 
		if [ $step -ne 1 ]
		then
		    step=2
		fi
		break;;
	    No ) 
		exit 1;;
	esac
    done
}

usage="\nUsage: install.sh [option]\n\n \
       -c\t\tcheck installed apps only\n \
       -u\t\tupdate Fvwm-Nightshade. Not implemented yet\n \
       -d\t\tdisable interactive mode\n \
       -l <logpath>\tother save location for log.txt\n \
       -h\t\tprint this help\n"
while getopts "cduvl:h" options; do
  case $options in
    c ) 
	mode=0
	step=2
	;;
    d ) mode=1
	;;
    u ) step=3
	;;
    v ) echo -e "\n Installer version: ${installer_version}\n"
	exit 0
	;;
    l ) if [ "$OPTARG" != "" ]
	then
	    logpath=$OPTARG
	else
	    echo -e "\nMissing argument: logpath\n"
	    exit 1
        fi;;
    h ) echo -e $usage
        exit 0
        ;;
   \? ) echo -e $usage
        exit 1
        ;;
  esac
done

########################################################################
#                           M A I N
########################################################################
rm -f ${logpath}/log.txt

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
echo '     /  |/ / // __ `/ __ \/ __/ ___/ __ \/ __ `/ __  // _ \ '
echo '    / /|  / // /_/ / / / / /_(__  ) / / / /_/ / /_/ //  __/'
echo '   /_/ |_/_/ \__, /_/ /_/\__/____/_/ /_/\__,_/\__,_/ \___/ '
echo '            /____/                                         '
echo ''
echo "         Install script for Fvwm-Nightshade V $nightshade_version"
echo ''
echo '------------------------------------------------------------------'
echo ''
echo ""

echo "This script will install Fvwm-Nightshade into your userhome. If"
echo ".fvwm/ directory exist it will renamed and a new .fvwm will created."
echo "After that it checks which applications are installed needed for "
echo "propper work."
if [ "$logpath" != ".." ]
then
    echo -e "Logpath has changed from user to ${logpath}/log.txt\n" > ${logpath}/log.txt
fi
echo "The complete install process will be written into ${logpath}/log.txt"
sleep 1

#=======================================================================
# Installing Nightshade
#=======================================================================

if [ $mode -eq 0 ]
then
    echo -e "\nContinue?"
    ask
fi

if [ $step -eq 1 ]
then
    lecho -e "\nInstalling Fvwm-Nightshade in your userhome"
    lecho    "---------------------------------------------"
    sleep 1

    # rename .fvwm if exist
    if [ -d ${homedir}/.fvwm ]
    then
	bak_path="${homedir}/fvwm_orig_`date +%Y%m%d%H%M`"
	printf "%-80s" "rename ${homedir}/.fvwm/ to $bak_path" |tee -a ${logpath}/log.txt
	mv ${homedir}/.fvwm $bak_path
	sleep $timer
	lecho -e "done."
    fi

    # create new fvwm home
    printf "%-80s" "create ${homedir}/.fvwm/" |tee -a ${logpath}/log.txt
    mkdir ${homedir}/.fvwm
    sleep $timer
    lecho -e "done."

    # copy all to the right place
    printf "%-80s" "copy Nightshade files to ${homedir}/.fvwm/" |tee -a ${logpath}/log.txt
    cp -r * ${homedir}/.fvwm/


    # delete all Changelog files and install.sh
    cd ${homedir}/.fvwm/
    for file in `find . -name Changelog_*`
    do
	rm $file
    done
    rm install.sh
    rm ToDo
    cd - > /dev/null

    # create wallpaper dir and move wallpapers
    mkdir ${homedir}/.fvwm/wallpapers
    mv ${homedir}/.fvwm/artwork/wp_* ${homedir}/.fvwm/wallpapers/

    sleep $timer
    lecho -e "done.\n"

    step=2
fi

#=======================================================================
# Search for applications needed for full functionality
#=======================================================================

if [ $step -eq 2 ]
then
    lecho -e "\nChecking programs which should be installed"
    lecho    "---------------------------------------------"

    lecho -e "\nRequired:"
    lecho "---------"
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
    # wm-icons
    search_folder /usr/share/icons/ wm-icons

    lecho -e "\nRecommended:"
    lecho "--------------------"
    sleep 1
    # wm-icons !!!!!!
    # volumeicon
    search_app volumeicon
    # nm-applet
    search_app nm-applet network-manager-gnome

    lecho -e "\nOptional but useful:"
    lecho "--------------------"
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
    #suse: qt4config
    search_app qtconfig-qt4 qtconfig-qt4

    lecho -e "\nWhat YOU should do:"
    lecho    "---------------------"
    sleep 1
    lecho "-> Please install the \"not found\" packages before starting Fvwm-Nightshade."
    lecho -e "Remark:\tsome package names differ from the output above. So you have to"
    lecho -e "\tsearch for similar named ones. Sorry for the inconvenience ..."
    lecho "-> Also add \"\${HOME}/.fvwm/bin\" to your PATH variable. Add this to your"
    lecho -e ".profile or .bash_profile:"
    lecho -e "\tPATH=\$PATH:\${HOME}/.fvwm/bin"
    lecho -e "\texport PATH"
    lecho -e "\nThanks for installing Fvwm-Nightshade :-)\n"
fi

exit 0

