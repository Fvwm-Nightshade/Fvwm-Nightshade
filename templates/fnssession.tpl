#!/bin/sh
#-----------------------------------------------------------------------
# File:         .fnssession
# Version:      1.0.0
# Licence:      GPL 2
#
# Description:  This file supersedes ~/.xsession for local installation.
#				Background is that
#				- it's easier for the user (no entries in .profile etc)
#				- it makes no difference whether startx or a display 
#				  manager will be used to start FNS => $PATH and $PERL5LIB
#				  will always set.
#
# Author:       Thomas Funk <t.funk@web.de>    
# Created:      08/21/2012
# Changed:      03/09/2016
#-----------------------------------------------------------------------

localbin=
localperl=

# Local bin path
PATH=$localbin:$PATH

# Local perl lib path
if test -z $PERL5LIB; then
	export PERL5LIB=$localperl
else
	PERL5LIB=$PERL5LIB:$localperl
fi

unset localbin
unset localperl
