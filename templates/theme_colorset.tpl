#-----------------------------------------------------------------------
# File:		<name>
# Version:	<major>.<minor>.<fix>
# Licence: 	GPL 2
#
# Description:	<short but meaningful>
#
# Author:	<name> <email-address>	
#
# Created:	<MM/DD/YYYY>
# Changed:	<MM/DD/YYYY>
#-----------------------------------------------------------------------
# REMARKS:
#
# Hints: 'NoShape' removes the shape mask from the colorset.
#        'Plain' removes the background pixmap or gradient.
#        Optional parts are sometimes problematic because while switching
#        they won't be removed and will be stayed until restart!
#
# IMPORTANT: ALL COLORSETS MUST BE SET !!! BECAUSE ALL ARE SET IN THE 
#            OTHER THEMES. NOT ALL ARE USED. THESE CAN BE TAKEN FOR OTHERS.
#            IF POSSIBLE ;-)


########################################################################
# Default Colorset
########################################################################

#-----------------------------------------------------------------------
# for feedback windows (like geometry window and NoteMessage) and Fvwm*
#
# Example:
# Colorset 0 fg black, bg white
#-----------------------------------------------------------------------
Colorset 0 fg black, bg white


########################################################################
# Window Decorations
########################################################################
# The following colors are used in FvwmPager for the window colors
# and in a title bar of windows (shade/hilight colors, computed from
# the bg color, but might be specified directly by sh and hi).

#-----------------------------------------------------------------------
# window title, inactive
#
# fg = inactive titlebar font color
# bg = inactive hilight color for vector buttons
# sh = inactive shade color for vector buttons
# optional:
# IconAlpha = inactive transparent mini icon in titlebar in %
#
# Examples:
# Colorset 1 fg #606060, bg #606060, sh #98a5b5
# Colorset 1 fg grey, IconAlpha 60
#-----------------------------------------------------------------------
Colorset 1

#-----------------------------------------------------------------------
# window title, active
#
# ?Gradient = active windows titlebar
# fg = active titlebar font color
# bg = active hilight color for vector buttons
#      active windows titlebar
# sh = active shade color for vector buttons
# optional:
# fgAlpha = merge titlebar text and background in %
#
# Examples:
# Colorset 2  VGradient 255 2 #829aba 40 #657d9d 60 #314969, bg white, fg white, fgAlpha 85, sh #606060, NoShape
# Colorset 2  VGradient 255 2 #65645e 60 #4c4b46 40 #403f3a, fg white, NoShape
# Colorset 2  bg #e0dedc, fg black, Plain
#-----------------------------------------------------------------------
Colorset 2

#-----------------------------------------------------------------------
# window borders and titlebar, inactive
#
# ?Gradient = background inactive windows titlebar
# bg = inactive border line color (FvwmIconman)
#      inactive windows titlebar            _
# hi = inactive border (inner) shade color |
# sh = inactive border color (Window, FvwmPager, FvwmButtons)
#      inactive border (inner) shade color _| (FvwmPager, FvwmButtons)
#
# Examples:
# Colorset 3 VGradient 255 2 #98a5b5 40 #7c8999 60 #687585, bg #687585, hi #657d9d, NoShape
# Colorset 3 bg #e0dedc, hi grey80, Plain
#-----------------------------------------------------------------------
Colorset 3

#-----------------------------------------------------------------------
# window borders, active
#
# bg = border color               _
# hi = active border shade color |
# sh = active border shade color _|
#
# Example:
# Colorset 4 bg #829aba, hi #657d9d, sh #657d9d, Plain
#-----------------------------------------------------------------------
Colorset 4 


########################################################################
# Menu Colorsets
########################################################################

#-----------------------------------------------------------------------
# inactive menu
#
# ?Gradient = color flow in menu
# fg = title font color
# bg =
# hi = inactive arrow color und menu border
#
# Example:
# Test (EnvMatch use_composite 1) Colorset 5 fg white, bg #233040, hi #535353, Plain, RootTransparent, Tint #232323 $[infostore.used_menutint]
# Test (EnvMatch use_composite 0) Colorset 5 fg white, bg #233040, hi #535353, Plain
#-----------------------------------------------------------------------
Test (EnvMatch use_composite 1) Colorset 5
Test (EnvMatch use_composite 0) Colorset 5

#-----------------------------------------------------------------------
# active/hilighted menu item
# fg = title font color in the higlighted area
# bg = highlight bar color
# hi = arrow color if higlighted
#
# Example:
# Test (EnvMatch use_composite 1) Colorset 6 fg white, bg #969696, hi white, Plain, RootTransparent, Tint #969696 $[infostore.used_menutint]
# Test (EnvMatch use_composite 0) Colorset 6 fg white, bg #969696, hi white, Plain
#-----------------------------------------------------------------------
Test (EnvMatch use_composite 1) Colorset 6
Test (EnvMatch use_composite 0) Colorset 6

#-----------------------------------------------------------------------
# Menu title if needed
#
# Examples:
# without special title
# Colorset 7 Plain 
# with special title
# Test (EnvMatch use_composite 1) Colorset 7 fg black, bg #a0a0a0, Pixmap $[FNS_THEMEDIR]/images/title.svg, Alpha $[infostore.used_menutint], NoShape
# Test (EnvMatch use_composite 0) Colorset 7 fg black, bg #a0a0a0, Pixmap $[FNS_THEMEDIR]/images/title.svg, NoShape
#-----------------------------------------------------------------------
Colorset 7 Plain

#-----------------------------------------------------------------------
# Colorsets 8 and 9 are reserved for the future use.


########################################################################
# Module Colorsets
########################################################################

#-----------------------------------------------------------------------
# default for inactive modules
# FvwmButtons, FvwmPager, can be also used for FvwmIconMan, FvwmIconBox.
#
# ?Gradient = inactive background
# fg = inactive font color or border color (FvwmIconMan)
# bg = background of inactive pages  _
#      inactive border color        |    (FvwmIconMan)
#
# Examples:
# Colorset 10 VGradient 255 2 #e5e4e0 30 #9c9885 70 #312b1d, fg grey, bg #312b1d, NoShape
# Colorset 10 Pixmap $[FNS_THEMEDIR]/images/gradient_up.svg, fg #737373, bg #233040, NoShape
#-----------------------------------------------------------------------
Colorset 10 

#-----------------------------------------------------------------------
# default for active modules
# For hilighting a part of a button bar (some swallowed apps for example)
# or anything else.
#
# ?Gradient = active background
# fg = active font color color 
# bg = active border color (mouse) _| _
#      active border color           |
#
# Example:
# Colorset 11 VGradient 255 2 #312b1d 70 #9c9885 30 #e5e4e0,fg white, bg black, NoShape
# Colorset 11 Pixmap $[FNS_THEMEDIR]/images/gradient_down.svg, fg #091d68, bg #737373, NoShape
#-----------------------------------------------------------------------
Colorset 11

#-----------------------------------------------------------------------
# special or funny: a gradient or a pixmap
# May be used in certain FvwmButtons, FvwmIconMan (iconified windows),
# FvwmIconBox.
#
# ?Gradient = inactive background
# fg = inactive font color (FvwmIconMan)
# optional:                   _
# hi = inactive border shade |
#      Pager mini windows inactive
# sh = inactive border shade _|
#
# Example:
# Colorset 12 VGradient 255 2 #312b1d 70 #9c9885 30 #e5e4e0, fg LightSteelBlue2, NoShape
# Colorset 12 Pixmap $[FNS_THEMEDIR]/images/gradient_up.svg, fg #8f8fb2, hi #ececec, sh #ececec, NoShape
#-----------------------------------------------------------------------
Colorset 12

#-----------------------------------------------------------------------
# swallowed window: the hilight and shadow colors should be defined
# (-hd of xclock and -hl of xload use sh, and -hl of xclock uses hi)
#
# fg = font color
# bg = background color
#
# Example:
# Colorset 13 fg black, bg rgb:70/8C/8C, hi black, sh gray40, Plain
# Colorset 13 fg #233040, Pixmap $[FNS_THEMEDIR]/images/gradient_up.svg, NoShape
#-----------------------------------------------------------------------
Colorset 13

#-----------------------------------------------------------------------
# default #2
# FvwmPager or to get more colors in FvwmButtons, can be set to 10.
# Pager mini windows inactive
#
# fg = border color
# bg = background
#
# Example:
# Colorset 14 fg black, bg grey50, Plain
#-----------------------------------------------------------------------
Colorset 14

#-----------------------------------------------------------------------
# default hilight #2
# FvwmPager or to get more colors in FvwmButtons, can be set to 11.
# Pager mini windows active
#
# fg = border color
# bg = background
#
# Example:
# Colorset 15 fg black, bg snow2, Plain
#-----------------------------------------------------------------------
Colorset 15

#-----------------------------------------------------------------------
# tips/balloons (TaskBar and FvwmPager)
#
# fg = tip font color
# bg = tip background
#
# Example:
# Colorset 16 fg black, bg snow2, Plain
#-----------------------------------------------------------------------
Colorset 16


########################################################################
# Window List Module Colorsets
########################################################################

#-----------------------------------------------------------------------
# standard item
#
# Example:
# Colorset 17 fg black, bg rgb:80/A0/A0, Plain
#-----------------------------------------------------------------------
# Actually not used

#-----------------------------------------------------------------------
# active item
#
# Example:
# Colorset 18 fg black, bg rgb:A0/C8/C8, Plain
#-----------------------------------------------------------------------
# Actually not used

#-----------------------------------------------------------------------
# iconified item
#
# Example:
# Colorset 19 fg white, bg rgb:60/78/78, Plain
#-----------------------------------------------------------------------
# Actually not used

#-----------------------------------------------------------------------
# pointed item
#
# Example:
# Colorset 20 fg black, bg rgb:88/AA/AA, Plain
#-----------------------------------------------------------------------
# Actually not used


########################################################################
# Other Module Colorsets
########################################################################

#-----------------------------------------------------------------------
# FvwmIdent
#
# Example:
# Colorset 21 fg black, bg snow2, Plain
# Colorset 21 bg #233040, fg white, sh black, fgsh #233040, RootTransparent buffer, Tint #233040 $[infostore.used_menutint], Plain
#-----------------------------------------------------------------------
Colorset 21

#-----------------------------------------------------------------------
# FvwmConsole
#
# Example:
# Colorset 22 fg white, bg rgb:00/30/60, Plain
#-----------------------------------------------------------------------
Colorset 22

#-----------------------------------------------------------------------
# transparent
#
# Example:
# Colorset 23 fg $[fg.cs10], bg $[bg.cs10], Transparent
#-----------------------------------------------------------------------
Colorset 23

#-----------------------------------------------------------------------
# FvwmBacker
#
# Example:
# Colorset 24 VGradient 255 2 #312b1d 70 #9c9885 30 #e5e4e0, NoShape
#-----------------------------------------------------------------------
Colorset 24

########################################################################
# Nanomoids Colorsets
########################################################################

#-----------------------------------------------------------------------
# Default Colorset
#-----------------------------------------------------------------------
#
# Example:
# Colorset 25 fg $[infostore.used_appletfontcolor], bg #E0DFDE, hi #EEEEEE, sh #EEEEEE, RootTransparent, Tint #808080 $[infostore.used_applettint]
#-----------------------------------------------------------------------
Colorset 25 fg $[infostore.used_appletfontcolor], bg #E0DFDE, hi #EEEEEE, sh #EEEEEE, RootTransparent, Tint #808080 $[infostore.used_applettint]

#-----------------------------------------------------------------------
# Highlight Colorset or Default Colorset for Icons e.g. in DriveInn to
# simulate unmounted devices
#-----------------------------------------------------------------------
#
# Example:
# Colorset 26 fg #A4CDF9, bg #E0DFDE, hi #EEEEEE, sh #EEEEEE, RootTransparent, Tint #808080 $[infostore.used_applettint], IconAlpha 50
#-----------------------------------------------------------------------
Colorset 26 fg #A4CDF9, bg #E0DFDE, hi #EEEEEE, sh #EEEEEE, RootTransparent, Tint #808080 $[infostore.used_applettint], IconAlpha 50

#-----------------------------------------------------------------------
# Warn Colorset
#-----------------------------------------------------------------------
#
# Example:
# Colorset 27 fg #E78787, bg #E0DFDE, RootTransparent, Tint #808080 $[infostore.used_applettint]
#-----------------------------------------------------------------------
Colorset 27 fg #E78787, bg #E0DFDE, RootTransparent, Tint #808080 $[infostore.used_applettint]

#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#
# Example:
# Colorset 28 fg #E78787, bg #E0DFDE, RootTransparent, Tint #808080 $[infostore.used_applettint]
#-----------------------------------------------------------------------
Colorset 28 fg #E78787, bg #E0DFDE, RootTransparent, Tint #808080 $[infostore.used_applettint]

#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#
# Example:
# Colorset 29 fg #89D5D7, bg #E0DFDE, RootTransparent, Tint #808080 $[infostore.used_applettint]
#-----------------------------------------------------------------------
Colorset 29 fg #89D5D7, bg #E0DFDE, RootTransparent, Tint #808080 $[infostore.used_applettint]

#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#
# Example:
# Colorset 30
#-----------------------------------------------------------------------
Colorset 30

########################################################################
# Application Colorsets
########################################################################

#-----------------------------------------------------------------------
# regular terminal (xterm, rxvt, Eterm)
#
# Example:
# Colorset 31 fg white, bg #233040, Plain
#-----------------------------------------------------------------------
Colorset 31

#-----------------------------------------------------------------------
# admin terminal (su xterm)
#
# Example:
# Colorset 32 fg white, bg #233040, Plain
#-----------------------------------------------------------------------
Colorset 32

#-----------------------------------------------------------------------
# remote terminal (ssh, telnet)
#
# Example:
# Colorset 33 fg white, bg #233040, Plain
#-----------------------------------------------------------------------
Colorset 33

#-----------------------------------------------------------------------
# viewer terminal (man, less, tail -f)
#
# Example:
# Colorset 34 fg white, bg SeaGreen4, Plain
#-----------------------------------------------------------------------
Colorset 34

#-----------------------------------------------------------------------
# application run in the terminal, text editor using ft-xrdb
#
# Example:
# Colorset 35 fg black, bg snow2, Plain
#-----------------------------------------------------------------------
Colorset 35

#-----------------------------------------------------------------------
# dialog main background (FvwmScript, FvwmForm, xmessage, ft-xrdb)
#
# Example:
# Colorset 36 fg black, bg #969696, Plain
#-----------------------------------------------------------------------
Colorset 36

#-----------------------------------------------------------------------
# dialog text area (FvwmScript, FvwmForm, xmessage, ft-xrdb)
#
# Example:
# Colorset 37 fg black, bg #969696, Plain
#-----------------------------------------------------------------------
Colorset 37

#-----------------------------------------------------------------------
# Colorsets 38 to 40 are reserved for the future use.
