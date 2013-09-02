%define       	__spec_install_post %{nil}
%define         debug_package %{nil}
%define        	__os_install_post %{_dbpath}/brp-compress

Name:		fvwm-nightshade
Version:	
Release:	1
Summary:	Fvwm-Nightshade

Group:		X11/Window Managers
License:	GPL v2+
URL:		https://github.com/Fvwm-Nightshade
Source0:	%{expand:%%(pwd)}/../%{name}-%{version}.tar.gz
BuildArch:	noarch
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}

Requires:	fvwm >= 2.6.5
Requires:	python < 3
Requires:	pyxdg
Requires:	xterm
Requires:	conky
Requires:	xscreensaver
Requires:	feh
Requires:	ImageMagick
Requires:	librsvg2
Requires:	stalonetray
Requires:	cpufrequtils
Requires:	xorg-x11-apps
Requires:	beesu

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

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{_bindir}/*
%{_datadir}/*

%define date%(echo `LC_ALL="C" date +"%a %b %d %Y"`)
%changelog
* %{date} Fvwm-Nightshade team <fvwmnightshade@gmail.com>
  - Auto building %{version}-%{release}
* Tue Dec 25 2012 Thomas Funk <t.funk@web.de>
  - First try at making the package

