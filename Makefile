#-----------------------------------------------------------------------
# File:         Makefile
# Version:      2.0.0
# Licence:      GPL 2
# 
# Description:  Makefile to install, uninstall Fvwm-Nightshade and create
#               a dist package
# 
# Author:       Thomas Funk <t.funk@web.de>     
# Created:      09/08/2012
# Changed:      06/23/2013
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
localedir	= $(datadir)/locale

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

build-install-list: 
	rm -f ./fns-install_$(version).lst
	echo "Build install list 'fns-install_$(version).lst' for Fvwm-Nightshade $(version)"
	echo "-> FvwmScripts"
	if test -z "$(DESTDIR)"; then \
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
		for file in $(fns_fvwmscripts); do \
			echo $(fvwm_path)/$$file >> ./fns-install_$(version).lst; \
		done; \
	fi

	echo "-> Executables"
	for file in $(fns_executables); do \
		echo $(bindir)/$$file >> ./fns-install_$(version).lst; \
	done

	echo "-> Login file"
	echo /usr/share/xsessions/fvwm-nightshade.desktop >> ./fns-install_$(version).lst

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
	
	echo "-> Documentation directories"
	for directory in $(fns_docdirs); do \
		echo $(pkgdocdir)/$$directory >> ./fns-install_$(version).lst; \
	done
	echo $(pkgdocdir) >> ./fns-install_$(version).lst
	
	echo "-> Template files"
	for file in $(fns_templates); do \
		echo $(pkgdocdir)/templates/$$file >> ./fns-install_$(version).lst; \
	done
	echo $(pkgdocdir)/templates >> ./fns-install_$(version).lst;

	echo "-> Manpage files"
	for file in $(fns_manpages); do \
		echo $(man1dir)/$$file >> ./fns-install_$(version).lst; \
	done

	echo "-> Localization files"
	for file in $(fns_mofiles); do \
		basename=$${file%%.*}; \
		extensions=$${file#*.}; \
		lang=$${extensions%%.*}; \
		echo $(localedir)/$$lang/LC_MESSAGES/$$basename.mo >> ./fns-install_$(version).lst; \
	done

	echo "Done"
	echo
	
install: build-install-list
	echo "Installing Fvwm-Nightshade $(version) to $(pkgprefix)"
	echo "-> Install FvwmScripts"
	if test -z "$(DESTDIR)"; then \
		if test -d "$(fvwm_path)"; then \
			for file in $(fns_fvwmscripts); do \
				install -m 644 fvwm/$$file  $(fvwm_path); \
			done; \
		else \
			echo "Fvwm isn't installed in $(fvwm_path)"; \
			echo "Please set fvwm_path=<path_to_fvwm> and rerun make install."; \
			rm -f ./fns-install_$(version).lst; \
			exit 2; \
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

	echo "-> Install login file"
	install -d $(DESTDIR)/usr/share/xsessions
	install -m 644 system/fvwm-nightshade.desktop $(DESTDIR)/usr/share/xsessions/

	echo "-> Install system files"
	install -d $(datadir)
	cp -r $(package) $(pkgdatadir)
	
	echo "-> Install documentation, Readmes and templates"
	install -d $(pkgdocdir)
	cp -r doc/* $(pkgdocdir)

	for file in AUTHORS ChangeLog COPYING NEWS README INSTALL; do \
		install -m 644 $$file $(pkgdocdir); \
	done
	
	cp -r templates $(pkgdocdir)

	install -m 644 fns-install_$(version).lst $(pkgdocdir)
	
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
		install -d $(localedir)/$$lang/LC_MESSAGES; \
		install -m 644 po/$$file $(localedir)/$$lang/LC_MESSAGES/$$basename.mo; \
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
					if test -e $$path; then \
						rm -f $$path; \
						echo "remove file: $$path"; \
					elif test -d $$path; then \
						rmdir $$path; \
						echo "remove directory: $$path"; \
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
				echo "But then file/directory fragments can be remained."; \
				exit 2; \
			fi; \
		else \
			echo "Can't find fns-install log under $(pkgdocdir)! Wrong installation path."; \
			echo "Please set correct prefix=<other_dir> and rerun make uninstall."; \
			echo "Or use 'make uninstall-alternative' to remove files/directories"; \
			echo "otherwise. But then file/directory fragments can be remained."; \
			exit 2; \
		fi; \
	else \
		echo "Can't find config in $(pkgdatadir)! Wrong installation path."; \
		echo "Please set correct prefix=<other_dir> and rerun make uninstall."; \
		exit 2; \
	fi

dry-uninstall:
	echo "Uninstall previous version of Fvwm-Nightshade - dry run. Nothing happens."
	if test -f "$(pkgdatadir)/config"; then\
		fns_version=`grep ns_version $(pkgdatadir)/config |sed q |cut -d' ' -f3`; \
		uninst_file=`find $(pkgdocdir)/fns-install_*.lst`; \
		if test -f "$$uninst_file" && test "$$uninst_file" != ''; then \
			inst_fns_version=`find $(pkgdocdir)/fns-install_*.lst |cut -d '_' -f2|sed 's/.lst//'`; \
			if test "$$fns_version" = "$$inst_fns_version"; then \
				echo "Install log version and config version identically: $$fns_version"; \
				echo "Starting with deinstallation ..."; \
				echo "copy $(pkgdocdir)/fns-install_$$inst_fns_version.lst to `pwd`"; \
				for path in `cat fns-install_$$inst_fns_version.lst` ; do \
					if test -e $$path; then \
						echo "remove file: $$path"; \
					elif test -d $$path; then \
						echo "remove directory: $$path"; \
					else \
						echo "not found: $$path"; \
					fi; \
				done; \
				echo "Dry run done.."; \
				exit 0; \
			else \
				echo "Install log ($$inst_fns_version) and config version ($$fns_version) differs!"; \
				echo "Try 'make uninstall-alternative' to remove files/directories otherwise."; \
				echo "But then file/directory fragments can be remained."; \
				exit 2; \
			fi; \
		else \
			echo "Can't find fns-install log under $(pkgdocdir)! Wrong installation path."; \
			echo "Please set correct prefix=<other_dir> and rerun make uninstall."; \
			echo "Or use 'make uninstall-alternative' to remove files/directories"; \
			echo "otherwise. But then file/directory fragments can be remained."; \
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
				rm -f $(fvwm_path)/$$file; \
				echo "remove $(fvwm_path)/$$file"; \
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
			rm -f $(bindir)/$$file; \
			echo "remove $(bindir)/$$file"; \
		fi; \
	done

	echo "-> Uninstall login file"
	-rm /usr/share/xsessions/fvwm-nightshade.desktop
	echo "remove /usr/share/xsessions/fvwm-nightshade.desktop"

	echo "-> Uninstall system files"
	if test -d "$(pkgdatadir)"; then \
		-rm -r $(pkgdatadir); \
		echo "remove $(pkgdatadir) completelly"; \
	fi
	
	echo "-> Uninstall documentation"
	if test -d "$(pkgdocdir)"; then \
		-rm -r $(pkgdocdir); \
		echo "remove $(pkgdocdir) completelly"; \
	fi

	echo "-> Uninstall manpages"
	for file in $(fns_manpages) ; do \
		if test -f "$(man1dir)/$$file"; then \
			rm -f $(man1dir)/$$file; \
			echo "remove $(man1dir)/$$file"; \
		fi; \
	done

	echo "-> Uninstall localization files"
	for file in $(fns_mofiles); do \
		basename=$${file%%.*}; \
		extensions=$${file#*.}; \
		lang=$${extensions%%.*}; \
		if test -f "$(localedir)/$$lang/LC_MESSAGES/$$basename.mo"; then \
			rm -f $(localedir)/$$lang/LC_MESSAGES/$$basename.mo; \
			echo "remove $(localedir)/$$lang/LC_MESSAGES/$$basename.mo"; \
		fi; \
	done

	echo "Fvwm-Nightshade is now removed (hopefully). Only ~/.fvwm-nightshade exists."
	echo "If you don't need it anymore remove it by hand."

dry-uninstall-alternative:
	echo "Try to uninstall previous version of Fvwm-Nightshade - dry run. Nothing happens."
	echo "-> Uninstall FvwmScripts"
	if test -d "$(fvwm_path)"; then \
		for file in $(fns_fvwmscripts) ; do \
			if test -f "$(fvwm_path)/$$file"; then \
				echo "remove $(fvwm_path)/$$file"; \
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
		fi; \
	done

	echo "-> Uninstall login file"
	echo "remove /usr/share/xsessions/fvwm-nightshade.desktop"

	echo "-> Uninstall fvwm-nightshade system files"
	if test -d "$(pkgdatadir)"; then \
		echo "remove $(pkgdatadir) completelly"; \
	fi
	
	echo "-> Uninstall documentation"
	if test -d "$(pkgdocdir)"; then \
		echo "remove $(pkgdocdir) completelly"; \
	fi

	echo "-> Uninstall manpages"
	for file in $(fns_manpages) ; do \
		if test -f "$(man1dir)/$$file"; then \
			echo "remove $(man1dir)/$$file"; \
		fi; \
	done

	echo "-> Uninstall localization files"
	for file in $(fns_mofiles); do \
		basename=$${file%%.*}; \
		extensions=$${file#*.}; \
		lang=$${extensions%%.*}; \
		if test -f "$(localedir)/$$lang/LC_MESSAGES/$$basename.mo"; then \
			echo "remove $(localedir)/$$lang/LC_MESSAGES/$$basename.mo"; \
		fi; \
	done

	echo "Dry run done."

build-deb: 
	echo "Build debian package"
	rm -rf $(pkgdir)
	mkdir -p $(pkgdir)
	mkdir -p $(pkgdir)/DEBIAN
	cp debian/control $(pkgdir)/DEBIAN
	mkdir -p $(pkgdocdir)
	cp debian/copyright $(pkgdocdir)

deb: build-deb install
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
	
	
.PHONY: dist distcheck install uninstall dry-uninstall uninstall-alternative dry-uninstall-alternative deb rpm arch
.SILENT: FORCE dist install uninstall build-deb deb rpm prepare-rpm arch prepare-arch build-install-list dry-uninstall uninstall-alternative dry-uninstall-alternative
	
