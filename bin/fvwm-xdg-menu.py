#-----------------------------------------------------------------------
# File:		fvwm-xdg-menu.py
# Version:	1.99
# Licence: 	GPL 2
#
# Description:	creates a Fvwm menu with xdg entries
#
# Author:	Piotr Zielinski (http://www.cl.cam.ac.uk/~pz215/)	
# Created:	12/03/2005
# Changed:	05/22/2012 by Thomas Funk <t.funk@web.de>
#-----------------------------------------------------------------------

#!/usr/bin/python

# This script searches for the newest menu file conforming to the 
# XDG Desktop Menu Specification, and outputs the FVWM equivalent 
# to the standard output.
#
#   http://standards.freedesktop.org/menu-spec/latest/

# Syntax:
#
#   fvwm-xdg-menu.py [options] ...
#
# Example:
#
#   fvwm-xdg-menu.py -w -f -s 16 -m FvwmMenu 

# This script requires the python-xdg module, which in Debian can be
# installed by typing
#
#   apt-get install python-xdg

import sys
import xdg.Menu
import xdg.IconTheme
import xdg.Locale
import optparse
import os.path
import os
from xdg.DesktopEntry import *
import fnmatch

usage = """

   %prog [options] ...

This script searches for the newest menu file conforming to the XDG Desktop Menu Specification, and outputs the FVWM equivalent to the standard output.

   http://standards.freedesktop.org/menu-spec/latest/

Examples:

   Writes menu with top level name 'Applications' to file
   %prog -m Applications > menu
   
   Creates menu with titles, convert icons to 16x16, menu top level name is 'FvwmMenu'
   %prog -w -f -s 16 -m FvwmMenu
   
   Creates menu with oxygen icons and take the menu entries from kde4-applications.menu
   %prog -t oxygen -p 'kde4-'"""

parser = optparse.OptionParser(usage=usage)
parser.add_option("-e", "--exec", dest="exec_command", type="string",
                  default="Exec",
                  help="FVWM command used to execute programs [Exec]")
parser.add_option("-s", "--size", dest="icon_size", type="int",
                  default=24, help="Used icon size [24]")
parser.add_option("-f", "--force", action="store_true", dest="force",
                  default=False,
                  help="Force icon size (requires imagemagick and writes \
                  into ICON_DIR)")
parser.add_option("-i", "--icon-dir", dest="icon_dir", type="string",
                  default="~/.fvwm/menu-icons",
                  help="Directory for converted icons [~/.fvwm/menu-icons]")
parser.add_option("-t", "--theme", dest="theme", type="string",
                  default="gnome",
                  help="Used icon theme [gnome]")
parser.add_option("-m", "--top-menu", dest="top", type="string",
                  default="",
                  help="Top menu name")
parser.add_option("-w", "--with-titles", action="store_true", dest="with_titles",
                  default=False,
                  help="Menus have titles [no]")
parser.add_option("-p", "--prefix", dest="menu_prefix", type="string",
                  default="",
                  help="Force special menu e.g. 'gnome-' [none]")


(options, args) = parser.parse_args()

def printtext(text):
    print text.encode("utf-8")

def geticonfile(icon, size=options.icon_size, theme=options.theme):
    iconpath = xdg.IconTheme.getIconPath(icon, size, theme, ["png", "xpm"])
    if not iconpath == None:
        extension = os.path.splitext(iconpath)[1]

    if not iconpath:
        return None

    if not options.force:
        return iconpath
    
    if iconpath.find("%ix%i" % (size, size)) >= 0: # ugly hack!!!
        return iconpath

    #printtext(iconpath)
    
    if not os.path.isdir(os.path.expanduser(options.icon_dir)):
        os.system("mkdir " + os.path.expanduser(options.icon_dir))
    
    iconfile = os.path.join(os.path.expanduser(options.icon_dir),
                            "%ix%i-" % (size, size) + 
                            os.path.basename(iconpath))
    if extension == '.svg':
        iconfile = iconfile.replace('.svg', '.png')

    os.system("if test \\( ! -f '%s' \\) -o \\( '%s' -nt '%s' \\) ; then convert '%s' -resize %i '%s' ; fi"% 
              (iconfile, iconpath, iconfile, iconpath, size, iconfile))
    
    return iconfile

    
def getdefaulticonfile(command):
    if command.startswith("Popup"):
        return geticonfile("gnome-fs-directory")
    else:
        return geticonfile("gnome-applications")    

def printmenu(name, icon, command):
    iconfile = geticonfile(icon) or getdefaulticonfile(command) or icon
    printtext('+ "%s%%%s%%" %s' % (name, iconfile, command))

def parsemenu(menu, name=""):
    if not name:
      name = menu.getPath()

    printtext('DestroyMenu "%s"' % name)
    if options.with_titles:
        printtext('AddToMenu "%s" "%s" Title' % (name, name))
    else:
        printtext('AddToMenu "%s"' % name)
    
    for entry in menu.getEntries():
	if isinstance(entry, xdg.Menu.Menu):
	    printmenu(entry.getName(), entry.getIcon(),
		      'Popup "%s"' % entry.getPath())
	elif isinstance(entry, xdg.Menu.MenuEntry):
	    desktop = DesktopEntry(entry.DesktopEntry.getFileName())
	    printmenu(desktop.getName(), desktop.getIcon(),
		      options.exec_command + " " + desktop.getExec())
	else:
	    printtext('# not supported: ' + str(entry))

    print
    for entry in menu.getEntries():
	if isinstance(entry, xdg.Menu.Menu):
	    parsemenu(entry)

# ----- Main ----------------------------------------------------------------
# $XDG_CONFIG_DIRS/menus/${XDG_MENU_PREFIX}applications.menu
# get the wantedor newest used menu
pattern = ''

if not options.menu_prefix == '':
    if options.menu_prefix == 'debian-':
        pattern = 'debian-menu.menu'
    else:
        xdg_menu_prefix = options.menu_prefix

if pattern == '':
    pattern = '*' + options.menu_prefix + 'applications.menu'
    
newest_mtime = 0
newest_xdg_file = ''

for dir in xdg_config_dirs:
    dir = dir + '/menus'
    dir_list = os.listdir(dir)
    for filename in fnmatch.filter(dir_list, pattern):
        temp_mtime = os.path.getmtime(os.path.join(dir, filename))
        if temp_mtime > newest_mtime:
            newest_mtime = temp_mtime
            newest_xdg_file = os.path.join(dir, filename)
        
parsemenu(xdg.Menu.parse(newest_xdg_file), options.top)

"""
for arg in args:
    print '# %s' % arg
    parsemenu(xdg.Menu.parse(arg), options.top)
"""        
