# shell script for starting apps automatically which will be found in 
# .autostart
# Copyright (C) 2007 Thomas Funk <t.funk@web.de>
# Version: 2.0
##########################################################################

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
