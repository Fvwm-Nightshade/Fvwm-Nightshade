#-----------------------------------------------------------------------
# File:         Makefile
# Version:      1.0.7
# Licence:      GPL 2
# 
# Description:  Makefile to install, uninstall Fvwm-Nightshade and create
#               a dist package
# 
# Author:       Thomas Funk <t.funk@web.de>     
# Created:      09/08/2012
# Changed:      12/30/2012
#-----------------------------------------------------------------------

package 	= fvwm-nightshade
version 	= $(shell grep ns_version fvwm-nightshade/config |sed q |cut -d' ' -f3)
tarname 	= $(package)
distdir 	= ../$(tarname)-$(version)
pkgdir		= ../$(package)
arch: pkgdir = /tmp/$(package)
rpm: srcdir = $(shell rpmbuild --showrc |grep " _topdir" |cut -f2)/SOURCES

DESTDIR		?=
deb: DESTDIR = $(pkgdir)

prefix 		?= /usr/local
deb: prefix = /usr

pkgprefix	= $(DESTDIR)$(prefix)
bindir 		= $(pkgprefix)/bin
datadir 	= $(pkgprefix)/share
mandir 		= $(datadir)/man
man1dir 	= $(mandir)/man1
docdir 		= $(datadir)/doc

pkgdatadir 	= $(datadir)/$(package)
pkgdocdir 	= $(docdir)/$(package)

fns_executables = $(shell ls -1 bin)
fns_manpages 	= $(shell ls -1 man)
fns_fvwmscripts = $(shell ls -1 fvwm)

fvwm_path	?= $(DESTDIR)/usr/share/fvwm

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
	echo "Installing fvwm-nightshade $(version) to $(pkgprefix)"
	echo "-> install all executables"
	install -d $(bindir)
	install -m 755 bin/* $(bindir)
	
	echo "-> install login file"
	install -d $(DESTDIR)/usr/share/xsessions
	install -m 644 system/fvwm-nightshade.desktop $(DESTDIR)/usr/share/xsessions/
	
	echo "-> install fvwm-nightshade system files"
	install -d $(datadir)
	cp -r $(package) $(pkgdatadir)

	echo "-> install documentation"
	install -d $(pkgdocdir)
	cp -r doc/* $(pkgdocdir)
	install -m 644 AUTHORS ChangeLog COPYING README INSTALL $(pkgdocdir)
	cp -r templates $(pkgdocdir)

	echo "-> install fvwm scripts"
	if test -z "$(DESTDIR)"; then \
	  if test -d "$(fvwm_path)"; then \
	    install -m 644 fvwm/*  $(fvwm_path); \
	  else \
	    echo "Fvwm isn't installed in $(fvwm_path)"; \
	    echo "Please set fvwm_path=<path_to_fvwm> and rerun make install."; \
	    exit 2; \
	  fi \
	else \
	  install -d $(fvwm_path); \
	  install -m 644 fvwm/*  $(fvwm_path); \
	fi

	echo "-> install manpages"
	install -d $(man1dir)
	install -m 644 man/* $(man1dir)

	if test -z "$(DESTDIR)"; then \
	  echo "Fvwm-Nightshade is installed. Thanks."; \
	fi
	
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
	for file in $(fns_manpages) ; do \
	  rm -f $(man1dir)/$$file; \
	done

	echo "Fvwm-Nightshade is now removed. Only ~/.fvwm-nightshade exists."
	echo "If you don't need it anymore remove it by hand."

build-deb: 
	echo "Build debian package"
	rm -rf $(pkgdir)
	mkdir -p $(pkgdir)
	mkdir -p $(pkgdir)/DEBIAN
	cp debian/control $(pkgdir)/DEBIAN
	mkdir -p $(pkgdocdir)
	cp debian/copyright $(pkgdocdir)
	

deb: build-deb install
	rm $(pkgdocdir)/INSTALL
	sed -i "s/Version:/Version: $(version)/" $(pkgdir)/DEBIAN/control
	sed -i "s/Installed-Size:/Installed-Size: `du -s fvwm-nightshade |cut -f1`/" $(pkgdir)/DEBIAN/control
	dpkg -b $(pkgdir) ../$(package)_$(version)_all.deb
	rm -rf $(pkgdir)
	echo "Done."

prepare-rpm:
	sed -i "s/Version:.*/Version:\t$(version)/" rpm/fvwm-nightshade.spec
	cp $(distdir).tar.gz $(srcdir)

rpm: dist prepare-rpm
	echo "Build rpm package"
	rpmbuild -bb rpm/fvwm-nightshade.spec --clean

prepare-arch: dist
	echo "Build Arch package"
	rm -rf $(pkgdir)
	mkdir -p $(pkgdir)
	cp arch/PKGBUILD_FNS $(pkgdir)/PKGBUILD
	mv $(distdir).tar.gz $(pkgdir)/
	sed -i "s/pkgver=.*/pkgver=$(version)/" $(pkgdir)/PKGBUILD
	sed -i "s#source=.*#source=\"$(package)-$(version).tar.gz\"#" $(pkgdir)/PKGBUILD
	sed -i "s#^  cd \"\$$srcdir/.*#  cd \"\$$srcdir/$(package)-$(version)\"#" $(pkgdir)/PKGBUILD

arch: prepare-arch
	makepkg --config arch/makepkg.conf -p $(pkgdir)/PKGBUILD -g >> $(pkgdir)/PKGBUILD
	makepkg --config arch/makepkg.conf -p $(pkgdir)/PKGBUILD
	rm -f *.xz
	mv $(pkgdir)/*.xz ../
	rm -rf $(pkgdir)
	
	
.PHONY: dist distcheck install uninstall deb rpm arch
.SILENT: FORCE dist install uninstall build-deb deb rpm prepare-rpm arch prepare-arch
	
