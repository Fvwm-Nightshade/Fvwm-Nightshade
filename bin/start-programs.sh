########################################################################
# File:		start-programs.sh
# Version:	2.0.0
# Licence: 	GPL 2
#
# Description:	shell script for starting apps automatically which will 
#		be found in $FVWM_USERDIR/.autostart
#
# Author:	Thomas Funk <t.funk@web.de>	
# Created:	2007
# Changed:	06/08/2012
########################################################################

# !/bin/bash

# check whether starup file exist
if [ -f ${FVWM_USERDIR}/.autostart ]
then
  # read startup file
  autostart=`cat ${FVWM_USERDIR}/.autostart`
  for program in $autostart
  do
    prog_started=`ps -ef |grep -c $program`
    if [ $prog_started -gt 1 ]
    then
      echo [Autostart]: $program is already started. Skipping. >> ~/.xsession-errors
    else
      echo [Autostart]: $program not started. Will be started now. >> ~/.xsession-errors
      $program &
      sleep 5
		fi
  done
fi
exit 0
