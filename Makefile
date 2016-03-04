#-----------------------------------------------------------------------
# File:         Makefile
# Version:      2.4.0
# Licence:      GPL 2
# 
# Description:  Makefile to install, uninstall Fvwm-Nightshade and create
#               a dist package
# 
# Author:       Thomas Funk <t.funk@web.de>     
# Created:      09/08/2012
# Changed:      03/03/2016
#-----------------------------------------------------------------------

package 		= fvwm-nightshade
version 		= $(shell grep ns_version fvwm-nightshade/config |sed q |cut -d' ' -f3)
tarname 		= $(package)
distdir 		= ../$(tarname)-$(version)
pkgdir			= ../$(package)
arch: pkgdir 	= /tmp/$(package)

DESTDIR			?=
deb: DESTDIR 	= $(pkgdir)

prefix 			?= /usr/local
deb: prefix 	= /usr
absprefix		= $(abspath $(prefix))

displaymanager	?= yes
local			?= no
purge			?= no
localperldir	?=

po-file			?=
po-lang			?=

pkgprefix		= $(DESTDIR)$(absprefix)
bindir 			= $(pkgprefix)/bin
datadir 		= $(pkgprefix)/share
mandir 			= $(datadir)/man
man1dir 		= $(mandir)/man1
docdir 			= $(datadir)/doc
localedir		= $(datadir)/locale
xdgdir			= $(datadir)/desktop-directories
themesdir 		= $(datadir)/themes
userdir			= ~
fnsuserdir		= $(userdir)/.$(package)
perlsitedir 	?= $(shell perl -le 'foreach (@INC) {if (m/\/usr\/lib\/.*(site_perl|perl5|vendor_perl)/|m/\/usr\/local\/lib\/.*(site_perl|perl5|vendor_perl)/){print $$_; last;}}')

ifeq ($(local),yes)
  themesdir = $(userdir)/.themes
  ifdef localperldir
    perlsitedir = $(localperldir)
  else
    ifdef PERLLIB
      perlsitedir = $(shell echo $(PERLLIB)|cut -d':' -f1)
    else
      ifdef PERL5LIB
        perlsitedir = $(shell echo $(PERL5LIB)|cut -d':' -f1)
      else
        $(error No local Perl library path is defined! Use 'localperldir=<local_perl_path>' in the make call.)
      endif
    endif
  endif
endif

pkgdatadir 		= $(datadir)/$(package)
pkgdocdir 		= $(docdir)/$(package)

fns_fvwmscripts = $(shell ls -p1 fvwm|grep -v /)
fns_executables = $(shell ls -1 bin)
fns_manpages 	= $(shell ls -1 man)
fns_templates 	= $(shell ls -1 templates)
fns_docfiles	= $(shell find doc -type f|cut -d'/' -f 2-)
fns_docdirs		= $(shell find doc/ -type d|sort -r|cut -d'/' -f 2-)
fns_files 		= $(shell find $(package) -type f|cut -d'/' -f 2-)
fns_directories = $(shell find $(package)/ -type d|sort -r|cut -d'/' -f 2-)
fns_mofiles 	= $(shell ls -1 po |grep ".mo")
fns_languages 	= $(shell ls -1 po |grep ".mo" |cut -d"." -f2 |sort |uniq)
fns_xdgfiles	= $(shell find system/desktop-directories -type f|cut -d'/' -f 3-)
fns_themesfiles	= $(shell find system/themes -type f|cut -d'/' -f 3-)
fns_themesdirs	= $(shell find system/themes/ -type d|sort -r|cut -d'/' -f 3-)
id				= $(shell id -un)
simplegtk2files = $(shell find system/libs -type f|cut -d'/' -f 3-)
simplegtk2dirs	= $(shell find system/libs/ -type d|sort -r|cut -d'/' -f 3-)

fvwm_path		?= $(DESTDIR)/usr/share/fvwm
new_perllibfiles = $(shell find fvwm/perllib -type f|cut -d'/' -f 3-)
perllibdirs		= $(shell find fvwm/perllib/ -type d|sort -r|cut -d'/' -f 3-)

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
	rm -f $(distdir).tar.gz
	rm -rf $(distdir)

distcheck: $(distdir).tar.gz
	gzip -cd $+ | tar xvf -
	rm -rf $(distdir)
	@echo "*** Package $(distdir).tar.gz ready for distribution."

build-install-list: 
	rm -f ./fns-install_$(version).lst
	echo "Building install list 'fns-install_$(version).lst' for Fvwm-Nightshade $(version)"
	echo "-> Fvwm scripts"
	if test -z "$(DESTDIR)"; then \
		if test "$(local)" = "yes"; then \
			for file in $(fns_fvwmscripts); do \
				if test "$${file#*Form}" != "$$file" || test "$${file#*fvwm}" != "$$file"; then \
					echo $(fnsuserdir)/$$file >> ./fns-install_$(version).lst; \
				else \
					echo $(fnsuserdir)/scripts/$$file >> ./fns-install_$(version).lst; \
				fi; \
			done; \
		else \
			if test "$(id)" = "root"; then \
				if test -d "$(fvwm_path)"; then \
					for file in $(fns_fvwmscripts); do \
						echo $(fvwm_path)/$$file >> ./fns-install_$(version).lst; \
					done; \
					for file in $(new_perllibfiles); do \
						echo $(fvwm_path)/$$file >> ./fns-install_$(version).lst; \
					done; \
				else \
					echo "Fvwm isn't installed in $(fvwm_path)"; \
					echo "Please set fvwm_path=<path_to_fvwm> and rerun make install."; \
					rm -f ./fns-install_$(version).lst; \
					exit 2; \
				fi; \
			else \
				echo "Can't install FvwmScripts and new perllib modules later in $(fvwm_path) because you are not root."; \
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
	elif test "$(displaymanager)" = "yes" && test "$(id)" != "root"; then \
		echo "Can't install fvwm-nightshade.desktop in /usr/share/xsessions/ because you are not root."; \
		rm -f ./fns-install_$(version).lst; \
		exit 3; \
	fi

	echo "-> SimpleGtk2 library"
	for file in $(simplegtk2files); do \
		filename=$${file##*/}; \
		dirs=$${file%/*}; \
		if test "$$dirs" != "$$filename"; then \
			echo $(perlsitedir)/$$dirs/$$filename >> ./fns-install_$(version).lst; \
		else \
			echo $(perlsitedir)/$$filename >> ./fns-install_$(version).lst; \
		fi; \
	done; \
	for directory in $(simplegtk2dirs); do \
		echo $(perlsitedir)/$$directory >> ./fns-install_$(version).lst; \
	done

	echo "-> Perllib modules"
	for file in $(new_perllibfiles); do \
		if test "$(id)" = "root"; then \
			echo $(fvwm_path)/perllib/$$file >> ./fns-install_$(version).lst; \
		else \
			echo $(perlsitedir)/$$file >> ./fns-install_$(version).lst; \
		fi; \
	done; \
	if test "$(local)" = "yes"; then \
		for directory in $(perllibdirs); do \
			echo $(perlsitedir)/$$directory >> ./fns-install_$(version).lst; \
		done; \
		echo $(perlsitedir) >> ./fns-install_$(version).lst; \
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
	done; \
	for lang in $(fns_languages); do \
		if test "$(local)" = "yes" && test "$(id)" != "root"; then \
			echo $(fnsuserdir)/locale/$$lang/LC_MESSAGES >> ./fns-install_$(version).lst; \
			echo $(fnsuserdir)/locale/$$lang >> ./fns-install_$(version).lst; \
		else \
			echo $(localedir)/$$lang/LC_MESSAGES >> ./fns-install_$(version).lst; \
			echo $(localedir)/$$lang >> ./fns-install_$(version).lst; \
		fi; \
	done; \
	if test "$(local)" = "yes" && test "$(id)" != "root"; then \
		echo $(fnsuserdir)/locale >> ./fns-install_$(version).lst; \
	else \
		echo $(localedir) >> ./fns-install_$(version).lst; \
	fi

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

	echo "-> Gtk themes"
	for file in $(fns_themesfiles); do \
		echo $(themesdir)/$$file >> ./fns-install_$(version).lst; \
	done
	for directory in $(fns_themesdirs); do \
		echo $(themesdir)/$$directory >> ./fns-install_$(version).lst; \
	done
	echo $(themesdir) >> ./fns-install_$(version).lst

	echo $(datadir) >> ./fns-install_$(version).lst
	echo $(pkgprefix) >> ./fns-install_$(version).lst

	echo "Done"
	echo

install: build-install-list dist-install

dist-install:
	echo "Installing Fvwm-Nightshade $(version) to $(pkgprefix)"
	echo "-> Install FvwmScripts and perllib modules"
	if test -z "$(DESTDIR)"; then \
		if test "$(local)" = "yes"; then \
			install -d $(fnsuserdir)/scripts; \
			for file in $(fns_fvwmscripts); do \
				if test "$${file#*Form}" != "$$file" || test "$${file#*fvwm}" != "$$file"; then \
					install -m 644 fvwm/$$file $(fnsuserdir); \
				else \
					install -m 644 fvwm/$$file $(fnsuserdir)/scripts/; \
				fi; \
			done; \
		else \
			if test "$(id)" = "root"; then \
				if test -d "$(fvwm_path)"; then \
					for file in $(fns_fvwmscripts); do \
						install -m 644 fvwm/$$file  $(fvwm_path); \
					done; \
					for file in $(new_perllibfiles); do \
						if test -f "fvwm/$$file"; then \
							install -m 644 fvwm/$$file  $(fvwm_path)/$$file; \
						else \
							if test -d "fvwm/$$file"; then \
								install -d $(fvwm_path)/$$file; \
							fi; \
						fi; \
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

	echo "-> Install SimpleGtk2 library"
	install -d $(DESTDIR)$(perlsitedir); \
	for file in $(simplegtk2files); do \
		filename=$${file##*/}; \
		dirs=$${file%/*}; \
		if test "$$dirs" != "$$filename"; then \
			install -d $(DESTDIR)$(perlsitedir)/$$dirs/; \
			install -m 644 system/libs/$$dirs/$$filename $(DESTDIR)$(perlsitedir)/$$dirs/; \
		else \
			install -d $(DESTDIR)$(perlsitedir); \
			install -m 644 system/libs/$$filename $(DESTDIR)$(perlsitedir)/; \
		fi; \
	done; \

	echo "-> Install Perllib modules"
	for file in $(new_perllibfiles); do \
		dirs=$${file%/*}; \
		if test "$(id)" = "root" || test -n "$(DESTDIR)"; then \
			install -d $(fvwm_path)/perllib/$$dirs/; \
			install -m 644 fvwm/perllib/$$file $(fvwm_path)/perllib/$$dirs/; \
		else \
			install -d $(DESTDIR)$(perlsitedir)/$$dirs/; \
			install -m 644 fvwm/perllib/$$file $(DESTDIR)$(perlsitedir)/$$dirs/; \
		fi; \
	done; \

	echo "-> Install system files"
	install -d $(datadir)
	cp -r $(package) $(pkgdatadir)
	
	if test -z "$(DESTDIR)"; then \
		echo "-> Register apps at polkit"; \
		for app in cpufreq-set cpupower; do \
			if ! test -z `which $$app`; then \
				echo "   $$app"; \
				bin/fns-poladd $$app; \
			fi; \
		done; \
	fi
	
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
	
	install -d $(xdgdir)
	for file in $(fns_xdgfiles); do \
		install -m 644 system/desktop-directories/$$file $(xdgdir); \
	done
	
	echo "-> Install Gtk themes"
	install -d $(themesdir)
	cp -r system/themes/* $(themesdir)

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
				echo "-> Unregister apps at polkit"; \
				for app in "cpufreq-set" "cpupower"; do \
					if ! test -z `which $$app`; then \
						alreadyHere=`cat /usr/share/polkit-1/actions/org.freedesktop.policykit.pkexec.policy | grep "$$app"`; \
						if [ "$$alreadyHere" != "" ]; then \
							echo "   $$app"; \
							bin/fns-poladd -r "$$app"; \
						fi; \
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
	echo "Try to remove previous version of Fvwm-Nightshade"
	if test "$(local)" = "yes"; then \
		if test "$(purge)" = "yes"; then \
			echo "-> Remove Fvwm Scripts"; \
			for file in $(fns_fvwmscripts); do \
				if test "$${file#*Form}" != "$$file" || test "$${file#*fvwm}" != "$$file"; then \
					echo "removing $(fnsuserdir)/$$file"; \
					rm -f $(fnsuserdir)/$$file; \
				else \
					echo "removing $(fnsuserdir)/scripts/$$file"; \
					rm -f $(fnsuserdir)/scripts/$$file; \
				fi; \
			done; \
			if test -d "$(fnsuserdir)/scripts/"; then \
				echo "removing $(fnsuserdir)/scripts/ if empty"; \
				rmdir $(fnsuserdir)/scripts 2>/dev/null; \
			fi; \
		fi; \
	else \
		echo "-> Remove Fvwm Scripts"; \
		if test -d "$(fvwm_path)"; then \
			for file in $(fns_fvwmscripts); do \
				echo "removing $(fvwm_path)/$$file"; \
				rm -f $(fvwm_path)/$$file; \
			done; \
			for file in $(new_perllibfiles); do \
				echo "removing $(fvwm_path)/$$file"; \
				rm -f $(fvwm_path)/$$file; \
			done; \
		else \
			echo "Fvwm isn't installed in $(fvwm_path)"; \
			echo "Please set fvwm_path=<path_to_fvwm> and rerun make uninstall-alternative."; \
			exit 2; \
		fi; \
	fi; \

	echo "-> Remove executables"
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
			echo "removing $(bindir)/$$file"; \
			rm -f $(bindir)/$$file; \
		done; \
		echo removing $(bindir) if empty; \
		rmdir $(bindir) 2>/dev/null; \
	else \
		echo "Can't remove FNS executables in $(bindir) because you are not root."; \
		echo "If you want to remove a local installation use 'prefix=<path>' in the make call"; \
		echo "additionally to 'local=yes'."; \
		exit 3; \
	fi; \

	if test -f "/usr/share/xsessions/fvwm-nightshade.desktop" && test "$(id)" = "root"; then \
		echo "-> Remove login file"; \
		echo /usr/share/xsessions/fvwm-nightshade.desktop >> ./fns-install_$(version).lst; \
	elif test -f "/usr/share/xsessions/fvwm-nightshade.desktop" && test "$(id)" != "root"; then \
		echo "Can't remove fvwm-nightshade.desktop in /usr/share/xsessions/ because you are not root."; \
		exit 3; \
	fi

	if test -O "$(perlsitedir)"; then \
		echo "-> Remove SimpleGtk2 library"
		for file in $(simplegtk2files); do \
			filename=$${file##*/}; \
			dirs=$${file%/*}; \
			if test "$$dirs" != "$$filename"; then \
				echo "removing $(perlsitedir)/$$dirs/$$filename"; \
				rm -f $(perlsitedir)/$$dirs/$$filename; \
			else \
				echo "removing $(perlsitedir)/$$filename"; \
				rm -f $(perlsitedir)/$$filename; \
			fi; \
		done; \
		for directory in $(simplegtk2dirs); do \
			echo "removing $(perlsitedir)/$$directory if empty"; \
			rmdir $(perlsitedir)/$$directory 2>/dev/null; \
		done; \
	else \
		echo "Can't remove SimpleGtk2 files in $(perlsitedir) because you are not root."; \
		echo "If you want to remove a local installation use 'localperldir=<path>' in the make call"; \
		echo "additionally to 'local=yes'."; \
		exit 3; \
	fi

	echo "-> Remove perllib modules"
	for file in $(new_perllibfiles); do \
		if test "$(id)" = "root"; then \
			echo "removing $(fvwm_path)/perllib/$$file"; \
			rm -f $(fvwm_path)/perllib/$$file; \
		else \
			echo "removing $(perlsitedir)/$$file"; \
			rm -f $(perlsitedir)/$$file; \
		fi; \
	done; \
	if test "$(local)" = "yes"; then \
		for directory in $(perllibdirs); do \
			echo "removing $(perlsitedir)/$$directory if empty"; \
			rmdir $(perlsitedir)/$$directory 2>/dev/null; \
		done; \
		echo "removing $(perlsitedir) if empty"; \
		rmdir $(perlsitedir) 2>/dev/null; \
	fi

	echo "-> Remove system files and directories"
	for file in $(fns_files); do \
		echo "removing $(pkgdatadir)/$$file"; \
		rm -f $(pkgdatadir)/$$file; \
	done
	for directory in $(fns_directories); do \
		echo "removing $(pkgdatadir)/$$directory if empty"; \
		rmdir $(pkgdatadir)/$$directory 2>/dev/null; \
	done
	echo "removing $(pkgdatadir) if empty"
	rmdir $(pkgdatadir) 2>/dev/null
	
	echo "-> Remove documentation files"
	rm -rf $(pkgdocdir)
	rmdir $(docdir) 2>/dev/null

	echo "-> Remove manpage files"
	for file in $(fns_manpages); do \
		echo "removing $(man1dir)/$$file"; \
		rm -f $(man1dir)/$$file; \
	done
	echo "removing $(man1dir) if empty"
	rmdir $(mandir) 2>/dev/null

	echo "-> Removing localization files"
	for file in $(fns_mofiles); do \
		basename=$${file%%.*}; \
		extensions=$${file#*.}; \
		lang=$${extensions%%.*}; \
		if test "$(local)" = "yes" && test "$(id)" != "root"; then \
			if test "purge" = "yes"; then \
				echo "removing $(fnsuserdir)/locale/$$lang/LC_MESSAGES/$$basename.mo"; \
				rm -f $(fnsuserdir)/locale/$$lang/LC_MESSAGES/$$basename.mo; \
				echo "removing $(fnsuserdir)/locale/$$lang if empty"; \
				rmdir $(fnsuserdir)/locale/$$lang/LC_MESSAGES 2>/dev/null; \
				rmdir $(fnsuserdir)/locale/$$lang 2>/dev/null; \
			else \
				echo "Can't remove locales in $(fnsuserdir)/locale/ because purge=yes"; \
				echo "is not set in make call. Remove it by hand please."; \
			fi; \
		else \
			echo "removing $(localedir)/$$lang/LC_MESSAGES/$$basename.mo"; \
			rm -f $(localedir)/$$lang/LC_MESSAGES/$$basename.mo; \
		fi; \
	done
	if test "$(local)" = "yes" && test "purge" = "yes"; then \
		rmdir $(fnsuserdir)/locale 2>/dev/null; \
	fi

	echo "-> Remove XDG menu files"
	if test "$(local)" = "yes" && test "$(id)" != "root"; then \
		echo "removing $(userdir)/.config/menus/fns-applications.menu"; \
		rm -f $(userdir)/.config/menus/fns-applications.menu; \
	else \
		echo "removing /etc/xdg/menus/fns-applications.menu"; \
		rm -f /etc/xdg/menus/fns-applications.menu; \
	fi; \
	
	for file in $(fns_xdgfiles); do \
		echo "removing $(xdgdir)/$$file"; \
		rm -f $(xdgdir)/$$file; \
	done
	echo "removing $(xdgdir) if empty"
	rmdir $(xdgdir) 2>/dev/null

	echo "-> Remove Gtk themes"
	for file in $(fns_themesfiles); do \
		echo "removing $(themesdir)/$$file"; \
		rm -f $(themesdir)/$$file; \
	done
	for directory in $(fns_themesdirs); do \
		echo "removing $(themesdir)/$$directory if empty"; \
		rmdir $(themesdir)/$$directory 2>/dev/null; \
	done
	echo "removing $(themesdir) if empty"
	rmdir $(themesdir) 2>/dev/null

	echo "removing $(datadir) if empty"
	rmdir $(datadir) 2>/dev/null
	echo "removing $(pkgprefix) if empty"
	rmdir $(pkgprefix) 2>/dev/null

	echo "-> Unregister apps at polkit if set"; \
	for app in "cpufreq-set" "cpupower"; do
		if test -n `which $$app`; then \
			alreadyHere=`cat /usr/share/polkit-1/actions/org.freedesktop.policykit.pkexec.policy | grep "$$app"`; \
			if [ "$$alreadyHere" != "" ]; then \
				echo "   $$app"; \
				bin/fns-poladd -r "$$app"; \
			fi; \
		fi; \
	done; \

	echo
	echo "Fvwm-Nightshade is now hopefully removed. Only ~/.fvwm-nightshade exists."
	echo "If you don't need it anymore remove it by hand."

build-deb: 
	echo "Build debian package"
	rm -rf $(pkgdir)
	mkdir -p $(pkgdir)
	mkdir -p $(pkgdir)/DEBIAN
	cp debian/control $(pkgdir)/DEBIAN
	cp debian/fvwm-nightshade.postinst $(pkgdir)/DEBIAN/postinst
	cp debian/fvwm-nightshade.prerm $(pkgdir)/DEBIAN/prerm
	mkdir -p $(pkgdocdir)
	cp debian/copyright $(pkgdocdir)

deb: build-deb dist-install
	sed -i "/^Standards\|^Build\|^Package:\|^Depends:\|^$$/d;s/^[ \t]*fvwm/Depends:    fvwm/" $(pkgdir)/DEBIAN/control
	sed -i "s/Source: fvwm-nightshade/Package: fvwm-nightshade\nVersion: $(version)\nInstalled-Size: `du -s fvwm-nightshade |cut -f1`/" $(pkgdir)/DEBIAN/control
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
		sed -i "s#_perlsitedir#_perlsitedir $(perlsitedir)#" rpm/fvwm-nightshade.spec; \
		sed -i "s/Version:.*/Version:\t$(version)/" rpm/fvwm-nightshade.spec; \
		if test "`rpm -q yum|cut -d '-' -f -1`" == "yum"; then \
			if test "`cat /etc/*release |grep ^NAME |cut -d '=' -f2`" != "fedora"; then \
				if test "`cat /etc/*release |grep VERSION_ID |cut -d '=' -f2`" -lt "7"; then \
					sed -i "s/^Requires:\tcpupower/Requires:\tcpufrequtils/" rpm/fvwm-nightshade.spec; \
				else \
					sed -i "s/^Requires:\tcpupower/Requires:\tkernel-tools/" rpm/fvwm-nightshade.spec; \
				fi; \
			else \
				sed -i "s/^Requires:\tcpupower/Requires:\tkernel-tools/" rpm/fvwm-nightshade.spec; \
			fi; \
		fi; \
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
	cp arch/makepkg.conf $(pkgdir)/
	cp arch/fns.install $(pkgdir)/
	mv $(distdir).tar.gz $(pkgdir)/
	sed -i "s/pkgver=.*/pkgver=$(version)/" $(pkgdir)/PKGBUILD
	sed -i "s#source=.*#source=\"$(package)-$(version).tar.gz\"#" $(pkgdir)/PKGBUILD
	sed -i "s#^  cd \"\$$srcdir/.*#  cd \"\$$srcdir/$(package)-$(version)\"#" $(pkgdir)/PKGBUILD

arch: prepare-arch
	cd $(pkgdir); \
	makepkg --config $(pkgdir)/makepkg.conf -p PKGBUILD -g >> PKGBUILD; \
	makepkg --config $(pkgdir)/makepkg.conf -p PKGBUILD; \
	cd -
	mv $(pkgdir)/*.xz ../
	rm -rf $(pkgdir)

update-mo:
	cd po; \
	if test $(po-file); then \
		what="$(po-file).*.po"; \
		echo "Recompile .mo files with name $(po-file)"; \
	elif test $(po-lang); then \
		what="*.$(po-lang).po"; \
		echo "Recompile .mo files with lang $(po-lang)"; \
	else \
		what="*.po"; \
		echo "Recompile all .mo files"; \
	fi; \
	for file in `find . -name "$$what" -type f -printf "%f\n"`; do \
		basename=$${file%%.*}; \
		extensions=$${file#*.}; \
		lang=$${extensions%%.*}; \
		echo "  $$basename.$$lang.mo"; \
		msgfmt $$file -o $$basename.$$lang.mo;\
	done

.PHONY: dist distcheck install uninstall uninstall-alternative deb rpm arch gentoo-prepare
.SILENT: FORCE dist install uninstall build-deb deb rpm prepare-rpm arch prepare-arch build-install-list uninstall-alternative dist-install update-mo
	
