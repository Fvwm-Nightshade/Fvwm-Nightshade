%define     __spec_install_post %{nil}
%define     debug_package %{nil}
%define     __os_install_post %{_dbpath}/brp-compress
%define		_perlsitedir

Name:       fvwm-nightshade
Version:    
Release:    1
Summary:    Fvwm-Nightshade

Group:      X11/Window Managers
License:    GPL v2+
URL:        https://github.com/Fvwm-Nightshade
Source0:    %{expand:%%(pwd)}/../%{name}-%{version}.tar.gz
BuildArch:  noarch
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}

Requires:   fvwm >= 2.6.5
Requires:   python < 3
Requires:   pyxdg
Requires:   perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:   perl(Gtk2)
Requires:   librsvg2
Requires:   xterm
Requires:   conky
Requires:   xscreensaver
Requires:   feh
Requires:   ImageMagick
Requires:   stalonetray
Requires:	cpupower
Requires:   xorg-x11-apps
Requires:   pcmanfm
Requires:   polkit-gnome
Requires:   gtk-murrine-engine
Requires:   network-manager-applet

Provides: 	perl(governor)

%description
A lightweight but feature rich and good looking configuration of Fvwm.


%prep
cp %{SOURCEURL0} %{_topdir}/SOURCES/
%setup -q

%build
# nothing to do

%install
rm -rf $RPM_BUILD_ROOT
make DESTDIR=$RPM_BUILD_ROOT prefix=/usr dist-install

%post
if [ "$1" -eq 1 ] ; then
    for app in cpufreq-set cpupower; do
        if [ `which $app &> /dev/null ;echo $?` == "0" ]; then
            echo "register $app at pkexec"
            /usr/bin/fns-poladd $app
        fi
    done
fi
exit 0

%preun
if [ "$1" -eq 0 ] ; then
	echo "run preuninstall"
    for app in cpufreq-set cpupower; do
        if [ `which $app &> /dev/null ;echo $?` == "0" ]; then
            alreadyHere=`cat /usr/share/polkit-1/actions/org.freedesktop.policykit.pkexec.policy | grep "$app"`
            if [ "$alreadyHere" != "" ]; then
                echo "unregister $app from pkexec"
                /usr/bin/fns-poladd -r $app
            fi
        fi
    done
fi
exit 0

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{_bindir}/*
%{_datadir}/*
%{_perlsitedir}/*
/etc/*

%define date%(echo `LC_ALL="C" date +"%a %b %d %Y"`)
%changelog
* %{date} Fvwm-Nightshade team <fvwmnightshade@gmail.com>
  - Auto building %{version}-%{release}
* Tue Dec 25 2012 Thomas Funk <t.funk@web.de>
  - First try at making the package

