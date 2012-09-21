#-----------------------------------------------------------------------
# File:         Makefile
# Version:      1.0.2
# Licence:      GPL 2
# 
# Description:  Makefile to install, uninstall Fvwm-Nightshade and create
#               a dist package
# 
# Author:       Thomas Funk <t.funk@web.de>     
# Created:      09/08/2012
# Changed:      09/22/2012
#-----------------------------------------------------------------------

package 	= fvwm-nightshade
version 	= $(shell grep ns_version fvwm-nightshade/config |sed q |cut -d' ' -f3)
tarname 	= $(package)
distdir 	= ../$(tarname)-$(version)

prefix 		?= /usr/local
exec_prefix 	= $(prefix)
bindir 		= $(exec_prefix)/bin
datadir 	=  $(prefix)/share
mandir 		= $(prefix)/man
man1dir 	= $(mandir)/man1
docdir 		= $(datadir)/doc

pkgdatadir 	= $(datadir)/$(package)
pkgdocdir 	= $(docdir)/$(package)

fns_executables = $(shell ls -1 bin)
fns_manpages 	= $(shell ls -1 man)
fns_fvwmscripts = $(shell ls -1 fvwm)

fvwm_path	?= /usr/share/fvwm

all:
	@echo "There is nothing to compile."


dist: $(distdir).tar.gz

$(distdir).tar.gz: FORCE $(distdir)
	tar chof - $(distdir) |gzip -9 -c > $(distdir).tar.gz
	rm -rf $(distdir)

$(distdir):
	mkdir -p $(distdir)
	cp -r * $(distdir)
	
FORCE:
	-rm $(distdir).tar.gz &> /dev/null
	-rm -rf $(distdir) &> /dev/null

distcheck: $(distdir).tar.gz
	gzip -cd $+ | tar xvf -
	rm -rf $(distdir)
	@echo "*** Package $(distdir).tar.gz ready for distribution."

install: 
	echo "Installing fvwm-nightshade $(version) to $(prefix)"
	echo "-> install all executables"
	install -d $(bindir)
	install -m 755 bin/* $(bindir)
	
	echo "-> install login file"
	install -d $(datadir)/xsessions
	install -m 644 system/fvwm-nightshade.desktop /usr/share/xsessions/
	
	echo "-> install fvwm-nightshade system files"
	install -d $(datadir)
	cp -r $(package) $(pkgdatadir)

	echo "-> install documentation"
	install -d $(pkgdocdir)
	cp -r doc/* $(pkgdocdir)
	install -m 644 AUTHORS ChangeLog COPYING README INSTALL $(pkgdocdir)
	cp -r templates $(pkgdocdir)

	echo "-> install fvwm scripts"
	if test -d "$(fvwm_path)"; then \
	  install -m 644 fvwm/*  $(fvwm_path); \
	else \
	  echo "Fvwm isn't installed in $(fvwm_path)"; \
	  echo "Please set fvwm_path=<path_to_fvwm> and rerun make install."; \
	  exit 2; \
	fi

	echo "-> install manpages"
	#install -d -m 644 man/* $(man1dir)

	echo "Fvwm-Nightshade is installed. Thanks."
	
uninstall:
	echo "uninstall previous version of Fvwm-Nightshade"
	echo "-> uninstall executables"
	for file in $(fns_executabels) ; do \
	  rm -f $(bindir)/$$file; \
	done

	echo "-> uninstall login file"
	-rm /usr/share/xsessions/fvwm-nightshade.desktop

	echo "-> uninstall fvwm-nightshade system files"
	-rm -r $(pkgdatadir)
	
	echo "-> uninstall documentation"
	-rm -r $(pkgdocdir)

	echo "-> uninstall fvwm scripts"
	if test -d "$(fvwm_path)"; then \
	  for file in $(fns_fvwmscripts) ; do \
	    rm -f $(fvwm_path)/$$file; \
	  done; \
	else \
	  echo "Fvwm isn't installed in $(fvwm_path)"; \
	  echo "Please set fvwm_path=<path_to_fvwm> and rerun make uninstall."; \
	  exit 2; \
	fi
	
	echo "-> uninstall manpages"
	#for file in $(fns_manpages) ; do \
	#  -rm $(man1dir)/$$file; done

	echo "Fvwm-Nightshade is now removed. Only ~/.fvwm-nightshade exists."
	echo "If you don't need it anymore remove it by hand."
	
.PHONY: FORCE dist distcheck install uninstall
.SILENT: install uninstall
	
