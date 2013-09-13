# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python2_7 )
inherit eutils python-r1

MY_P="fvwm-nightshade-${PV}"

DESCRIPTION="Fvwm-Nightshade aims to be a lightweight but feature rich and good looking configuration of Fvwm."
HOMEPAGE="http://fvwm-nightshade.github.io/Fvwm-Nightshade/"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="wm-icons pcmanfm nm-gnome volumeicon pm-utils lxappearance qtconfig"

RDEPEND="${PYTHON_DEPS}
	>=x11-wm/fvwm-2.6.5[bidi,doc,gtk2-perl,netpbm,nls,perl,png,readline,rplay,stroke,svg,truetype,vanilla,xinerama,lock]
	|| ( media-gfx/imagemagick[svg] media-gfx/graphicsmagick[imagemagick] )
	media-gfx/feh
	x11-apps/xwd
	x11-apps/xprop
	x11-misc/stalonetray
	x11-misc/xscreensaver
	x11-terms/xterm
	app-admin/conky
	sys-power/cpufrequtils
	dev-python/pyxdg
	wm-icons? ( x11-themes/wm-icons )
	pcmanfm? ( x11-misc/pcmanfm )
	nm-gnome? ( gnome-extra/nm-applet )
	volumeicon? ( media-sound/volumeicon )
	pm-utils? ( sys-power/pm-utils )
	lxappearance? ( lxde-base/lxappearance )
	qtconfig? ( dev-qt/qtgui )"

S=${WORKDIR}/${MY_P}

src_install() {
	emake \
		DESTDIR="${D}" \
		prefix="/usr" \
		dist-install
}

pkg_postinst() {
	einfo
	einfo "If you haven't a graphical login manager copy xinitrc template into your home directory"
	einfo " $ cp ${ROOT}usr/share/doc/fvwm-nightshade/xinitrc-example ~/.xinitrc"
	einfo "or add the following lin in your .xinitrc:"
	einfo " exec fvwm-nightshade"
	einfo "and start the xserver with"
	einfo " $ startx"
	einfo "change the base settings and enjoy."
	einfo ""
	einfo "If you have installed Fvwm-Nightshade locally and want to use a display-manager copy"
	einfo "fvwm-nightshade.desktop-example from the doc directory to /usr/share/xsessions:"
	einfo " # cp ${ROOT}usr/share/doc/fvwm-nightshade/fvwm-nightshade.desktop-example /usr/share/xsessions/fvwm-nightshade.desktop"
	einfo ""
	einfo "Many applications can extend functionality of Fvwm-Nightshade."
	einfo "They are listed in ${ROOT}usr/share/doc/${PF}/INSTALL.gz."
	einfo ""
	einfo "Read the manual pages for more details."
	einfo ""
}
