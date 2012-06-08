########################################################################
# File:		<name>
# Version:	<major>.<minor>.<fix>
#
# Description:	<short but meaningful>
#
#
# Author:	<name> <email-address>	
# Created:	<MM/DD/YYYY>
# Changed:	<MM/DD/YYYY>
########################################################################
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


#-----------------------------------------------------------------------
# window borders, inactive
#
# ?Gradient = inactive windows titlebar
# bg = inactive border line color
#      inactive windows titlebar    _
# hi = inactive border shade color |
# sh = inactive border shade color _|
#
# Examples:
# Colorset 3 VGradient 255 2 #98a5b5 40 #7c8999 60 #687585, bg #687585, hi #657d9d, NoShape
# Colorset 3  bg #e0dedc, hi grey80, Plain
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# window borders, active
#
# bg = border color               _
# hi = active border shade color |
# sh = active border shade color _|
# Colorset 4 bg #829aba, hi #657d9d, sh #657d9d, Plain
#
# Example:
# Colorset 4 bg #829aba, hi #657d9d, sh #657d9d, Plain
#-----------------------------------------------------------------------



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
# Colorset 5 VGradient 255 2 #9c9885 60 #e5e4e0 40 white, fg black, bg #424241, hi #424241, NoShape
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# active/hilighted menu item
# fg = title font color in the higlighted area
# bg = highlight bar color
# hi = arrow color if higlighted
#
# Example:
# Colorset 6 fg white, bg #687585, hi orange, Plain
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# greyed menu item if needed
#
# Example:
# Colorset 7 fg grey45, bg grey45, Plain
#-----------------------------------------------------------------------


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
# fg = inactive font color or border color
# bg = background of inactive pages
#
# Example:
# Colorset 10 VGradient 255 2 #e5e4e0 30 #9c9885 70 #312b1d, fg grey, bg #312b1d, NoShape
#-----------------------------------------------------------------------


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
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# special or funny: a gradient or a pixmap
# May be used in certain FvwmButtons, FvwmIconMan, FvwmIconBox.
#
# ?Gradient = inactive background
# fg = inactive font color
# optional:                   _
# hi = inactive border shade |
# sh = inactive border shade _|
#
# Example:
# Colorset 12 VGradient 255 2 #312b1d 70 #9c9885 30 #e5e4e0, fg LightSteelBlue2, NoShape
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# swallowed window: the hilight and shadow colors should be defined
# (-hd of xclock and -hl of xload use sh, and -hl of xclock uses hi)
#
# fg = font color
# bg = background color
#
# Example:
# Colorset 13 fg black, bg rgb:70/8C/8C, hi black, sh gray40, Plain
#-----------------------------------------------------------------------


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


#-----------------------------------------------------------------------
# tips/balloons (TaskBar and FvwmPager)
#
# fg = tip font color
# bg = tip background
#
# Example:
# Colorset 16 fg black, bg snow2, Plain
#-----------------------------------------------------------------------



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
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# FvwmConsole
#
# Example:
# Colorset 22 fg white, bg rgb:00/30/60, Plain
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# transparent
#
# Example:
# Colorset 23 fg $[fg.cs10], bg $[bg.cs10], Transparent
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# FvwmBacker
#
# Example:
# Colorset 24 VGradient 255 2 #312b1d 70 #9c9885 30 #e5e4e0, NoShape
#-----------------------------------------------------------------------


########################################################################
# External Colorsets
########################################################################

#-----------------------------------------------------------------------
# reserved for modules@: 25

#-----------------------------------------------------------------------
# reserved for the future use: 26-28

#-----------------------------------------------------------------------
# temporary colorset: 29, has no static definition, used dynamically


########################################################################
# Application Colorsets
########################################################################

#-----------------------------------------------------------------------
# regular terminal (xterm, rxvt, Eterm)
#
# Example:
# Colorset 30 fg white, bg rgb:00/00/50, Plain
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# admin terminal (su xterm)
#
# Example:
# Colorset 31 fg white, bg rgb:00/50/50, Plain
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# remote terminal (ssh, telnet)
#
# Example:
# Colorset 32 fg white, bg rgb:50/00/00, Plain
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# viewer terminal (man, less, tail -f)
#
# Example:
# Colorset 33 fg white, bg SeaGreen4, Plain
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# application run in the terminal, text editor using ft-xrdb
#
# Example:
# Colorset 34 fg black, bg snow2, Plain
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# dialog main background (FvwmScript, FvwmForm, xmessage, ft-xrdb)
#
# Example:
# Colorset 35 fg black, bg rgb:80/A0/80, Plain
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# dialog text area (FvwmScript, FvwmForm, xmessage, ft-xrdb)
#
# Example:
# Colorset 36 fg black, bg rgb:A0/C8/A0, Plain
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# Colorsets 37 to 39 are reserved for the future use.
