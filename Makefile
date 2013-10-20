#-----------------------------------------------------------------------
# File:         Makefile
# Version:      2.1.7
# Licence:      GPL 2
# 
# Description:  Makefile to install, uninstall Fvwm-Nightshade and create
#               a dist package
# 
# Author:       Thomas Funk <t.funk@web.de>     
# Created:      09/08/2012
# Changed:      10/13/2013
#-----------------------------------------------------------------------

package 	= fvwm-nightshade
version 	= $(shell grep ns_version fvwm-nightshade/config |sed q |cut -d' ' -f3)
tarname 	= $(package)
distdir 	= ../$(tarname)-$(version)
pkgdir		= ../$(package)
arch: pkgdir = /tmp/$(package)

DESTDIR		?=
deb: DESTDIR = $(pkgdir)

prefix 		?= /usr/local
deb: prefix = /usr
absprefix	= $(abspath $(prefix))

displaymanager ?= yes
local		?= no

pkgprefix	= $(DESTDIR)$(absprefix)
bindir 		= $(pkgprefix)/bin
datadir 	= $(pkgprefix)/share
mandir 		= $(datadir)/man
man1dir 	= $(mandir)/man1
docdir 		= $(datadir)/doc
localedir	= $(datadir)/locale
xdgdir		= $(datadir)/desktop-directories
userdir		= ~
fnsuserdir	= $(userdir)/.$(package)

pkgdatadir 	= $(datadir)/$(package)
pkgdocdir 	= $(docdir)/$(package)

fns_fvwmscripts = $(shell ls -1 fvwm)
fns_executables = $(shell ls -1 bin)
fns_manpages 	= $(shell ls -1 man)
fns_templates 	= $(shell ls -1 templates)
fns_docfiles	= $(shell find doc -type f|cut -d'/' -f 2-)
fns_docdirs		= $(shell find doc/ -type d|sort -r|cut -d'/' -f 2-)
fns_files 		= $(shell find $(package) -type f|cut -d'/' -f 2-)
fns_directories = $(shell find $(package)/ -type d|sort -r|cut -d'/' -f 2-)
fns_mofiles 	= $(shell ls -1 po |grep ".mo")
fns_xdgfiles	= $(shell find system/desktop-directories -type f|cut -d'/' -f 3-)
id				= $(shell id -un)

fvwm_path	?= $(DESTDIR)/usr/share/fvwm

all:
	@echo "There is nothing to compile."

dist: $(distdir).tar.gz

$(distdir).tar.gz: FORCE $(distdir)
	echo "Create dist package ../$(tarname)-$(version)"
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

build-install-list: 
	rm -f ./fns-install_$(version).lst
	echo "Build install list 'fns-install_$(version).lst' for Fvwm-Nightshade $(version)"
	echo "-> FvwmScripts"
	if test -z "$(DESTDIR)"; then \
		if test "$(local)" = "yes"; then \
			for file in $(fns_fvwmscripts); do \
				if test "$${file#*FvwmScript}" != "$$file"; then \
					echo $(fnsuserdir)/scripts/$$file >> ./fns-install_$(version).lst; \
				else \
					echo $(fnsuserdir)/$$file >> ./fns-install_$(version).lst; \
				fi; \
			done; \
		else \
			if test "$(id)" = "root"; then \
				if test -d "$(fvwm_path)"; then \
					for file in $(fns_fvwmscripts); do \
						echo $(fvwm_path)/$$file >> ./fns-install_$(version).lst; \
					done; \
				else \
					echo "Fvwm isn't installed in $(fvwm_path)"; \
					echo "Please set fvwm_path=<path_to_fvwm> and rerun make install."; \
					rm -f ./fns-install_$(version).lst; \
					exit 2; \
				fi; \
			else \
				echo "Can't install FvwmScripts later in $(fvwm_path) because you are not root."; \
				echo "If you want install Fvwm-Nightshade locally use 'local=yes' in the make call."; \
				rm -f ./fns-install_$(version).lst; \
				exit 3; \
			fi; \
		fi; \
	else \
		for file in $(fns_fvwmscripts); do \
			echo $(fvwm_path)/$$file >> ./fns-install_$(version).lst; \
		done; \
	fi

	echo "-> Executables"
	ok=0; \
	slashes=`echo $(bindir) | awk '{print gsub("/","")}'|xargs expr 1 +`; \
	while test "$$slashes" -gt "1"; do \
		part=`echo $(bindir) |cut -d'/' -f-$$slashes`; \
		if test -d "$$part" && test -w "$$part"; then \
			ok=1; \
			break; \
		else \
			slashes=`expr $$slashes - 1`; \
		fi; \
	done; \
	if (test "$(local)" = "yes" && test "$$ok" = "1") || test "$(id)" = "root"; then \
		for file in $(fns_executables); do \
			echo $(bindir)/$$file >> ./fns-install_$(version).lst; \
		done; \
		echo $(bindir) >> ./fns-install_$(version).lst; \
	else \
		echo "Can't install FNS executables later in $(bindir) because you are not root."; \
		echo "If you want install Fvwm-Nightshade locally use 'prefix=<path>' in the make call"; \
		echo "additionally to 'local=yes' you have permissions to install it e.g. ~/local."; \
		rm -f ./fns-install_$(version).lst; \
		exit 3; \
	fi; \

	if test "$(displaymanager)" = "yes" && test "$(id)" = "root"; then \
		echo "-> Login file"; \
		echo /usr/share/xsessions/fvwm-nightshade.desktop >> ./fns-install_$(version).lst; \
	fi

	echo "-> System files"
	for file in $(fns_files); do \
		echo $(pkgdatadir)/$$file >> ./fns-install_$(version).lst; \
	done
	
	echo "-> System directories"
	for directory in $(fns_directories); do \
		echo $(pkgdatadir)/$$directory >> ./fns-install_$(version).lst; \
	done
	echo $(pkgdatadir) >> ./fns-install_$(version).lst
	
	echo "-> Documentation files"
	for file in $(fns_docfiles); do \
		echo $(pkgdocdir)/$$file >> ./fns-install_$(version).lst; \
	done

	echo "-> Readme files"
	for file in AUTHORS ChangeLog COPYING NEWS README INSTALL; do \
		echo $(pkgdocdir)/$$file >> ./fns-install_$(version).lst; \
	done
	echo $(pkgdocdir)/fns-install_$(version).lst >> ./fns-install_$(version).lst
	if test "$(displaymanager)" = "no" || (test "$(local)" = "yes" && test "$(id)" != "root"); then \
		echo $(pkgdocdir)/fvwm-nightshade.desktop-example >> ./fns-install_$(version).lst; \
	fi
	echo "-> Template files"
	for file in $(fns_templates); do \
		echo $(pkgdocdir)/templates/$$file >> ./fns-install_$(version).lst; \
	done
	
	echo "-> Documentation directories"
	for directory in $(fns_docdirs); do \
		echo $(pkgdocdir)/$$directory >> ./fns-install_$(version).lst; \
	done
	echo $(pkgdocdir)/templates >> ./fns-install_$(version).lst;
	echo $(pkgdocdir) >> ./fns-install_$(version).lst
	echo $(docdir) >> ./fns-install_$(version).lst

	echo "-> Manpage files"
	for file in $(fns_manpages); do \
		echo $(man1dir)/$$file >> ./fns-install_$(version).lst; \
	done
	echo $(man1dir) >> ./fns-install_$(version).lst
	echo $(mandir) >> ./fns-install_$(version).lst

	echo "-> Localization files"
	for file in $(fns_mofiles); do \
		basename=$${file%%.*}; \
		extensions=$${file#*.}; \
		lang=$${extensions%%.*}; \
		if test "$(local)" = "yes" && test "$(id)" != "root"; then \
			echo $(fnsuserdir)/locale/$$lang/LC_MESSAGES/$$basename.mo >> ./fns-install_$(version).lst; \
		else \
			echo $(localedir)/$$lang/LC_MESSAGES/$$basename.mo >> ./fns-install_$(version).lst; \
		fi; \
	done

	echo "-> XDG menu files"
	if test "$(local)" = "yes" && test "$(id)" != "root"; then \
		echo $(userdir)/.config/menus/fns-applications.menu >> ./fns-install_$(version).lst; \
	else \
		echo /etc/xdg/menus/fns-applications.menu >> ./fns-install_$(version).lst; \
	fi; \
	
	for file in $(fns_xdgfiles); do \
		echo $(xdgdir)/$$file >> ./fns-install_$(version).lst; \
	done
	echo $(xdgdir) >> ./fns-install_$(version).lst

	echo $(datadir) >> ./fns-install_$(version).lst
	echo $(pkgprefix) >> ./fns-install_$(version).lst

	echo "Done"
	echo

install: build-install-list dist-install

dist-install:
	echo "Installing Fvwm-Nightshade $(version) to $(pkgprefix)"
	echo "-> Install FvwmScripts"
	if test -z "$(DESTDIR)"; then \
		if test "$(local)" = "yes"; then \
			install -d $(fnsuserdir)/scripts; \
			for file in $(fns_fvwmscripts); do \
				if test "$${file#*FvwmScript}" != "$$file"; then \
					install -m 644 fvwm/$$file $(fnsuserdir)/scripts/; \
				else \
					install -m 644 fvwm/$$file $(fnsuserdir); \
				fi; \
			done; \
		else \
			if test "$(id)" = "root"; then \
				if test -d "$(fvwm_path)"; then \
					for file in $(fns_fvwmscripts); do \
						install -m 644 fvwm/$$file  $(fvwm_path); \
					done; \
				else \
					exit 2; \
				fi; \
			else \
				exit 3; \
			fi; \
		fi; \
	else \
		install -d $(fvwm_path); \
		for file in $(fns_fvwmscripts); do \
			install -m 644 fvwm/$$file  $(fvwm_path); \
		done; \
	fi

	echo "-> Install all executables"
	install -d $(bindir)
	for file in $(fns_executables); do \
		install -m 755 bin/$$file $(bindir); \
	done

	if test -n "$(DESTDIR)" || (test "$(displaymanager)" = "yes" && test "$(id)" = "root"); then \
		echo "-> Install login file"; \
		install -d $(DESTDIR)/usr/share/xsessions; \
		install -m 644 system/fvwm-nightshade.desktop $(DESTDIR)/usr/share/xsessions/;\
	fi

	echo "-> Install system files"
	install -d $(datadir)
	cp -r $(package) $(pkgdatadir)
	
	echo "-> Install documentation, Readmes, examples and templates"
	install -d $(pkgdocdir)
	cp -r doc/* $(pkgdocdir)

	for file in AUTHORS ChangeLog COPYING NEWS README INSTALL; do \
		install -m 644 $$file $(pkgdocdir); \
	done

	if test "$(displaymanager)" = "no" || (test "$(local)" = "yes" && test "$(id)" != "root"); then \
		install -m 644 system/fvwm-nightshade.desktop $(pkgdocdir)/fvwm-nightshade.desktop-example; \
	fi
	
	cp -r templates $(pkgdocdir)

	if test -z "$(DESTDIR)"; then \
		install -m 644 fns-install_$(version).lst $(pkgdocdir); \
	fi
	
	echo "-> Install manpage files"
	install -d $(man1dir)
	for file in $(fns_manpages); do \
		install -m 644 man/$$file $(man1dir); \
	done

	echo "-> Install localization files"
	for file in $(fns_mofiles); do \
		basename=$${file%%.*}; \
		extensions=$${file#*.}; \
		lang=$${extensions%%.*}; \
		if test "$(local)" = "yes" && test "$(id)" != "root"; then \
			install -d $(fnsuserdir)/locale/$$lang/LC_MESSAGES; \
			install -m 644 po/$$file $(fnsuserdir)/locale/$$lang/LC_MESSAGES/$$basename.mo; \
		else \
			install -d $(localedir)/$$lang/LC_MESSAGES; \
			install -m 644 po/$$file $(localedir)/$$lang/LC_MESSAGES/$$basename.mo; \
		fi; \
	done

	echo "-> Install XDG menu files"
	if test "$(local)" = "yes" && test "$(id)" != "root"; then \
		install -d $(userdir)/.config/menus; \
		install -m 644 system/fns-applications.menu $(userdir)/.config/menus/; \
	else \
		install -d $(DESTDIR)/etc/xdg/menus; \
		install -m 644 system/fns-applications.menu $(DESTDIR)/etc/xdg/menus/; \
	fi; \
	
	for file in $(fns_xdgfiles); do \
		install -d $(xdgdir); \
		install -m 644 system/desktop-directories/$$file $(xdgdir); \
	done
	
	if test -z "$(DESTDIR)"; then \
		echo "Fvwm-Nightshade $(version) is installed. Enjoy ^^"; \
	fi

uninstall:
	echo "Uninstall previous version of Fvwm-Nightshade"
	if test -f "$(pkgdatadir)/config"; then\
		fns_version=`grep ns_version $(pkgdatadir)/config |sed q |cut -d' ' -f3`; \
		uninst_file=`find $(pkgdocdir)/fns-install_*.lst`; \
		if test -f "$$uninst_file" && test "$$uninst_file" != ''; then \
			inst_fns_version=`find $(pkgdocdir)/fns-install_*.lst |cut -d '_' -f2|sed 's/.lst//'`; \
			if test "$$fns_version" = "$$inst_fns_version"; then \
				echo "Install log version and config version identically: $$fns_version"; \
				echo "Starting with deinstallation ..."; \
				cp $(pkgdocdir)/fns-install_$$inst_fns_version.lst .; \
				echo "copy $(pkgdocdir)/fns-install_$$inst_fns_version.lst to `pwd`"; \
				for path in `cat fns-install_$$inst_fns_version.lst` ; do \
					if test -f "$$path"; then \
						echo "remove file: $$path"; \
						rm -f $$path; \
					elif test -d "$$path"; then \
						echo "remove directory: $$path"; \
						rmdir $$path; \
					else \
						echo "not found: $$path"; \
					fi; \
				done; \
				echo "Fvwm-Nightshade is now removed. Only ~/.fvwm-nightshade exists."; \
				echo "If you don't need it anymore remove it by hand."; \
				exit 0; \
			else \
				echo "Install log ($$inst_fns_version) and config version ($$fns_version) differs!"; \
				echo "Try 'make uninstall-alternative' to remove files/directories otherwise."; \
				echo "But then file/directory fragments can remain."; \
				exit 2; \
			fi; \
		else \
			echo "Can't find fns-install log under $(pkgdocdir)! Wrong installation path."; \
			echo "Please set correct prefix=<other_dir> and rerun make uninstall."; \
			echo "Or use 'make uninstall-alternative' to remove files/directories"; \
			echo "otherwise. But then file/directory fragments can remain."; \
			exit 2; \
		fi; \
	else \
		echo "Can't find config in $(pkgdatadir)! Wrong installation path."; \
		echo "Please set correct prefix=<other_dir> and rerun make uninstall."; \
		exit 2; \
	fi

uninstall-alternative:
	echo "Try to uninstall previous version of Fvwm-Nightshade"
	echo "-> Uninstall FvwmScripts"
	if test -d "$(fvwm_path)"; then \
		for file in $(fns_fvwmscripts) ; do \
			if test -f "$(fvwm_path)/$$file"; then \
				echo "remove $(fvwm_path)/$$file"; \
				rm -f $(fvwm_path)/$$file; \
			fi; \
		done; \
	else \
		echo "Fvwm isn't installed in $(fvwm_path)"; \
		echo "Please set fvwm_path=<path_to_fvwm> and rerun make uninstall."; \
		exit 2; \
	fi
	
	echo "-> Uninstall executables"
	for file in $(fns_executables) ; do \
		if test -f "$(bindir)/$$file"; then \
			echo "remove $(bindir)/$$file"; \
			rm -f $(bindir)/$$file; \
		fi; \
	done

	if test -f "/usr/share/xsessions/fvwm-nightshade.desktop"; then \
		echo "-> Uninstall login file"; \
		echo "remove /usr/share/xsessions/fvwm-nightshade.desktop"; \
		rm -f /usr/share/xsessions/fvwm-nightshade.desktop; \
	fi

	echo "-> Uninstall system files"
	if test -d "$(pkgdatadir)"; then \
		echo "remove $(pkgdatadir) completelly"; \
		rm -rf $(pkgdatadir); \
	fi
	
	echo "-> Uninstall documentation"
	if test -d "$(pkgdocdir)"; then \
		echo "remove $(pkgdocdir) completelly"; \
		rm -rf $(pkgdocdir); \
	fi

	echo "-> Uninstall manpages"
	for file in $(fns_manpages) ; do \
		if test -f "$(man1dir)/$$file"; then \
			echo "remove $(man1dir)/$$file"; \
			rm -f $(man1dir)/$$file; \
		fi; \
	done

	echo "-> Uninstall localization files"
	for file in $(fns_mofiles); do \
		basename=$${file%%.*}; \
		extensions=$${file#*.}; \
		lang=$${extensions%%.*}; \
		if test -f "$(localedir)/$$lang/LC_MESSAGES/$$basename.mo"; then \
			echo "remove $(localedir)/$$lang/LC_MESSAGES/$$basename.mo"; \
			rm -f $(localedir)/$$lang/LC_MESSAGES/$$basename.mo; \
		fi; \
	done

	echo "-> Uninstall XDG menu files"
	if test "$(local)" = "yes" && test "$(id)" != "root"; then \
		if test -f "$(userdir)/.config/menus/fns-applications.menu"; then \
			echo "remove $(userdir)/.config/menus/fns-applications.menu"; \
			rm -f $(userdir)/.config/menus/fns-applications.menu; \
		fi; \
	else \
		if test -f "/etc/xdg/menus/fns-applications.menu"; then \
			echo "remove /etc/xdg/menus/fns-applications.menu"; \
			rm -f /etc/xdg/menus/fns-applications.menu; \
		fi; \
	fi; \
	
	for file in $(fns_xdgfiles); do \
		if test -f "$(xdgdir)/$$file"; then \
			echo "remove $(xdgdir)/$$file"; \
			rm -f $(xdgdir)/$$file; \
		fi; \
	done
	rmdir $(xdgdir)

	echo "Fvwm-Nightshade is now removed (hopefully). Only ~/.fvwm-nightshade exists."
	echo "If you don't need it anymore remove it by hand."

build-deb: 
	echo "Build debian package"
	rm -rf $(pkgdir)
	mkdir -p $(pkgdir)
	mkdir -p $(pkgdir)/DEBIAN
	cp debian/control $(pkgdir)/DEBIAN
	mkdir -p $(pkgdocdir)
	cp debian/copyright $(pkgdocdir)

deb: build-deb dist-install
	sed -i "s/Version:/Version: $(version)/" $(pkgdir)/DEBIAN/control
	sed -i "s/Installed-Size:/Installed-Size: `du -s fvwm-nightshade |cut -f1`/" $(pkgdir)/DEBIAN/control
	dpkg -b $(pkgdir) ../$(package)_$(version)_all.deb
	rm -rf $(pkgdir)
	echo "Done."

prepare-rpm:
	if test "`rpm -q rpm-build|cut -d '-' -f -2`" != "rpm-build"; then \
		echo "rpm-build package isn't installed."; \
		echo "Please install rpm-build and rerun make rpm."; \
		exit 2; \
	else \
		if test ! -f "~/.rpmmacros"; then \
			echo "%_topdir /home/$(id)/redhat" > ~/.rpmmacros; \
		fi; \
		sed -i "s/Version:.*/Version:\t$(version)/" rpm/fvwm-nightshade.spec; \
		srcdir=`rpmbuild --showrc |grep " _topdir" |cut -f2`/SOURCES; \
		mkdir -p $$srcdir; \
		cp $(distdir).tar.gz $$srcdir; \
	fi;

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
	makepkg -s --config arch/makepkg.conf -p $(pkgdir)/PKGBUILD
	rm -f *.xz
	mv $(pkgdir)/*.xz ../
	rm -rf $(pkgdir)

gentoo-prepare: dist
	echo "Create ebuild with current version in name"
	cp gentoo/fvwm-nightshade.ebuild fvwm-nightshade-$(version).ebuild

.PHONY: dist distcheck install uninstall uninstall-alternative deb rpm arch gentoo-prepare
.SILENT: FORCE dist install uninstall build-deb deb rpm prepare-rpm arch prepare-arch build-install-list uninstall-alternative dist-install gentoo-prepare
	
