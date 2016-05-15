# Copyright (c) 2015 Thomas Funk
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# ---------------------------------------------------------------------
#   Title: SimpleGtk2
#
#   A Rapid Application Development Library for Gtk+ version 2.
#
#   About: Description
#   SimpleGtk2 is a wrapper library to build graphical user interfaces
#   with a minimal programming effort.
#
#   It is based on the GtkFixed widget which is a container you can place 
#   child widgets at fixed positions and with fixed sizes, given in pixels.
#
#   About: Example
#   The 'Hello World' example ;-)
#
#   Original with Perl-Gtk2:
#
#   (start code)
#        #! /usr/bin/perl -w
#        use strict;
#        use Gtk2 -init;
# 
#        # toplevel window
#        my $window = Gtk2::Window->new('toplevel');
#        $window->signal_connect(delete_event => sub { Gtk2->main_quit });
# 
#        # button
#        my $button = Gtk2::Button->new('Action');
#        $button->signal_connect(clicked => sub{print("Hello Gtk2-Perl\n");});
# 
#        # add button and show window
#        $window->add($button);
#        $window->show_all();
# 
#        Gtk2->main;
#   (end)
#
#   With SimpleGtk2:
#
#   (start code)
#        #! /usr/bin/perl -w
#        use strict;
#        use SimpleGtk2;
# 
#        # toplevel window
#        my $window = SimpleGtk2->new_window(Type => 'toplevel', 
#                                            Name => 'main', 
#                                            Title => 'Hello World');
#        $window->add_signal_handler('main', 'delete_event', 
#                                            sub { Gtk2->main_quit; });
# 
#        # button
#        $window->add_button(Name => 'button', Pos => [20, 40], 
#                            Title => "Action", Sig => 'clicked', 
#                            Func => sub {print("Hello Gtk2-Perl\n");});
#        # show window
#        $window->show_and_run();
#   (end)
#
#   About: Basics
#   Short introduction how SimpleGtk2 is constructed.
#
#   SimpleGtk2 works with objects and containers. 
#
#   All widget objects are stored as a hash in an internal object list hash 
#   in the respective window created with <new_window>. Basically each object 
#   hash has the following structure:
#
#   (start code)
#    object = (  type       => <string>  || undef,
#                name       => <string>  || undef,
#                title      => <string>  || undef,
#                pos_x      => <integer> || undef,
#                pos_y      => <integer> || undef,
#                width      => <integer> || undef,
#                height     => <integer> || undef,
#                container  => <string>  || undef,
#                tip        => <string>  || undef,
#                handler    => <hash>    || {},
#                ref        => <widget_reference> || undef
#             )
#   (end)
#
#   Some widgets have additional entries like paths or other references but
#   all of them can be accessed and updated with the support functions and 
#   shouldn't used directly to prevent inconsistencies.
#
#   Containers are the window itself, frames or notebook pages. If you are use 
#   a GUI designer like Qt-Designer (not a joke - Glade cannot be used because it
#   handles the positioning and sizing without dimensions but Qt-Designer does) to
#   create your surface you can take the position values one by one in SimpleGtk2.
#
#   SimpleGtk2 has implemented the most needed functions for each widget. But if you 
#   need one which isn't available you can use its Gtk reference and access it the
#   old way.
#
#   About: Special Feature
#   SimpleGtk2 has module support for <FVWM at http://www.fvwm.org> to use it in conjunction
#   with <fvwm-perllib at http://www.fvwm.org/documentation/perllib/>. See <FVWM Support> for
#   more information.
#   
#   About: Caveats
#   The problems and their handling.
#
#   GtkFixed has some caveats but the most annoying ones are removed or can 
#   be defanged with this library:
#   - The GUI grows/shrinks automatically depending on the Font size. Default is 10. 
#     But you can create the GUI with your loved size. Add it to your <new_window> 
#     definition and you're fine.
#   - The widget sizes aren't changeable by themes because they're defined 
#     by the user in the program.
#   - Translation of text into other languages changes its size. Also, display 
#     of non-English text will use a different font in many cases. So keep 
#     in mind to use positioning and sizing sufficiently, that translations fit 
#     fine enough. 
#
#   The only thing which still exists is that fixed widgets can't properly be mirrored in 
#   right-to-left languages such as Hebrew and Arabic. i.e. normally GTK+ will 
#   flip the interface to put labels to the right of the thing they label, but 
#   it can't do that with GtkFixed. So your application will not be usable in 
#   right-to-left languages. 
#
#   About: Bugs
#   Where to send bug reports.
#
#   Bug reports can be sent to fvwmnightshade-workers mailing list at 
#   <https://groups.google.com/forum/?hl=en#!forum/fvwmnightshade-workers>
#   or submit them under <https://github.com/Fvwm-Nightshade/Fvwm-Nightshade/issues>.
#
#   About: License
#   This software stands under the GPL V2 or higher.
#
#   About: Author
#   (C) 2015 Thomas Funk <t.funk@web.de>
#
#   About: Thanks
#   Thanks to:
#   * The Perl-Gtk2 team helped me to fix some problems.
#   * The Gtk2 team where I've borrowed some text passages and the arrangement.
# ---------------------------------------------------------------------
package SimpleGtk2;

#use 5.004;
use strict;
use Gtk2 '-init';
use POSIX qw(setlocale);
use Locale::gettext;
use I18N::Langinfo qw(langinfo CODESET);
use Encode qw(decode encode);;
use Scalar::Util qw(looks_like_number);
use Gtk2::Ex::Simple::List;
use Gtk2::Ex::Simple::Tree;

#
use Data::Dumper;
#    print "-------------------------------\n";
#    print Dumper(\$attrlist);

require Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $GETTEXT $LANGUAGE $LCDIRECTORY $APPNAME $CODESET);
@ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration    use SimpleGtk2 ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
#%EXPORT_TAGS = ( 'all' => [ qw(
#    
#) ] );

#@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
@EXPORT_OK = ();
@EXPORT = qw(use_gettext translate get_fontsize get_fontfamily get_fontweight 
            get_color new_window internal_die show_error show_message show 
            show_and_run add_signal_handler remove_signal_handler get_object 
            exist_object get_widget hide_widget show_widget 
            add_tooltip add_button add_link_button 
            add_filechooser_button add_font_button add_check_button 
            add_radio_button add_label add_frame add_entry add_spin_button 
            add_combo_box add_slider add_scroll_bar add_image add_drawing_area 
            add_text_view add_menu_bar add_menu add_menu_item add_notebook 
            add_nb_page add_msg_dialog show_msg_dialog add_filechooser_dialog 
            show_filechooser_dialog add_fontselection_dialog show_fontselection_dialog 
            add_statusbar add_treeview is_sensitive get_title get_tooltip get_size 
            get_pos is_active is_underlined get_value get_font_string get_font_array 
            font_array_to_string font_string_to_array get_image get_textview 
            get_treeview get_group set_sensitive set_title set_tooltip set_size 
            set_pos set_value set_values set_image set_textview set_font 
            set_font_color remove_nb_page initial_draw set_sb_text remove_sb_text 
            clear_sb_stack modify_list_data modify_tree_data);

$VERSION = '0.68';
$LANGUAGE = $ENV{LANG} || 'en_US.UTF-8';
$CODESET = langinfo(CODESET());
$GETTEXT = 0;

POSIX::setlocale(&POSIX::LC_ALL, $LANGUAGE);

######################################################################
# internal functions
######################################################################

# ---------------------------------------------------------------------
# global widget object structure for window object list
# ---------------------------------------------------------------------
sub _new_widget {
    my %params = @_;
    my $self = { };
    $self->{type} = $params{'type'} || undef;
    $self->{name} = $params{'name'} || undef;
    $self->{title} = $params{'title'} || undef;
    $self->{pos_x} = defined($params{'position'}) ? ($params{'position'}[0] == 0 ? 0 : $params{'position'}[0]) : undef;
    $self->{pos_y} = defined($params{'position'}) ? ($params{'position'}[1] == 0 ? 0 : $params{'position'}[1]) : undef;
    $self->{width} = defined($params{'size'}) ? ($params{'size'}[0] == 0 ? 0 : $params{'size'}[0]) : undef;
    $self->{height} = defined($params{'size'}) ? ($params{'size'}[1] == 0 ? 0 : $params{'size'}[1]) : undef;
    $self->{container} = $params{'frame'} || undef;
    $self->{tip} = $params{'tooltip'} || undef;
    $self->{handler} = {};
    $self->{ref} = undef;
    return $self;
}

# ---------------------------------------------------------------------
# _normalize - normalize keys in a hash
# ---------------------------------------------------------------------
sub _normalize($@) {
    my $self = shift;
    my %params = @_;
    my %new_params;

    # get all key/value pairs
    foreach my $key (keys %params) {
        # lower key
        my $new_key = lc($key);
        # extend key
        $new_key = _extend($new_key);
        # scale position and size if needed
        if ($self->{scalefactor} != 1 and $new_key =~ /^(position|size)/) {
            $new_params{$new_key} = $self->_scale($params{$key});
        } else {
            $new_params{$new_key} = $params{$key};
        }
    }
    return %new_params;
}

# ---------------------------------------------------------------------
# _extend - extend keys
# ---------------------------------------------------------------------
sub _extend {
    my $short = shift;
    
    if ($short =~ /^(pos|tip|func|sig|sens|min|max|orient|valuepos|pixbuf|textbuf|
                    wrap|climb|col|scroll|prev|cur|no|dtype|mtype|rfunc|file|gname)/) {
        if    ($short eq 'pos') {$short = 'position';}
        elsif ($short eq 'tip') {$short = 'tooltip';}
        elsif ($short eq 'func') {$short = 'function';}
        elsif ($short eq 'sig') {$short = 'signal';}
        elsif ($short eq 'sens') {$short = 'sensitive';}
        elsif ($short eq 'min') {$short = 'minimum';}
        elsif ($short eq 'max') {$short = 'maximum';}
        elsif ($short eq 'orient') {$short = 'orientation';}
        elsif ($short eq 'valuepos') {$short = 'valueposition';}
        elsif ($short eq 'pixbuf') {$short = 'pixbuffer';}
        elsif ($short eq 'textbuf') {$short = 'textbuffer';}
        elsif ($short eq 'wrap') {$short = 'wrapped';}
        elsif ($short eq 'climb') {$short = 'climbrate';}
        elsif ($short eq 'col') {$short = 'columns';}
        elsif ($short eq 'pos_n') {$short = 'positionnumber';}
        elsif ($short eq 'scroll') {$short = 'scrollable';}
        elsif ($short eq 'prev') {$short = 'previous';}
        elsif ($short eq 'current') {$short = 'currentpage';}
        elsif ($short eq 'no2name') {$short = 'number2name';}
        elsif ($short eq 'dtype') {$short = 'dialogtype';}
        elsif ($short eq 'mtype') {$short = 'messagetype';}
        elsif ($short eq 'rfunc') {$short = 'responsefunction';}
        elsif ($short eq 'file') {$short = 'filename';}
        elsif ($short eq 'gname') {$short = 'groupname';}
    }
    return $short;
}

# ---------------------------------------------------------------------
# _scale - scales the position and size depending on the $SCALE_FACTOR
# ---------------------------------------------------------------------
sub _scale($$) {
    my $self = shift;
    my $reference = shift;
    my $new_value;
    
    if (ref($reference) eq 'ARRAY') {
        my @new_array;
        foreach (@{$reference}) {
            $new_value = sprintf "%.0f", $_ * $self->{scalefactor};
            push(@new_array, $new_value);
        }
        return \@new_array;
    } 
    
    # scalar (string, int)
    $new_value = sprintf "%.0f", $reference * $self->{scalefactor};
    return $new_value;
    
}

# ---------------------------------------------------------------------
# _get_pos_inside_frame(<name_of_frame>, <pos_x_of_widget>, <pos_y_of_widget>)
# ---------------------------------------------------------------------
sub _get_pos_in_frame($@) {
    my $self = shift;
    my ($name, $src_x, $src_y) = @_;
    
    my $frame = $self->get_object($name);
    my $label_height = 0;
    
    if (defined($frame->{title})) {
        # get the current height of the label
        my $label = $frame->{ref}->get_label_widget();
        my $label_req = $label->size_request();
        $label_height = $label_req->height;
    }
    
    # calculate widget position in frame
    #my $x = $src_x - $frame->{pos_x};
    my $y = $src_y  - $label_height/2;
    
    return ($src_x, $y);
}


# ---------------------------------------------------------------------
# set some functions which appears in most of the widgets
# _set_commons(<name>, %params)
# ---------------------------------------------------------------------
sub _set_commons($@) {
    my $self = shift;
    my ($name, %params) = @_;
    
    # get object
    my $object = $self->get_object($name);
    my $widget = $object->{ref};
    my $type = $object->{type};

    # widget common fields
    my $function = undef;
    my $data = undef;
    if (defined($params{'function'})) {
        if (ref($params{'function'} =~ 'ARRAY')) {
            $function = $params{'function'}[0];
            $data = $params{'function'}[1];
        } else {
            $function = $params{'function'};
        }
    }
    
    my $signal = $params{'signal'} || undef;
    my $sensitive = defined($params{'sensitive'}) ? $params{'sensitive'} : undef;
    
    # set tooltip if needed
    unless($type =~ /(MenuBar|Menu$|Dialog$|LinkButton|List|Tree|Notebook$|Statusbar|Separator$|DrawingArea|TextView)/) {
        $self->add_tooltip($object->{name});
    }
    
    # add signal handler if function is given
    if (defined($function)) {
        $self->add_signal_handler($object->{name}, $signal, $function, $data);
    }

    # set sensitive state
    $object->{ref}->set_sensitive($sensitive) if defined($sensitive);

    # size of the widget
    unless($type =~ /^(Statusbar|Menu$)/) {
        if ($object->{width} && $object->{height}) {
            $widget->set_size_request($object->{width}, $object->{height});
        } else {
            if ($object->{type} eq 'Button') {
                # default size: 80x25 pixel on base 10 (scale factor = 1)
                $object->{width} = $self->_scale(80);
                $object->{height} = $self->_scale(25);
            } else {
                if ($object->{type} eq 'NotebookPage') {
                    $widget = $self->_get_container($object->{name});
                }
                my $req = $widget->size_request();
                $object->{width} = $req->width;
                $object->{height} = $req->height;
            }
        }
    }
}


# ---------------------------------------------------------------------
# add widget to a fixed container
# _add_to_container(<name>)
# ---------------------------------------------------------------------
sub _add_to_container($@) {
    my $self = shift;
    my $name = shift;
    my $object = $self->get_object($name);
    
    if (defined($object->{container})) {
        my $container = $self->_get_container($object->{container});
        my $container_obj = $self->get_object($object->{container});
        
        # calculate position
        my $x = $object->{pos_x};
        my $y = $object->{pos_y};
        if ($container_obj->{type} eq 'Frame') {
            ($x, $y) = $self->_get_pos_in_frame($object->{container}, $object->{pos_x}, $object->{pos_y});
        }
        
        $container->put($object->{ref}, $x, $y);
    } else {
        $self->{container}->put($object->{ref}, $object->{pos_x}, $object->{pos_y});
    }
}


# ---------------------------------------------------------------------
# _get_container(<name_of_container>)
# ---------------------------------------------------------------------
sub _get_container($@) {
    my $self = shift;
    my $name = shift;
    return $self->{containers}->{$name};
}


# ---------------------------------------------------------------------
# calculate the current scaling factor depending on the font size
# _calc_scalefactor(<old_font_size>, <new_font_size>)
# ---------------------------------------------------------------------
sub _calc_scalefactor($@) {
    my $self = shift;
    my ($old_size, $new_size) = @_;
    
    my $context = $self->{ref}->get_pango_context();
    my $language = $context->get_language();

    # Sans is used as a reference font
    my $old_fdesc = Pango::FontDescription->from_string('Sans ' . $old_size);
    my $old_metrics = $context->get_metrics($old_fdesc, $language);
    my $old_char_widths = $old_metrics->get_approximate_char_width();

    my $new_fdesc = Pango::FontDescription->from_string('Sans ' . $new_size);
    my $new_metrics = $context->get_metrics($new_fdesc, $language);
    my $new_char_widths = $new_metrics->get_approximate_char_width();
    
    my $new_scalefactor = sprintf "%.1f", $new_char_widths/$old_char_widths;
    
    return $new_scalefactor;
}


# ---------------------------------------------------------------------
# function to update the size, position and font of all widgets
# to scale the gui depending on the gtk changes
# ---------------------------------------------------------------------
sub _update_size_pos_and_font($) {
    my $self = shift;
    my @win_new_font_array = $self->get_font_array($self->{name});
    
    foreach my $name (keys %{$self->{objects}}) {
        my $object = $self->get_object($name);
        my $widget = $object->{ref};
        my $type = $object->{type};

        # update font of the widget if changed in the past
        if (defined($object->{font})) {
            my @obj_font_array = font_string_to_array($object->{font});
            my @win_old_font_array = font_string_to_array($self->{old_font});
            my $changed = 0;
            
            # does object use the default font?
            if ($obj_font_array[0] eq $win_old_font_array[0] and 
                $win_old_font_array[0] ne $win_new_font_array[0]) {
                    $obj_font_array[0] = $win_new_font_array[0];
                    $changed = 1;
            }
            # does object use the default font size?
            if ($obj_font_array[1] eq $win_old_font_array[1] and 
                $win_old_font_array[1] ne $win_new_font_array[1]) {
                    $obj_font_array[1] = $win_new_font_array[1];
                    $changed = 1;
            } else {
                # scale font size
                unless ($win_old_font_array[1] eq $win_new_font_array[1]) {
                    $obj_font_array[1] = $self->_scale($obj_font_array[1]);
                    $changed = 1;
                }
            }
            # does object use the default font weight?
            if ($obj_font_array[2] eq $win_old_font_array[2]) {
                if ($win_old_font_array[2] ne $win_new_font_array[2]) {
                    $obj_font_array[2] = $win_new_font_array[2];
                    $changed = 1;
                }
            }
            
            if ($changed) {
                $self->set_font($name, \@obj_font_array);
            }
        }

        # update position of the widget
        unless ($type =~ /^(toplevel|MenuItem|Menu$|NotebookPage)/) {
            if (defined($object->{container})) {
                my $x = $object->{pos_x};
                my $y = $object->{pos_y};
                my $container = $self->_get_container($object->{container});
                my $container_obj = $self->get_object($object->{container});
                
                # calculate position
                if ($container_obj->{type} eq 'Frame') {
                    ($x, $y) = $self->_get_pos_in_frame($object->{container}, $object->{pos_x}, $object->{pos_y});
                }
                
                $container->move($object->{ref}, $self->_scale($x), $self->_scale($y));
            } else {
                $self->{container}->move($object->{ref}, $self->_scale($object->{pos_x}), $self->_scale($object->{pos_y}));
            }
            $object->{pos_x} = $self->_scale($object->{pos_x});
            $object->{pos_y} = $self->_scale($object->{pos_y});
                        
            # update size of the widget
            unless($type =~ /^(MenuItem|Menu$|NotebookPage|Label)/) {
                unless ($object->{width} and $object->{height}) {
                    my $req = $widget->size_request();
                    $object->{width} = $req->width;
                    $object->{height} = $req->height;
                }
                $self->set_size($object->{name}, $self->_scale($object->{width}), $self->_scale($object->{height}));
            }
        }
    }     
}


# ---------------------------------------------------------------------
# function to add subs to $self->{subs} to execute them between show_all()
# and gtk2->main like drawings
# ---------------------------------------------------------------------
sub _add_subs($@) {
    my $self = shift;
    my ($function, $data) = @_;
    my @keys = keys %{$self->{subs}};
    if (defined($data)) {
        $self->{subs}{scalar @keys} = sub {$function->($data);};
    } else {
        $self->{subs}{scalar @keys} = $function;
    }
}


######################################################################
# Internal callback functions
######################################################################

sub _query_tooltip {
    my ($widget, $x, $y, $keyb, $tooltip) = @_;
    
    return 0 if $keyb;
    
    $tooltip->set_text($widget->get_tooltip_text);
    return 1;
}

sub _on_changed_update {
    my ($widget, $self) = @_;
    
    my $changes;
    my $key;
    
    # get object
    my $object = $self->get_object($widget);
    
    if ($object->{type} eq 'Entry') {
        # get text
        $changes = $object->{ref}->get_text();
        $key = 'title';
        # update object
        $object->{$key} = $changes;
    }
    elsif ($object->{type} eq 'SpinButton') {
        $changes = $object->{ref}->get_value();
        $key = 'value';
        # update object
        $object->{$key} = $changes;
    }    
}


sub _on_font_changed($) {
    my $self = shift;
    my $new_font = $self->get_font_string($self->{name});
    my $changed = 0;
    
    # has font changed?
    if ($new_font ne $self->{font}) {
        # update the main window font
        $self->{old_font} = $self->{font};
        $self->{font} = $self->get_font_string($self->{name});
        $changed = 1;
    }
    
    if ($changed) {
        my $new_fontsize = &get_fontsize($self->{ref});

        # update new font size and scale factor if font size has changed
        if ($new_fontsize != $self->{fontsize}) {
            $self->{old_fontsize} = $self->{fontsize};
            $self->{fontsize} = $new_fontsize;
            $self->{scalefactor} = $self->_calc_scalefactor($self->{base}, $self->{fontsize});
        }
    
        # update size and position of all widgets
        $self->_update_size_pos_and_font();
    
        # and now the window itself
        sleep 1; # needed because window resize faster than the widgets
        my $object = $self->get_object($self->{name});
        $object->{width} = $self->_scale($object->{width});
        $object->{height} = $self->_scale($object->{height});
        $object->{ref}->resize($object->{width}, $object->{height});
        
        # Now the current base can be set if different from fontsize
        if ($self->{scalefactor} != 1) {
            $self->{base} = $self->{fontsize};
            $self->{scalefactor} = 1.0;
        }
    }
}

# Create a new backing pixmap of the appropriate size
sub _configure_event {
    my ($widget, $event, $self) = @_;
    my $object = $self->get_object($widget);
    
    $object->{pixmap} = Gtk2::Gdk::Pixmap->new($widget->window, 
                                     $widget->allocation->width, 
                                     $widget->allocation->height, 
                                     -1);

    $object->{pixmap}->draw_rectangle($widget->style->white_gc,    # or black_gc
                                        1,
                                        0, 
                                        0,
                                        $widget->allocation->width,
                                        $widget->allocation->height);

    my $gc = Gtk2::Gdk::GC->new($object->{pixmap});
    my $colormap = $object->{pixmap}->get_colormap;

    # set a default foreground
    $gc->set_foreground($self->get_color($colormap, 'red'));
    
    return 1;
}


# Redraw the screen from the backing pixmap
sub _expose_event {
    my ($widget, $event, $self) = @_;
    my $object = $self->get_object($widget);

    $widget->window->draw_drawable($widget->style->fg_gc($widget->state), 
                                   $object->{pixmap},
                                   $event->area->x,     $event->area->y,
                                   $event->area->x,     $event->area->y,
                                   $event->area->width, $event->area->height);

   return 0;
}


######################################################################
#   Group: Helpers
#   Helper functions to support things like localization, stderr messages, etc.
######################################################################

# *********************************************************************
#  Class: Localization
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: use_gettext
#   Activate localization via gettext.
#
#   Parameters:
#   <locale_paths>      - Colon separated list of locale paths to search for translations.
#   <translation_file>  - Name of the string translation file.
#   <codeset>           - Name of the used codeset translation file.
#
#   Returns:
#   None.
#
#   Example:
#>  SimpleGtk2::use_gettext("fns-menu-configurator", "$ENV{FVWM_USERDIR}/locale:$ENV{FNS_SYSTEMDIR}/locale:+");
# ---------------------------------------------------------------------
sub use_gettext #(<locale_paths>, <translation_file>, <codeset>)
{
    my ($app_name, $localepaths) = @_;
    # check where's the + if any
    my $add = 'end';
    if ($localepaths =~ m/\+/) {
        $add = 'begin' if $localepaths =~ m/\+$/;
        $localepaths =~ s/^\+://;
        $localepaths =~ s/:\+$//;
    }
    # splitting on ':'
    my @textdomainbinds = split(':', $localepaths);
    # add the default locale paths depending on $add
    my @defaults = ('/usr/local/share/locale', '/usr/share/locale');
    if ($add eq 'end') {
        @textdomainbinds = (@defaults, @textdomainbinds);
    } else {
        @textdomainbinds = (@textdomainbinds, @defaults);
    }
    # get the language_country part of $LANGUAGE
    my @lang_country = split('\.', $LANGUAGE);
    $lang_country[1] = $lang_country[0];
    my @lang = split('_', $lang_country[0]);
    $lang_country[0] = $lang[0];
    
    # now search for the file
    foreach my $path (@textdomainbinds) {
        foreach my $language (@lang_country) {
            my $full_locale_dir = "$path/$language/LC_MESSAGES";
            if (-d $full_locale_dir) {
                next unless (-f "$full_locale_dir/$app_name.mo");
                $GETTEXT = 1;
                $LCDIRECTORY = $path;
                $APPNAME = $app_name;
                Locale::gettext::bindtextdomain($APPNAME, $LCDIRECTORY);
                Locale::gettext::textdomain($APPNAME);
                return;
            }
        }
    }
}

# ---------------------------------------------------------------------
# internal translation function used inside of SimpleGtk2
# ---------------------------------------------------------------------
sub _ {
    my $text = shift;
    return ($GETTEXT == 1 ? decode("utf-8", Locale::gettext::gettext($text)) : $text);
}

# ---------------------------------------------------------------------
#   Function: translate
#   Translation function used to translate text parts interrupted by variables.
#
#   Parameters:
#   <text>  - Text string to translate.
#
#   Returns:
#   The translated text or its' original.
#
#   Example:
#>  my $multi_menu_title = $win->translate('Menus in') . ' ' . $key;
# ---------------------------------------------------------------------
sub translate #(<text>)
{
    my $self = shift;
    my $text = shift;
    $text =~ s/\R\h+//g;
    return _($text);
}


# *********************************************************************
#   Class: Messages
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: internal_die
#   Internal die function if a fatal error occurs.
#
#   This may be used to end the program with a corresponding message. 
#   For a clean exit use <showError> instead. 
#
#   Parameters:
#   <msg>   - Die message printed to stderr.
#
#   Returns:
#   A die message before exiting the program.
#
#   Example:
#>  $win->internal_die($object, "No action defined!");
#
#   Output:
#>  [$win->$ExitButton]: No action defined! Exiting.
# ---------------------------------------------------------------------
sub internal_die #(<msg>)
{
    my $self = shift;
    my ($object, $msg) = @_;
    $msg =~ s/([^\.!?])$/$1./;
    if (defined($msg)) {
        die $self->{name} . "->$object->{name}: $msg Exiting.\n";
    } else {
        die $self->{name} . ": $msg Exiting.\n";
    }
}


# ---------------------------------------------------------------------
#   Function: show_error
#   Print an error message to standard error.
#
#   Parameters:
#   <msg>   - Error message.
#
#   Returns:
#   None.
#
#   Example:
#>  $win->show_error($nb_object, "No notebook page with number \"$number\" found.");
#
#   Output:
#>  [$win->$nb1][err]: No notebook page with number "123" found.
# ---------------------------------------------------------------------
sub show_error #(<msg>)
{
    my $self = shift;
    my ($object, $msg) = @_;
    if (defined($msg)) {
        print STDERR "[" . $self->{name} . "->$object->{name}][err]: $msg\n";
    } else {
        print STDERR "[" . $self->{objects}->{$self->{name}}->{title} . "][err]: $object\n";
    }
}


# ---------------------------------------------------------------------
#   Function: show_message
#   Print a message to standard error.
#
#   Parameters:
#   <msg>   - Message text.
#
#   Returns:
#   None.
#
#   Example:
#>  $win->show_message("xcompmgr not installed. Ignoring.");
#
#   Output:
#>  [FNS-CompConfigurator][msg]: xcompmgr not installed. Ignoring.
# ---------------------------------------------------------------------
sub show_message #(<msg>)
{
    my $self = shift;
    my ($object, $msg) = @_;
    if (defined($msg)) {
        print STDERR "[" . $self->{name} . "->$object->{name}][msg]: $msg\n";
    } else {
        print STDERR "[" . $self->{objects}->{$self->{name}}->{title} . "][msg]: $object\n";
    }
}


######################################################################
#   Group: Support Functions
#   Common functions for signaling, object handling, etc.
######################################################################

# *********************************************************************
#   Class: Signaling
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_signal_handler
#   Adds a signal handler to a widget.
#
#   It connects a signal to a sub procedure related to the widget.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#   <signal>    - Signal which will be "emitted" by the widget. See <Gtk2+ documentation at https://developer.gnome.org/gtk2/stable/index.html> for more info.
#   <function>  - Function to be executed if signal appears.
#   [<data>]    - Optional. The data you wish to have passed to this function.
#
#   Returns:
#   None.
#
#   Examples:
#>  $win->add_signal_handler('closeButton', 'clicked', sub{Gtk2->main_quit;});
#>  --------------------------------------
#>  $win->add_signal_handler('changeIconDir', 'clicked', \&change_path, [$win, 'entryIconDir']);
# ---------------------------------------------------------------------
sub add_signal_handler #(<name>, <signal>, <function>, [<data>])
{
    my $self = shift;
    my ($name, $signal, $function, $data) = @_;
    my $id;
    # is it the window itself?
    if ($name eq $self->{name}) {
        $id = $self->{ref}->signal_connect($signal, $function, $data);
        # add id for removing in handler hash
        $self->{handler}->{$signal} = $id;
    # or the others?
    } else {
        my $object = $self->get_object($name);
        if ($object->{type} eq 'NotebookPage' and $signal eq 'query_tooltip') {
            $id = $object->{pagelabel}->signal_connect($signal, $function, $data);
        }
        elsif ($object->{type} eq 'DrawingArea') {
            $id = $object->{drawing_area}->signal_connect($signal, $function, $data);
        }
        elsif ($object->{type} =~ /List|Tree/) {
            $id = $object->{treeview}->signal_connect($signal, $function, $data);
        }
        else {
            $id = $object->{ref}->signal_connect($signal, $function, $data);
        }
        $object->{handler}->{$signal} = $id;
    }
}

# ---------------------------------------------------------------------
#   Function: remove_signal_handler
#   Removes a signal handler (signal-function pair) from a widget.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#   <signal>    - Signal which should removed from the widget.
#
#   Returns:
#   None.
#
#   Examples:
#>  $win->remove_signal_handler('closeButton', 'clicked');
#>  --------------------------------------
#>  $win->remove_signal_handler('changeIconDir', 'clicked');
# ---------------------------------------------------------------------
sub remove_signal_handler #(<name>, <signal>)
{
    my $self = shift;
    my ($name, $signal) = @_;
    
    my $object = $self->get_object($name);
    my $id = $object->{handler}->{$signal};
    
    $object->{ref}->signal_handler_disconnect($id);
    delete $object->{handler}->{$signal};
}


# *********************************************************************
#   Class: Object Handling
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: get_object
#   Get the SimpleGtk2 widget hash from internal objects list.
#
#   Parameters:
#   <name>      - Name of a widget. Must be unique.
#   *OR*
#   <widget>    - Reference object of a widget (e.g. Gtk2::Button).
#
#   Returns:
#   Object hash
#
#   Examples:
#>  # with name
#>  $win->get_object('NB_page' . $number)->{pagelabel}->set_sensitive($state);
#>  --------------------------------------
#>  # with widget reference
#>  my $object_name = $win->get_object($widget)->{name};
# ---------------------------------------------------------------------
sub get_object #(<name|widget>)
{
    my $self = shift;
    my $identifier = shift;
    my $object = undef;
    if (ref($identifier) =~ m/^Gtk2::/) {
        my $entry = 'ref';
        if (ref($identifier) =~ m/^Gtk2::DrawingArea/) {
            $entry = 'drawing_area';
        }
        foreach (keys %{$self->{objects}}) {
            if (defined($self->{objects}->{$_}->{$entry})) {
                if ($self->{objects}->{$_}->{$entry} == $identifier) {
                    $object = $self->{objects}->{$_};
                }
            }
        }
    } else {
        $object = $self->{objects}->{$identifier};
    }
    $self->internal_die($identifier, "No object found!") unless defined($object);
    return $object;
}


# ---------------------------------------------------------------------
#   Function: exist_object
#   Check function if SimpleGtk2 object xyz exists.
#
#   Parameters:
#   <name>      - Name of a widget. Must be unique.
#   *OR*
#   <widget>    - Gtk2 reference object of a widget (e.g. Gtk2::Button).
#
#   Returns:
#   1 if true else 0.
#
#   Example:
#>  if (defined($win->exist_object('entrySplashPath'))) { ... }
# ---------------------------------------------------------------------
sub exist_object #(<name|widget>)
{
    my $self = shift;
    my $identifier = shift;
    my $exist = 0;
    if (ref($identifier) =~ m/^Gtk2::/) {
        foreach (keys %{$self->{objects}}) {
            if (ref($self->{objects}->{$_}->{ref}) eq ref($identifier)) {
                $exist = 1;
            }
        }
    } else {
        if (defined($self->{objects}->{$identifier})) {
            $exist = 1;
        }
    }
    return $exist;
}


# *********************************************************************
#   Class: Widget Handling
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: get_widget
#   Get a Gtk2 widget reference of a SimpleGtk2 object.
#
#   Restriction:
#   Not available for the following widget: <GtkNotebookPage>.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#
#   Returns:
#   A Gtk2 widget reference.
#
#   Example:
#>  $win->add_signal_handler('checkEnabled' . $name_number, 'toggled', sub {&on_checkbox_enabled_toggled($win->get_widget('comboResolution' . $name_number), $name);});
# ---------------------------------------------------------------------
sub get_widget #(<name>)
{
    my $self = shift;
    my $name = shift;
    my $object = $self->get_object($name);
    my $widget_ref;
    unless ($object->{type} =~ /^(Image|Statusbar|TextView|MenuBar|Separator|DrawingArea)$/) {
        $widget_ref = $self->{objects}->{$name}->{ref};
    } else {
        unless ($object->{type} eq 'NotebookPage') {
            if ($object->{type} eq 'Image') {$widget_ref = $object->{image};}
            elsif ($object->{type} eq 'Statusbar') {$widget_ref = $object->{statusbar};}
            elsif ($object->{type} eq 'TextView') {$widget_ref = $object->{textview};}
            elsif ($object->{type} eq 'MenuBar') {$widget_ref = $object->{menubar};}
            elsif ($object->{type} eq 'Separator') {$widget_ref = $object->{separator};}
            elsif ($object->{type} eq 'DrawingArea') {$widget_ref = $object->{drawing_area};}
            elsif ($object->{type} =~ /List|Tree/) {$widget_ref = $object->{treeview};}
        } else {
            $self->internal_die("$name is a notebook page which hasn't an own widget reference!");
        }
    }

    return $widget_ref;
}


# ---------------------------------------------------------------------
# get internal object widget reference
# _get_ref(<name>)    <= must be unique
# ---------------------------------------------------------------------
sub _get_ref($$) {
    my $self = shift;
    my $name = shift;
    return $self->{objects}->{$name}->{ref};
}


# ---------------------------------------------------------------------
#   Function: hide_widget
#   Hide a widget.
#
#   Restriction:
#   Not available for the following widgets: <GtkMenu>, <GtkMenuItem>, <GtkMenuBar> and <GtkNotebookPage>.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#
#   Returns:
#   None.
#
#   Example:
#>  $win->add_signal_handler('image1', 'button_press_event', sub{$win->hide_widget('frame1');});
# ---------------------------------------------------------------------
sub hide_widget #(<name>)
{
    my $self = shift;
    my $name = shift;

    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless($type =~ /(MenuBar|MenuItem$|Menu$|NotebookPage)/) {
        $object->{ref}->hide();
    } else {
        $self->show_error($object, "For \"$type\" use set_sensitive() instead.");
        return;
    }
}


# ---------------------------------------------------------------------
#   Function: show_widget
#   Show a hidden widget.
#
#   Restriction:
#   Not available for the following widgets: <GtkMenu>, <GtkMenuItem>, <GtkMenuBar> and <GtkNotebookPage>.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#
#   Returns:
#   None.
#
#   Example:
#>  $win->add_signal_handler('image1', 'button_press_event', sub{$win->show_widget('frame1');});
# ---------------------------------------------------------------------
sub show_widget #(<name>)
{
    my $self = shift;
    my $name = shift;

    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless($type =~ /(MenuBar|MenuItem$|Menu$|NotebookPage)/) {
        $object->{ref}->show();
    } else {
        $self->show_error($object, "For \"$type\" use set_sensitive() instead.");
        return;
    }
}


# ---------------------------------------------------------------------
#   Function: is_sensitive
#   Returns the sensitive state of a widget.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#
#   Returns:
#   The sensitive state - 0 (inactive) or 1 (active).
#
#   Example:
#>  my $state = $win->is_sensitive('Check1');
# ---------------------------------------------------------------------
sub is_sensitive #(<name>)
{
    my $self = shift;
    my $name = shift;
    
    # get widget
    my $widget = $self->_get_ref($name);
    
    return $widget->is_sensitive();
}


# ---------------------------------------------------------------------
#   Function: set_sensitive
#   Set sensitivity of a widget, a radio group or notebook page.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#   *OR*
#   <group>     - Name of the radio group. Must be unique.
#   <state>     - New sensitivity state of the widget/radio group/notebook page.
#                 0 (inactive) or 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#>  # deactivation of a radio group
#>  $win->set_sensitive('r_state', 0);
# ---------------------------------------------------------------------
sub set_sensitive #(<name|group>, <state>)
{
    my $self = shift;
    my ($name, $state) = @_;
    my $widget;
    
    # check if it is a widget or a group
    if (exists $self->{objects}->{$name}) {
        # get widget object
        my $object = $self->get_object($name);
        
        if ($object->{type} eq 'Menu') {
            $object->{title_item}->set_sensitive($state);
        }
        elsif ($object->{type} eq 'NotebookPage') {
            # set the viewport instead of the scrolled window sensitive
            # to let the scrollbars active
            $object->{viewport}->set_sensitive($state);
            # set sentivity of the label, too
            $object->{pagelabel}->set_sensitive($state);
        } else {
            $object->{ref}->set_sensitive($state);
        }
    } else {
        if (exists $self->{groups}->{$name}) {
            $widget = $self->_get_ref($self->{groups}->{$name}[0]);
            my $group = $widget->get_group();
            foreach (@$group) {
                $_->set_sensitive($state);
            }
        } else {
            $self->internal_die("$name not found - neither in objects nor in groups list!");
        }
    }
}


# ---------------------------------------------------------------------
#   Function: get_title
#   Returns the title text of a widget or the active value of a combo box.
#
#   Restriction:
#   Not available for the following widgets: <GtkSlider>, <GtkScrollBar>, <GtkImage>, <GtkTextView>, <GtkMenuBar>, <GtkNotebook>.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#
#   Returns:
#   The title text or undef.
#
#   Examples:
#>  # check whether a combo box value is currently set
#>  unless ($win->get_title('comboWindow') eq 'TopLeft') {
#>      &set_config_value('WindowsPlacement', $win->get_title('comboWindow'));
#>  }
#>  --------------------------------------
#>  # print window title with message to standard error
#>  print STDERR "[" . $win->get_title($win->{name}) . "]: $user_cfg saved.\n";
# ---------------------------------------------------------------------
sub get_title #(<name>)
{
# ---------------------------------------------------------------------
# TODO: Perhaps it has to changed to widget specific get functions
# ---------------------------------------------------------------------
    my $self = shift;
    my $name = shift;
    
    # get object
    my $object = $self->get_object($name);
    my $type = $object->{type};
    my $title = $object->{title};
    
    if ($type eq 'ComboBox'){
        my $index = $object->{ref}->get_active();
        unless ($index == -1) {
            $title = $object->{data}[$index]
        }
    }
    elsif ($type =~ /^(Slider|ScrollBar|Image|TextView|MenuBar|Notebook$)/){
        $self->show_error($object, "\"$type\" hasn't a title!");
        return undef;
    }
    return $title;
}


# ---------------------------------------------------------------------
#   Function: set_title
#   Sets the new title text of a widget or the active value of a combo box.
#
#   Restriction:
#   Not available for the following widgets: <GtkSlider>, <GtkScrollBar>, <GtkImage>, <GtkTextView>, <GtkMenuBar>, <GtkNotebook>.
#
#   Parameters:
#   <name>          - Name of the widget. Must be unique.
#   <new_title>     - New title text for the widget or new active value for the combo box.
#
#   Returns:
#   None.
#
#   Examples:
#>  # set label text depending on the current max virt size
#>  $win->set_title('labelMaxSizeValue', $xrandr->getMaxVirtSize());
#>  --------------------------------------
#>  # set new title of the notebook page 2
#>  $win->set_title("NB_page2", "1Bibbile");
# ---------------------------------------------------------------------
sub set_title #(<name>, <new_title>)
{
    my $self = shift;
    my ($name, $new_title) = @_;
    
    # get widget object
    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    # change title in widget
    if ($type =~ m/(^|k|o)Button$|^Frame|^Label/) {
        $object->{ref}->set_label($new_title);
    }
    elsif ($type =~ m/^Entry/) {
        $object->{ref}->set_text($new_title);
    }
    elsif ($type =~ m/^ComboBox/) {
        my @array = $object->{data};
        my $index = grep {$array[$_] =~ /^$new_title/} 0..$#array;
        unless ($index > 0) {
            $object->{ref}->set_active($index);
        } else {
            $self->show_error($object, "Can't set title \"$new_title\" - not found!");
            return;
        }
    }
    elsif ($type =~ m/^Menu|^Font/){
        $object->{ref}->set_title($new_title);
    }
    elsif ($type eq 'NotebookPage'){
        $object->{pagelabel}->set_label($new_title);
        # update menu if active
        my $nb_object = $self->get_object($object->{notebook});
        # workaround - not fine but works ;-)
        if ($nb_object->{popup}) {
            $nb_object->{ref}->popup_disable();
            $nb_object->{ref}->popup_enable();
        }
    }
    else {
        $self->show_error($object, "Can't set title \"$new_title\" - wrong type \"$type\"!");
        return;
    }
    
    # update title in object
    $object->{title} = $new_title;
}


# ---------------------------------------------------------------------
#   Function: get_size
#   Returns the current width and height (in pixel) of a widget.
#
#   Restriction:
#   Not available for the following widgets: <GtkMenu>, <GtkMenuItem>, <GtkNotebookPage>.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#
#   Returns:
#   An array of the current width and height or undef.
#
#   Example:
#>  my ($width, $height) = $win->get_size('Image1');
# ---------------------------------------------------------------------
sub get_size #(<name>)
{
    my $self = shift;
    my $name = shift;

    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless($type =~ /^(MenuItem|Menu$|NotebookPage)/) {
        return ($object->{width}, $object->{height})
    } else {
        $self->show_error($object, "For \"$type\" no size avaliable!");
        return;
    }
}


# ---------------------------------------------------------------------
#   Function: set_size
#   Sets the new size of a widget.
#
#   Restriction:
#   Not available for the following widgets: <GtkCheckButton>, <GtkRadioButton>, <GtkLabel>, <GtkMenu>, <GtkMenuItem>, <GtkNotebookPage>.
#
#   Parameters:
#   <name>              - Name of the widget. Must be unique.
#   <new_width>         - New width of the widget.
#   <new_height>        - New height of the widget.
#
#   Returns:
#   None.
#
#   Example:
#>  $win->set_size('image1', 200, 100);
# ---------------------------------------------------------------------
sub set_size #(<name>, <new_width>, <new_height>)
{
    my $self = shift;
    my ($name, $width, $height) = @_;
    
    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless ($type =~ m/^(Check|Radio|Label|Image|MenuItem|Menu$|NotebookPage)/) {
        $object->{ref}->set_size_request($width, $height);
    }
    elsif ($type =~ m/^Image/) {
        # scale pixbuf and create a new image
        my $scaled = $object->{pixbuf}->scale_simple($width, $height, 'bilinear');
        my $new_image = Gtk2::Image->new_from_pixbuf($scaled);
        
        # get old image and remove it from eventbox
        my $old_image = $object->{image};
        $object->{ref}->remove($old_image);
        
        # add new image to eventbox
        $object->{ref}->add($new_image);
        
        # and resize the eventbox to fit the bigger/smaller image 
        $object->{ref}->set_size_request($width, $height);
        
        # exchange the old with the new image reference
        $object->{image} = $new_image;
        
        # and show it
        $new_image->show();
    }
    else {
        $self->show_error($object, "\"$type\" isn't resizable!");
        return;
    }

    # update object
    $object->{width} = $width;
    $object->{height} = $height;
}


# ---------------------------------------------------------------------
#   Function: get_pos
#   Returns the current position (in pixel) of a widget.
#
#   Restriction:
#   Not available for the following widgets: <GtkMenu>, <GtkMenuItem>, <GtkNotebookPage>.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#
#   Returns:
#   An array of the current x and y position or undef.
#
#   Example:
#>  my ($pos_x, $pos_y) = $win->get_pos('cbox1');
# ---------------------------------------------------------------------
sub get_pos #(<name>)
{
    my $self = shift;
    my $name = shift;
    
    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless($type =~ /^(MenuItem|Menu$|NotebookPage)/) {
        return ($object->{pos_x}, $object->{pos_x})
    } else {
        $self->show_error($object, "For \"$type\" no position avaliable!");
        return;
    }
}


# ---------------------------------------------------------------------
#   Function: set_pos
#   Sets the new position of a widget.
#
#   Restriction:
#   Not available for the following widgets: <GtkMenu>, <GtkMenuItem>, <GtkNotebookPage>.
#
#   Parameters:
#   <name>          - Name of the widget. Must be unique.
#   <new_x>         - New x-position of the widget.
#   <new_y>         - New y-position of the widget.
#
#   Returns:
#   None.
#
#   Example:
#>  $win->set_pos('check_button', 10, 45);
# ---------------------------------------------------------------------
sub set_pos #(<name>, <new_x>, <new_y>)
{
    my $self = shift;
    my ($name, $pos_x, $pos_y) = @_;

    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless($type =~ /^(MenuItem|Menu$|NotebookPage)/) {
        if (defined($object->{container})) {
            my $container = $self->_get_container($object->{container});
            my $frame = $self->get_object($object->{container});
                
            # calculate position
            my ($x, $y) = $self->_get_pos_in_frame($object->{container}, $pos_x, $pos_y);
            
            $container->move($object->{ref}, $x, $y);
        } else {
            $self->{container}->move($object->{ref}, $pos_x, $pos_y);
        }
    
        # update object
        $object->{$pos_x} = $pos_x;
        $object->{$pos_y} = $pos_y;
    } else {
        $self->show_error($object, "\"$type\" cannot change the position!");
        return;
    }

}


# ---------------------------------------------------------------------
#   Function: is_active
#   Returns the state of Check- and RadioButtons or for given combobox value/string.
#
#   Parameters:
#   <name>              - Name of the widget. Must be unique.
#   <value/string>      - A given combobox value/string.
#
#   Returns:
#   An array of the current x and y position or undef.
#
#   Example:
#>  my ($pos_x, $pos_y) = $win->get_pos('cbox1');
# ---------------------------------------------------------------------
sub is_active #(<name>, [<value/string>])
{
    my $self = shift;
    my ($name, $value) = @_;
    
    # get object and type
    my $object = $self->get_object($name);
    my $type = $object->{type};

    my $rc = 0;
    
    # only these types has an active state
    if ($type =~ m/^(CheckButton|RadioButton)/) {
        $rc = $object->{ref}->get_active();
        $rc = 0 if $rc eq ''; # get_active() provides '' on uncheck
    }
    elsif ($type eq 'ComboBox'){
        my $current = $object->{ref}->get_active();
        unless ($current == -1) {
            # number?
            if ($value =~ /^\d+?$/) {
                if ($value == $object->{data}[$current]) {
                    $rc = 1;
                }
            # string
            } else {
                if ($value eq $object->{data}[$current]) {
                    $rc = 1;
                }
            }
        }
    }
    else {
        $self->show_error($object, "\"$type\" hasn't an active state!");
   } 
   return $rc;
}


# ---------------------------------------------------------------------
#   Function: is_underlined
#   Returns the state of a text whether it has an underline.
#
#   Parameters:
#   <text>              - Text to check.
#
#   Returns:
#   1 for underlined else 0.
#
#   Example:
#>  if ($win->is_underlined($object->{title})) { ... }
# ---------------------------------------------------------------------
sub is_underlined #(<text>)
{
    my $self = shift;
    my $text = shift;
    
    # remove double underlines
    $text =~ s/__//;
    
    my $underlined = $text =~ /_/ ? 1 : 0;
    return $underlined;
#   return ($text =~ /_/ ? 1 : 0); <= the same ^^
}


# ---------------------------------------------------------------------
#   Function: get_value
#   Returns a current value of a widget.
#
#   Parameters:
#   <name>                      - Name of a widget.
#   <keyname>                   - Keyword of a value.
#   *OR*
#   <keyname> => <value>        - Nth value of the keyword array|hash.
#   
#   _KEYNAMES_: 
#   
#   GtkCheckButton: 
#   "Active"                    - The current state of the check button.
#   
#   GtkRadioButton: 
#   "Active"                    - The current state of the radio button.
#   "Group"                     - The current group object/reference.
#   "Groupname|Gname"           - The current group name (string).
#   
#   GtkLinkButton:  
#   "Uri"                       - The current uri of the link button.
#   
#   GtkFontButton:  
#   "Fontstring"                - The current font string (family, size, weight) of the font button.
#   "Fontfamily"                - The current font family.
#   "Fontsize"                  - The current font size.
#   "Fontweight"                - The current font weight.
#   
#   GtkLabel:   
#   "Wrap|Wrapped"              - Returns whether lines in the label are automatically wrapped.
#   "Justify"                   - The current justification of the label.
#   
#   GtkEntry:   
#   "Align"                     - The current alignment string of the entry.
#   
#   GtkSpinButton:  
#   "Active"                    - The current active value of the spin button.
#   "Align"                     - The current alignment for the contents.
#   "Min|Minimum"               - The current minimum value.
#   "Max|Maximum"               - The current maximum value.
#   "Step"                      - The current step increment.
#   "Snap"                      - Returns whether the values are corrected to the nearest step.
#   "Rate|Climbrate"            - The current amount of acceleration that the spin button actually has.
#   "Digits"                    - The current number of decimal places the value is displayed.
#   
#   GtkComboBox:    
#   "Active"                    - The current index of the active value.
#   "Data"                      - The current data array of the combo box.
#   "Columns"                   - The current number of columns to display.
#   
#   GtkSlider:  
#   "Active"                    - The current active value of the slider.
#   "Min|Minimum"               - The current minimum value.
#   "Max|Maximum"               - The current maximum value.
#   "Step"                      - The current step increment.
#   "DrawValue"                 - The current active value as a string.
#   "ValuePos|ValuePosition"    - The position in which the current value is displayed.
#   "Digits"                    - The current number of decimal places the value is displayed.
#
#   GtkScrollbar:
#   "Active"                    - The current active value of the scrollbar.
#   "Min|Minimum"               - The current minimum value.
#   "Max|Maximum"               - The current maximum value.
#   "Step"                      - The current step increment.
#   "Digits"                    - The current number of decimal places the value is displayed.
#
#   GtkTextView:
#   "LeftMargin"                - The current left margin size of paragraphs in the text view.
#   "RightMargin"               - The current right margin size of paragraphs.
#   "Wrap|Wrapped"              - The current wrap mode.
#   "Justify"                   - The current justification.
#
#   *Note:* "Path", "Textview" and "Textbuf|Textbuffer" can get with <get_textview>.
#   
#   GtkMenu:    
#   "Justify"                   - The current justification of the menu.
#   
#   GtkMenuItem:    
#   "IconPath"                  - The current path of the used icon on a standard menu item or undef.
#   "StockIcon"                 - The current stock id of the used stock icon or undef.
#   "IconName"                  - The current name of the used theme icon or undef.
#   "Icon"                      - The current path/stock id/name of the used icon or undef.
#   "Active"                    - The current state of a radio menu item.
#   "Group"                     - The current group object/reference.
#   "Groupname|Gname"           - The current group name (string).
#   
#   GtkNotebook:    
#   "Current|CurrentPage"       - The page number of the current page.
#   "Pages"                     - The number of pages in the notebook.
#   "Popup"                     - Returns 1 whether the popup is activated. Else 0.
#   "No2Name|Number2Name"       - The page name with the page number.
#   "Scroll|Scrollable"         - Returns whether the tab label area has arrows for scrolling.
#   "Tabs"                      - The edge at which the tabs are drawn or "none".
#   
#   GtkNotebookPage:    
#   "PageNumber"                - The page number of the notebook page.
#   "Notebook"                  - The name of the notebook.
#   
#   GtkFontButton:  
#   "fontstring"                - The string of the current font e.g "Arial Rounded MT Bold, Bold Italic 12".
#   "fontfamily"                - The current font family ("Arial Rounded MT Bold").
#   "fontsize"                  - The current font size ("12").
#   "fontweight"                - The current font weight ("Bold Italic").
#       
#   GtkFontSelectionDialog: 
#   "previewstring"             - The current preview text of the font selection dialog.
#   "fontstring"                - The current font string e.g "Arial Rounded MT Bold, Bold Italic 12".
#   "fontfamily"                - The current font family ("Arial Rounded MT Bold").
#   "fontsize"                  - The current font size ("12").
#   "fontweight"                - The current font weight ("Bold Italic").
#   
#   GtkStatusbar:   
#   "message"                   - The text for the given message-id
#   "msgid"                     - The message id for the given text. If "last" is given the last message id.
#   "stackref"                  - The stack reference.
#   "stackcount"                - The stack count.
#
#   GtkTreeView::List:
#   "editable"                  - Whether the in-place editing on column <index> is enabled (1).
#   "path"                      - The path of row <index> (0 indexed) or the paths if an index array is given.
#   "cell"                      - The value of a cell given as an array with [<row_index>, <column_index>] 0 indexed.
#
#   GtkTreeView::Tree:
#   "iter"                      - The iter of the current selected element.
#   "path"                      - The path of the current selected element.
#   "row"                       - The row values as an array of the given iter.
#
#   Returns:
#   The found value.
#
#   Examples:
#>  if ($win->get_value("comboMaxFreq" . $a, "active") != $win->get_value("comboMaxFreqCommon", "active")) { ... }
#>  --------------------------------------
#>  my $rowref = $window->get_value("slist", path => $index);
# ---------------------------------------------------------------------
sub get_value #(<name>, <keyname>, or <keyname> => <value>)
{
    my $self = shift;
    my $name = shift;
    my @key_value = @_;
    my $key = $key_value[0];
    $key = _extend(lc($key)) if defined($key);
    my $value = 'Error';
    
    # get widget object
    my $object = $self->get_object($name);

    # Check and Radio button
    if ($object->{type} =~ /^(Check|Radio)/) {
        if    ($key eq 'active') {$value = $object->{ref}->is_active();}
    }
    
    # Radio button and menu
    elsif ($object->{type} =~ /^Radio/) {
        # radio button/menu group object
        if    ($key eq 'group') {$value = $object->{ref}->get_group();}
        # radio button/menu group name
        elsif    ($key eq 'groupname') {$value = $object->{group};}
    }

    # Link button
    elsif ($object->{type} eq 'LinkButton') {
        # get uri
        if    ($key eq 'uri') {$value = $object->{ref}->get_uri();}
    }
    
    # Label
    elsif ($object->{type} eq 'Label') {
        # line wrap
        if    ($key eq 'wrapped') {$value = $object->{ref}->get_line_wrap();}
        # justification of label
        elsif ($key eq 'justify') {$value = $object->{ref}->get_justify();}
    }
    
    # Text entry
    elsif ($object->{type} eq 'entry') {
        # alignment
        if    ($key eq 'align') {$value = $object->{ref}->get_alignment();}
    }
    
    # Spin button
    elsif ($object->{type} eq 'SpinButton') {
        # alignment of values
        if    ($key eq 'align') {$value = $object->{ref}->get_alignment();}
        # minimum value
        elsif ($key eq 'minimum') {$value = $object->{adjustment}->lower();}
        # maximum value
        elsif ($key eq 'maximum') {$value = $object->{adjustment}->upper();}
        # steps
        elsif ($key eq 'step') {$value = $object->{adjustment}->step_increment();}
        # start/active value
        elsif ($key eq 'active') {$value = $object->{ref}->get_value();}
        # digits
        elsif ($key eq 'digits') {$value = $object->{ref}->get_digits();}
        # climbrate
        elsif ($key eq 'climbrate') {$value = $object->{climbrate};}
        # snap to ticks
        elsif ($key eq 'snap') {$value = $object->{ref}->get_snap_to_ticks();}
    }
    
    # Combo box
    elsif ($object->{type} eq 'ComboBox') {
        # index of active value, else -1
        if    ($key eq 'active') {$value = $object->{ref}->get_active();}
        # columns
        elsif ($key eq 'columns') {$value = $object->{ref}->get_wrap_width();}
        # data array
        elsif ($key eq 'data') {$value = $object->{data};}
    }

    # Slider and Scroll bar
    elsif ($object->{type} =~ /^(Slider|Scrollbar)/) {
        # minimum value
        if    ($key eq 'minimum') {$value = $object->{adjustment}->lower();}
        # maximum value
        elsif ($key eq 'maximum') {$value = $object->{adjustment}->upper();}
        # steps
        elsif ($key eq 'step') {$value = $object->{adjustment}->step_increment();}
        # start/active value
        elsif ($key eq 'active') {$value = $object->{adjustment}->value();}
        # digits
        elsif ($key eq 'digits') {$value = $object->{ref}->get_digits();}
        
        if ($object->{type} eq 'Slider') {
            # draw value
            if    ($key eq 'drawvalue') {$value = $object->{ref}->get_draw_value();}
            # digits of value
            elsif ($key eq 'digits') {$value = $object->{ref}->get_digits();}
            # position of the draw value
            elsif ($key eq 'valueposition') {$value = $object->{ref}->get_value_pos();}
        }
    }
    
    # Image
    elsif ($object->{type} eq 'Image') {
        # not supported
        $self->internal_die($object, "'get_value' doesn't support \"$key\". Use 'get_image' instead.");
    }
    
    # Text view
    elsif ($object->{type} eq 'TextView') {
        # get margins
        if ($key eq 'leftmargin') {$value = $object->{textview}->get_left_margin();}
        elsif ($key eq 'rightmargin') {$value = $object->{textview}->get_right_margin();}
        # get wrap mode
        elsif ($key eq 'wrapped') {$value = $object->{textview}->get_wrap_mode();}
        # get justification
        elsif ($key eq 'justify') {$value = $object->{textview}->get_justification();}
        # not supported
        elsif ($key =~ /^(path|textbuffer)/) {
            $self->internal_die($object, "'get_value' doesn't support \"$key\". Use 'get_textview' instead.");
        }
    }
    
    # Menu
    elsif ($object->{type} eq 'Menu') {
        # get justification
        if ($key eq 'justify') {$value = $object->{title_item}->get_right_justified() == 1 ? 'right' : 'left';}
    }
    
    # Menu item
    elsif ($object->{type} eq 'MenuItem') {
        # get icon path
        if ($key =~ /icon/) {
            my $icon = $object->{icon};
            my $match = 0;

            if (defined($icon)) {
                # general
                if ($key eq 'icon') {$match = 1;}
                # stock icon?
                elsif ($icon =~ /^gtk-/ and $key eq 'stockicon') {$match = 1;}
                # path ?
                elsif (-e $icon and $key eq 'iconpath') {$match = 1;}
                # name
                elsif ($key eq 'iconname') {$match = 1;}
            }
            
            unless ($match) {$icon = undef;}
            
            return $icon;
        }
    }
    
    # Notebook
    elsif ($object->{type} eq 'Notebook') {
        # get current page
        if ($key eq 'currentpage') {$value = $object->{ref}->get_current_page();}
        # get count of pages
        elsif ($key eq 'pages') {$value = $object->{ref}->get_n_pages();}
        # popup active?
        elsif ($key eq 'popup') {$value = $object->{popup};}
        # get page number with page name
        elsif ($key eq 'name2number') {
            # get count of pages
            my $pages = $object->{ref}->get_n_pages();
            my $i = 0;
            while ($i < $pages) {
                # get page widget
                my $page = $object->{ref}->get_nth_page($i);
                my $page_object = $self->get_object($page);
                if ($page_object->{name} eq $key_value[1]) {
                    $value = $i;
                    last;
                }
                $i += 1;
            }
        }
        # get page name with number
        elsif ($key eq 'number2name') {
            # get page widget
            my $page = $object->{ref}->get_nth_page($key_value[1]);
            my $page_object = $self->get_object($page);
            $value = $page_object->{name};
        }
        # get page number with page title
        elsif ($key eq 'title2number') {
            # get count of pages
            my $pages = $object->{ref}->get_n_pages();
            my $i = 0;
            while ($i < $pages) {
                # get page widget
                my $page = $object->{ref}->get_nth_page($i);
                my $page_object = $self->get_object($page);
                if ($page_object->{title} eq $key_value[1]) {
                    $value = $i;
                    last;
                }
                $i += 1;
            }
        }
        elsif ($key eq 'number2title') {
            # get page widget
            my $page = $object->{ref}->get_nth_page($key_value[1]);
            my $page_object = $self->get_object($page);
            $value = $page_object->{title};
        }
        # is scrollbar active?
        elsif ($key eq 'scrollable') {$value = $object->{ref}->get_scrollable();}
        # tabs shown or position
        elsif ($key eq 'tabs') {
            if ($object->{ref}->get_show_tabs()) {
                $value = $object->{ref}->get_tab_pos();
            } else {
                $value = 'none';
            }
        }
        elsif ($key =~ /^(pagenumber|notebook)/) {
            $self->internal_die($object, "Parameter \"$key\" used with type 'NotebookPage' only.");
        }
    }
    
    # Notebook page
    elsif ($object->{type} eq 'NotebookPage') {
        # get number with page name
        if ($key eq 'pagenumber') {$value = $object->{notebook}->page_num($object->{ref});}
        # get allocated notebook name
        elsif ($key eq 'notebook') {
            my $nb_object = $self->get_object($object->{notebook});
            $value = $nb_object->{name};
        }
        elsif ($key =~ /^(scrollable|currentpage|pagination|no2name|tabs|popup)/) {
            $self->internal_die($object, "Parameter \"$key\" used with type 'Notebook' only.");
        }
    }

    # Font button and Font selection dialog
    elsif ($object->{type} =~ /^(FontButton|FontSelectionDialog)/) {
        # first get complete font as string from object
        my $font = $object->{font};
        # get preview string
        if ($key eq 'previewstring' and $object->{type} eq 'FontSelectionDialog') {
            $value = $object->{preview};
        }
        # get font string
        elsif ($key eq 'fontstring') {
            $value = $font;
        } else {
            my @fontarray = [undef, undef, undef];
            my $fontdescription = Pango::FontDescription->from_string($font);
            my $family = $fontdescription->get_family();
            # get font family
            if ($key eq 'fontfamily') {
                $value = $family;
            } else {
                $fontarray[0] = $family;
                # remove family
                $font =~ s/$family//;
                $font =~ s/, //;
                # get font size
                my @rest = split(" ",$font);
                my $size = pop(@rest);
                if ($key eq 'fontsize') {
                    $value = $size;
                } else {
                    $fontarray[1] = $size;
                    # get weight
                    if ($key eq 'fontweight') {
                        my $value = join(" ",@rest);
                    } else {
                        # complete font as array
                        $fontarray[2] = join(" ",@rest);
                        my $value = @fontarray;
                    }
                }
            }
        }
    }

    # Status bar
    elsif ($object->{type} eq 'Statusbar') {
        if ($key eq 'message') {
            my @value;
            # get the text of the message-id
            if (looks_like_number($key_value[1])) {
                foreach my $i (0..$#{$object->{sbar_stack}}) {
                    foreach my $key (keys %{$object->{sbar_stack}[$i]}) {
                        if ($key == $key_value[1]) {
                            $value = $object->{sbar_stack}[$i]{$key};
                            last;
                        }
                    }
                }
            # get last message
            } else {
                @value = values(%{$object->{sbar_stack}[-1]});
                $value = $value[0];
            }
        }
        # get message id of the text
        elsif ($key eq 'msgid') {
            unless ($key_value[1] eq 'last') {
                foreach my $href (@{$object->{sbar_stack}}) {
                    foreach my $key (keys %{$href}) {
                         if ($href->{$key} eq $key_value[1]) {
                             $value = $key;
                             last;
                         }
                    }
                }
            # get last message id
            } else {
                my @last = keys (%{$object->{sbar_stack}[-1]});
                $value = $last[0];
            }
        }
        # get stack reference
        elsif ($key eq 'stackref') {
            $value = $object->{sbar_stack};
        }
        elsif ($key eq 'stackcount') {
            $value = scalar @{$object->{sbar_stack}};
        }
    }

    # List
    elsif ($object->{type} eq 'List') {
        if ($key eq 'editable') {
            $value = $object->{treeview}->get_column_editable($key_value[1]);
        }
        elsif ($key eq 'path') {
            if (ref($key_value[1]) eq 'ARRAY') {
                my @path_array;
                foreach (@{$key_value[1]}) {
                    push(@path_array, $object->{list}->{data}[$_]);
                }
                $value = \@path_array;
            } else {
                my $val = $key_value[1];
                $value = $object->{treeview}->{data}[$val];
            }
        }
        elsif ($key eq 'cell') {
            my ($n, $m) = ($key_value[1][0], $key_value[1][1]);
            $value = $object->{treeview}->{data}[$n][$m];
        }
    }

    # Tree
    elsif ($object->{type} eq 'Tree') {
        my $treeselection = $object->{treeview}->get_selection();
        my ($model, $iter) = $treeselection->get_selected();
        return undef unless defined($iter);
        if ($key eq 'iter') {
            return $iter; # because of undef
        }
        elsif ($key eq 'path') {
            # current selection
            unless (defined($key_value[1])) {
                $value = $model->get_path($iter);
            } else {
                $value = $model->get_path($key_value[1]);
            }
        }
        elsif ($key eq 'row') {
            my @row_array = $model->get($iter);
            $value = \@row_array;
        }

    }


    unless ($value eq 'Error') {
        return $value;
    } else {
        $self->internal_die($object, "Unknown parameter \"$key\".");
    }
}


# ---------------------------------------------------------------------
#   Function: set_value
#   Sets a new value for a widget.
#
#   Parameters:
#   <name>                      - Name of a widget.
#   <keyname> => <new_value>    - Keyword of a value and its new value.
#
#   _KEYNAMES_:
#
#   GtkCheckButton:
#   Active                  => <0/1>                        - The new state of the check button. 0 (deactivated) or 1 (activated).
#               
#   GtkRadioButton:             
#   Active                  => <0/1>                        - The new state of the radio button. 0 (deactivated) or 1 (activated).
#               
#   GtkLinkButton:              
#   Uri                     => <uri-text>                   - The new uri of the link button.
#               
#   GtkFontButton:              
#   Fontstring              => <font-string>                - The new font string (family, size, weight) of the font button.
#   Fontfamily              => <fontfamily>                 - The new font family.
#   Fontsize                => <fontsize>                   - The new font size.
#   Fontweight              => <fontweight>                 - The new font weight.
#               
#   GtkLabel:               
#   Wrap|Wrapped            => <0/1>                        - The new wrapping of the text. 0 (off) or 1 (on).
#   Justify                 => <justification>              - The new justification of the text: left, right, center or fill,
#               
#   GtkEntry:               
#   Align                   => <xalign>                     - The new alignment of the entry: left or right.
#               
#   GtkSpinButton:                  
#   Start                   => <start_value>                - The new start value of the spin button.
#   Active                  => <active_value>               - The new active value.
#   Min|Minimum             => <min_value>                  - The new minimum value.
#   Max|Maximum             => <max_value>                  - The new maximum value.
#   Step                    => <step_value>                 - The new step increment.
#   Snap                    => <0/1>                        - Sets the new policy as to whether values are corrected to the nearest step increment when an invalid value is provided.
#   Rate|Climbrate          => <climb_rate>                 - The new amount of acceleration that the spin button shall has.
#   Digits                  => <used_digits>                - The new number of decimal places the value will be displayed.
#                   
#   GtkComboBox:                    
#   Active                  => <active_index>               - The active item of the combo box to be the item at index.
#   Data                    => [<Array_of_values>]          - The new array of values/strings being displayed in the combo box.
#   Columns                 => <wrap_to_x_columns>          - The current number of columns to display.
#                   
#   GtkSlider:                  
#   Start                   => <start_value>                - The new start value of the slider.
#   Active                  => <active_value>               - The new active value.
#   Min|Minimum             => <min_value>                  - The new minimum value.
#   Max|Maximum             => <max_value>                  - The new maximum value.
#   Step                    => <step_value>                 - The new step increment.
#   DrawValue               => <0/1>                        - Specifies whether the current value is displayed as a string next to the slider.
#   ValuePos|ValuePosition  => <value_position>             - The new position where the current value will be displayed.
#   Digits                  => <used_digits>                - The new number of decimal places the value will be displayed.
#           
#   GtkScrollbar:           
#   Start                   => <start_value>                - The new start value of the scrollbar.
#   Active                  => <active_value>               - The new active value.
#   Min|Minimum             => <min_value>                  - The new minimum value.
#   Max|Maximum             => <max_value>                  - The new maximum value.
#   Step                    => <step_value>                 - The new step increment.
#   Digits                  => <used_digits>                - The new number of decimal places the value will be displayed.
#           
#   GtkTextView:            
#   LeftMargin              => <in_pixel>                   - The new left margin size of paragraphs in the text view.
#   RightMargin             => <in_pixel>                   - The new right margin size of paragraphs.
#   Wrap|Wrapped            => <wrap_mode>                  - The new wrap mode.
#   Justify                 => <justification>              - The new justification.
#
#   _Note:_ 'Path', 'Textview' and 'Textbuf|Textbuffer' can set with <set_textview>.
#   
#   GtkMenu:    
#   Justify                 => <justification>              - The new justification of the menu.
#               
#   GtkMenuItem:                
#   Icon                    => <path|stock|name>            - The new path of an icon or its' stock id ('Stock') or its' icon name ('Name') on a standard menu item.
#   Active                  => <0/1>                        - The new state of a radio menu item.
#   
#   GtkNotebook:    
#   Current|CurrentPage     => <page_number|next|prev>      - The new current page. Possible values: <page_number>, 'Next' or 'Prev'.
#   Popup                   => <0/1>                        - Enables (1) or disables (0) the popup menu.
#   Scroll|Scrollable       => <0/1>                        - Sets whether the tab label area will have arrows for scrolling.
#   Tabs                    => <edges>                      - The edge at which the tabs are drawn.
#   
#   GtkNotebookPage:    
#   Reorder                 => <0/1>                        - Sets the notebook page to a new position.
#   
#   GtkFontButton:  
#   fontstring              => <font_string>                - The new used font as string. Font family and size are required.
#   fontfamily              => <font_family>                - The new font family.
#   fontsize                => <font_size>                  - The new font size.
#   fontweight              => <font_weight>                - The new font weight.
#       
#   GtkFontSelectionDialog: 
#   previewstring           => <preview_text>               - The new preview text of the font selection dialog.
#   fontstring              => <font_string>                - The new used font as string. Font family and size are required.
#   fontfamily              => <font_family>                - The new font family.
#   fontsize                => <font_size>                  - The new font size.
#   fontweight              => <font_weight>                - The new font weight.
#   
#   GtkTreeview::List:
#   mode                    => <selection_mode>             - The new selection mode. Possible values are: 'none', 'single' (default), 'browse' and 'multiple'.
#   sortable                => <0/1>                        - Set the current column sortable (1) or not (0 - default).
#   reordable               => <0/1>                        - Set the rows reordable (1) or not (0 - default).
#   select                  => <row|[row_list]>             - Select row(s) in the list by index. If the list is set for multiple selection, 
#                                                             all indices in the list will be set/unset; otherwise, just the first is used. 
#                                                             If the list is set for no selection, then nothing happens.
#   unselect                => <row|[row_list]>             - Unselect row(s) in the list by index.
#
#   GtkTreeview::Tree:
#   mode                    => <selection_mode>             - The new selection mode. Possible values are: 'none', 'single' (default), 'browse' and 'multiple'.
#   sortable                => <0/1>                        - Set the current column sortable (1) or not (0 - default).
#   reordable               => <0/1>                        - Set the rows reordable (1) or not (0 - default).
#   iter                    => <iter>                       - The iter of the current selected element.
#   path                    => <path_object>                - The path object of the current selected element.
#   row                     => [row_values]                 - The new row values as an array of the given iter.
#
#   Returns:
#   None.
#
#   Examples:
#>  $win->set_value('NB1', Currentpage => $win->get_value('NB1', Title2number => $out));
#>  --------------------------------------
#>  $spin_button->set_value($cell->get("value"));
# ---------------------------------------------------------------------
sub set_value #(<name>, <keyname> => <new_value>)
{
    my $self = shift;
    my $name = shift;
    my %params = @_;

    unless (scalar(keys %params) > 1) {
        $self->set_values($name, %params);
    } else {
        $self->internal_die("Too much parameters! Use 'set_values' instead.");
    }
}


# ---------------------------------------------------------------------
#   Function: set_values
#   Set a bunch of new values for a widget.
#
#   Parameters:
#   <name>                  - Name of a widget.
#   <keyname>               - Keyword of a value and its new value.
#
#   _KEYNAMES_:
#   See <set_value> for possible keynames.
#
#   Returns:
#   None.
#
#   Examples:
#>  $win->set_values('spinDesktopX', Start => $current_x_desks, Min => 1, Max => $max, Step => 1);
#>  --------------------------------------
#>  $win->set_values($name, Data => $item_list_ref, Start => $active_item_nr);
# ---------------------------------------------------------------------
sub set_values #(<name>, <keyname> => <new_value>, <keyname> => <new_value>, ...)
{
    my $self = shift;
    my $name = shift;
    my %params = $self->_normalize(@_);
    
    my $object = $self->get_object($name);

    if ($object->{type} =~ /^(CheckButton|RadioButton)/) {
        if (defined($params{'active'})) {
            $object->{ref}->set_active($params{'active'});
            delete $params{'active'};
        }
    }

    if ($object->{type} eq 'LinkButton') {
        if (defined($params{'uri'})) {
            $object->{ref}->set_uri($params{'uri'});
            delete $params{'uri'};
        }
    }
    
    if ($object->{type} eq 'Label') {
        if (defined($params{'wrapped'})) {
            $object->{ref}->set_line_wrap($params{'wrapped'});
            delete $params{'wrapped'};
        }
        if (defined($params{'justify'})) {
            $object->{ref}->set_justify($params{'justify'});
            delete $params{'justify'};
        }
    }
    
    if ($object->{type} =~ /^(Entry|SpinButton)/ and defined($params{'align'})) {
        # set alignment of values
        ($params{'align'} eq 'right') ? $object->{ref}->set_alignment(1) : $object->{ref}->set_alignment(0);
        delete $params{'align'};
    }
    
    if ($object->{type} =~ /^(Slider|Scrollbar|SpinButton)/) {
        my $reconfigure = 0;
        my $digits;
        my $climbrate;
        
        if ($object->{type} eq 'SpinButton') {
            $digits = $object->{ref}->get_digits();
            $climbrate = $object->{climbrate};
        }
        
        # set minimum value
        if (defined($params{'minimum'})) {
            $object->{adjustment}->lower($params{'minimum'});
            $reconfigure = 1;
            delete $params{'minimum'};
        }
        # set maximum value
        if (defined($params{'maximum'})) {
            $object->{adjustment}->upper($params{'maximum'});
            $reconfigure = 1;
            delete $params{'maximum'};
        }
        # set steps
        if (defined($params{'step'})) {
            $object->{adjustment}->step_increment($params{'step'});
            $reconfigure = 1;
            delete $params{'step'};
        }
        # set pages
        if (defined($params{'page'})) {
            $object->{adjustment}->page_increment($params{'page'});
            $reconfigure = 1;
            delete $params{'page'};
        }
        # set start value
        if (defined($params{'start'})) {
            $object->{adjustment}->value($params{'start'});
            $reconfigure = 1;
            delete $params{'start'};
        }
        # set active value
        if (defined($params{'active'})) {
            $object->{ref}->set_value($params{'active'});
            delete $params{'active'};
        }
        
        if ($object->{type} eq 'SpinButton') {
            # set snap to ticks
            if (defined($params{'snap'})) {
                $object->{ref}->set_snap_to_ticks($params{'snap'});
                delete $params{'snap'};
            }
#            # set digits
#            if (defined($params{'digits'}) and $reconfigure) {
#                $digits = $params{'digits'};
#            } else {
#               print "params{'digits'}: '$params{'digits'}'";
#               print "reconfigure: '$reconfigure'";
#                $object->{ref}->set_digits($params{'digits'}) unless $reconfigure;
#            }
#            delete $params{'digits'} if defined($params{'digits'});

#            # set climbrate
#            if (defined($params{'climbrate'}) and $reconfigure) {
#                $climbrate = $params{'climbrate'};
#            } else {
#                $reconfigure = 1 unless defined($params{'climbrate'});
#            }
#            delete $params{'climbrate'} if defined($params{'climbrate'});

            # set digits
            if (defined($params{'digits'})) {
                if ($reconfigure) {
                    $digits = $params{'digits'};
                } else {
#                   print "params{'digits'}: '$params{'digits'}'";
#                   print "reconfigure: '$reconfigure'";
                    $object->{ref}->set_digits($params{'digits'});
                }
                delete $params{'digits'};
            }
            # set climbrate
            if (defined($params{'climbrate'})) {
                if ($reconfigure) {
                    $climbrate = $params{'climbrate'};
                } else {
                    $reconfigure = 1;
                }
                delete $params{'climbrate'};
            }

            # reconfigure SpinButton if needed
            if ($reconfigure) {
                $object->{ref}->configure($object->{adjustment}, $climbrate, $digits);
            }
        }
        elsif ($object->{type} =~ /^(Slider|Scrollbar)/) {
            if ($object->{type} eq 'Slider') {
                # value drawing?
                if (defined($params{'drawvalue'})) {
                    $object->{ref}->set_draw_value($params{'drawvalue'});
                    delete $params{'drawvalue'};
                }
                # digits of value
                if (defined($params{'digits'})) {
                    $object->{ref}->set_digits($params{'digits'});
                    delete $params{'digits'};
                }
                # position of the value
                if (defined($params{'valueposition'})) {
                    $object->{ref}->set_value_pos($params{'valueposition'});
                    delete $params{'valueposition'};
                }
            }
            
            if ($reconfigure) {
                Glib::Object->signal_emit($object->{adjustment}, "changed");
            }
        }
    }
    
    if ($object->{type} eq 'ComboBox'){
        # index of active value
        if (defined($params{'active'})) {
            $object->{ref}->set_active($params{'active'});
            delete $params{'active'};
        }
        if (defined($params{'columns'})) {
            $object->{ref}->set_wrap_width($params{'columns'});
            delete $params{'columns'};
        }
        if (defined($params{'data'})) {
            # exchange old data in object with new one
            $object->{data} = $params{'data'};
            delete $params{'data'};
            
            # remove all rows in liststore object
            my $model = $object->{ref}->get_model();
            $model->clear();
            
            # add new data to ListStore object
            foreach(@{$object->{data}}) {
                my $iter = $model->append;
                $model->set($iter,0 => _($_));
            }
            
            # check if there's a $params{'start'}
            my $start = defined($params{'start'}) ? $params{'start'} : 0;
            delete $params{'start'} if defined($params{'start'});
            
            # set active item
            $object->{ref}->set_active($start);
        }
    }
    
    if ($object->{type} eq 'TextView'){
        # set margins
        if (defined($params{'leftmargin'})) {
            $object->{textview}->set_left_margin($params{'leftmargin'});
            delete $params{'leftmargin'};
        }
        if (defined($params{'rightmargin'})) {
            $object->{textview}->set_right_margin($params{'rightmargin'});
            delete $params{'rightmargin'};
        }
        # set wrap mode
        if (defined($params{'wrapped'})) {
            $object->{textview}->set_wrap_mode($params{'wrapped'});
            delete $params{'wrapped'};
        }
        # set justification
        if (defined($params{'justify'})) {
            $object->{textview}->set_justification($params{'justify'});
            delete $params{'justify'};
        }
    }
    
    if ($object->{type} eq 'Menu') {
        # set justification
        if (defined($params{'justify'})) {
            my $justify = $params{'justify'} eq 'right' ? 1 : 0;
            $object->{title_item}->set_right_justified($justify);
            delete $params{'justify'};
        }

    }

    if ($object->{type} eq 'MenuItem') {
        # set icon
        if (defined($params{'icon'})) {
            my $icon = $object->{icon};
            # first check which icon is suggested
            my $image;
            if (defined($icon)) {
                # stock icon?
                if ($icon =~ /^gtk-/) {
                    $image = Gtk2::Image->new_from_stock($icon, 'menu')
                } else {
                    # path or theme icon name?
                    if (-e $icon) {
                        $image = Gtk2::Image->new_from_file($icon);
                    } else {
                        $image = Gtk2::Image->new_from_icon_name($icon, 'menu');
                    }
                    $object->{ref}->set_image($image);
                }
            } else {
                $self->internal_die($object, "\"$object->{type}\" hasn't an icon!");
            }
            delete $params{'icon'};
        }
    }

    if ($object->{type} eq 'Notebook'){
        # set current page
        if (defined($params{'currentpage'})) {
            if ($params{'currentpage'} eq 'next') {
                $object->{ref}->next_page();
            } 
            elsif($params{'currentpage'} =~ /^prev/) {
                $object->{ref}->prev_page();
            }
            else {
                $object->{ref}->set_current_page($params{'currentpage'});
            }
            delete $params{'currentpage'};
        }
        # set popup
        if (defined($params{'popup'})) {
            if ($params{'popup'}) {
                $object->{ref}->popup_enable();
            } else {
                $object->{ref}->popup_disable();
            }
            # update object
            $object->{popup} = $params{'popup'};
            delete $params{'popup'};
        }
        # set scrollable
        if (defined($params{'scrollable'})) {
            $object->{ref}->set_scrollable($params{'scrollable'});
            delete $params{'scrollable'};
        }
        # show tabs
        if (defined($params{'showtabs'})) {
            $object->{ref}->set_show_tabs($params{'showtabs'});
            delete $params{'showtabs'};
        }
        # tabs ()show/hide and position)
        if (defined($params{'tabs'})) {
            unless ($params{'tabs'} eq 'none') {
                $object->{ref}->set_show_tabs(1);
                $object->{ref}->set_tab_pos($params{'tabs'});
            } else {
                $object->{ref}->set_show_tabs(0);
            }
            delete $params{'tabs'};
        }
    }
    
    if ($object->{type} eq 'NotebookPage'){
        # reorder the page to position x
        if (defined($params{'reorder'})) {
            $object->{notebook}->reorder_child($object->{ref}, $params{'reorder'});
            delete $params{'reorder'};
        }
    }

    if ($object->{type} =~ /^(FontButton|FontSelectionDialog)/) {
        # set preview text
        if (defined($params{'preview'}) and $object->{type} eq 'FontSelectionDialog') {
            $object->{ref}->set_preview_text($params{'preview'});
            $object->{preview} = $params{'preview'};
            delete $params{'preview'};
        }
        # set full fontname
        if (defined($params{'font'})) {
            if (ref($params{'font'}) eq 'ARRAY') {
                $object->{font} = scalar(@{$params{'font'}}) == 2 ? join(" ", @{$params{'font'}}) : "$params{'font'}[0] $params{'font'}[2] $params{'font'}[1]";
            } else {
                $object->{font} = $params{'font'};
            }
            if ($object->{type} eq 'FontButton'){
                $object->{ref}->set_font_name ($object->{font});
            }
            delete $params{'font'};
        }
        my @fontarray = $self->get_font_array($object->{font});
        # set only font family
        if (defined($params{'fontfamily'})) {
            $fontarray[0] = $params{'fontfamily'};
            delete $params{'fontfamily'};
        }
        # set only font size
        if (defined($params{'fontsize'})) {
            $fontarray[1] = $params{'fontsize'};
            delete $params{'fontsize'};
        }
        # set only font weight
        if (defined($params{'fontweight'})) {
            $fontarray[2] = $params{'fontweight'};
            delete $params{'fontweight'};
        }
        # update object and reference
        $object->{font} = "$fontarray[0] $fontarray[2] $fontarray[1]";
        if ($object->{type} eq 'FontButton'){
            $object->{ref}->set_font_name ($object->{font});
        }
    }

    if ($object->{type} =~ /List|Tree/){
        if (defined($params{'data'})) {
            $object->{treeview}->set_data_array($params{'data'});
            $object->{data} = $object->{treeview}->{data};
            delete $params{'data'};
        }

        # set selection mode
        if (defined($params{'mode'})) {
            my $treeselection = $object->{treeview}->get_selection();
            $treeselection->set_mode($params{'mode'});
            delete $params{'mode'};
        }

        # set a column sortable
        if (defined($params{'sortable'})) {
            my $treecolumn = $object->{treeview}->get_column($params{'sortable'});
            $treecolumn->set_sort_column_id($params{'sortable'});
            delete $params{'sortable'};
        }

        # set rows reordable
        if (defined($params{'reordable'})) {
            $object->{treeview}->set_reorderable($params{'reordable'});
            delete $params{'reordable'};
        }

        if ($object->{type} eq 'List'){
            if (defined($params{'select'})) {
                unless (ref($params{'select'}) eq 'ARRAY') {
                    $object->{list}->select($params{'select'});
                } else {
                    $object->{list}->select(join(',', $params{'select'}));
                }
                delete $params{'select'};
            }
            elsif (defined($params{'unselect'})) {
                unless (ref($params{'unselect'}) eq 'ARRAY') {
                    $object->{list}->unselect($params{'select'});
                } else {
                    $object->{list}->unselect(join(',', $params{'select'}));
                }
                delete $params{'unselect'};
            }
        }

        if ($object->{type} eq 'Tree'){
            
        }
    }


    # if there remain(s) unknown parameter(s) 
    if (scalar keys %params > 0) {
        my $rest = join(", ", keys %params);
        $self->internal_die($object, "Unknown parameter(s) \"$rest\".");
    }
}


# *********************************************************************
#   Class: Font Handling
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: get_fontsize
#   Returns the current font size of a widget.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#   *OR*
#   <widget>    - Gtk2 reference object of a widget (e.g. Gtk2::Button).
#
#   Returns:
#   The font size.
#
#   Example:
#>  my $fontsize = get_fontsize($window);
# ---------------------------------------------------------------------
sub get_fontsize #(<name|widget>)
{
    my $self = shift;
    my $name_widget = shift;
    my $widget;
    
    if (defined($name_widget)) {
        my $object = $self->get_object($name_widget);
        $widget = $self->get_widget($object->{name})
    } else {
        $widget = $self;
    }

    my $context = $widget->get_pango_context();
    my $fontDesc = $context->get_font_description();
    my $language = $context->get_language();
    my $metrics = $context->get_metrics($fontDesc, $language);
    my $char_widths = $metrics->get_approximate_char_width();
    my $fontsize = $fontDesc->get_size();
    my $pango_scale = Gtk2::Pango->scale();
    my $char_scale = $char_widths/$pango_scale;
    if ($fontsize > 200) {
        $fontsize = $fontsize/$pango_scale ;
    }
    
    return $fontsize;
}


# ---------------------------------------------------------------------
#   Function: get_fontfamily
#   Returns the current font family of a widget.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#   *OR*
#   <widget>    - Gtk2 reference object of a widget (e.g. Gtk2::Button).
#
#   Returns:
#   The font family.
#
#   Example:
#>  my $fontsize = get_fontsize($window);
# ---------------------------------------------------------------------
sub get_fontfamily #(<name|widget>)
{
    my $self = shift;
    my $name_widget = shift;
    my $widget;
    
    if (defined($name_widget)) {
        my $object = $self->get_object($name_widget);
        $widget = $self->get_widget($object->{name})
    } else {
        $widget = $self;
    }

    my $context = $widget->get_pango_context();
    my $fontDesc = $context->get_font_description();
    my $fontfamily = $fontDesc->get_family();
    return $fontfamily
}


# ---------------------------------------------------------------------
#   Function: get_fontweight
#   Returns the current font weight of a widget.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#   *OR*
#   <widget>    - Gtk2 reference object of a widget (e.g. Gtk2::Button).
#
#   Returns:
#   The font weight.
#
#   Example:
#>  my $fontweight = get_fontweight($window);
# ---------------------------------------------------------------------
sub get_fontweight #(<name|widget>)
{
    my $self = shift;
    my $name_widget = shift;
    my $widget;
    
    if (defined($name_widget)) {
        my $object = $self->get_object($name_widget);
        $widget = $self->get_widget($object->{name})
    } else {
        $widget = $self;
    }

    my $context = $widget->get_pango_context();
    my $fontDesc = $context->get_font_description();
    my @fontarray = &font_string_to_array($fontDesc->to_string());
    unless (@fontarray = 3) {
        return $fontarray[2];
    } else {
        return "";
    }
}


# ---------------------------------------------------------------------
#   Function: get_font_string
#   Returns the current font string of a widget.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#
#   Returns:
#   The font size.
#
#   Example:
#>  $testfont = $win->get_font_string('frame1');
# ---------------------------------------------------------------------
sub get_font_string #(<name>)
{
    my $self = shift;
    my $name = shift;

    # get font object
    my $object = $self->get_object($name);
    my $type = $object->{type};

    my $font;
    my $context;
    if ($type =~ /^(FontButton|FontSelectionDialog)/) {
        $font = $object->{ref}->get_font_name();
    }
    # unfortunately it's mostly not possible to get the current font with the
    # widget holding the text. So we do it over the hash tag 'font'
    elsif (defined($object->{font})) {
        $font = $object->{font};
    }
    else {
        $context = $self->{ref}->get_pango_context();
        my $fontDesc = $context->get_font_description();
        $font = $fontDesc->to_string();
    }

    unless ($font eq "") {
        return $font;
    } else {
        $self->internal_die($object, "\"$type\" hasn't a font!");
    }
}

# ---------------------------------------------------------------------
#   Function: get_font_array
#   Returns current font string of a widget as an array.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#
#   Returns:
#   A font array [family, size, weight].
#
#   Example:
#>  my @fontarray = $win->get_font_array('frame1');
# ---------------------------------------------------------------------
sub get_font_array #(<name>)
{
    my $self = shift;
    my $name = shift;

    # get font object
    my $object = $self->get_object($name);

    my $font;
    if ($object->{type} =~ /^(FontButton|FontSelectionDialog)/) {
        $font = $object->{ref}->get_font_name();
    } else {
        $font = $self->get_font_string($name);
    }

    unless ($font eq "") {
        my @fontarray = font_string_to_array($font);
        return @fontarray;
    } else {
        $self->internal_die($object, "\"$object->{type}\" hasn't a font!");
    }
}

# ---------------------------------------------------------------------
#   Function: font_array_to_string
#   Converts a font array into a font string.
#
#   Parameters:
#   <font_array>      - Font as an array like [family, size[, weight]]. Font family AND size is required.
#
#   Returns:
#   A font string.
#
#   Example:
#>  my @fontarray = (Sans, 12);
#>  my $fontstring = font_array_to_string(@fontarray);
# ---------------------------------------------------------------------
sub font_array_to_string #(<font_array>)
{
    my @font_array = @_;
    my $font_string;
    # check if comma is needed
    my @pango_enums = ('condensed', 'expanded', 'oblique', 'italic', 'light', 'bold', 'heavy', 'roman');
    # hope theses enums are enough :-/
    my @family = split(' ', $font_array[0]);
    foreach my $enums (@pango_enums) {
        if (lc($family[-1])=~ /^$enums$/) {
            $font_array[0] = $font_array[0] . ',';
            last;
        }
    }
    # now concatenate all
    if (scalar(@font_array) == 2 ) {
        $font_string = join(" ", @font_array);
    } else {
        $font_string = "$font_array[0] $font_array[2] $font_array[1]";
    }
    return $font_string;
}


# ---------------------------------------------------------------------
#   Function: font_string_to_array
#   Converts a font string into a font array.
#
#   Parameters:
#   <font_string>      - Font string. Font family AND size is required.
#
#   Returns:
#   A font array [family, size[, weight]].
#
#   Example:
#>  my @fontarray = font_string_to_array('Arial Rounded MT Bold, Bold Italic 12');
# ---------------------------------------------------------------------
sub font_string_to_array #(<font_string>)
{
    my $font_string = shift;
    my @fontarray = [undef, undef, undef];

    my $fontdescription = Pango::FontDescription->from_string($font_string);
    my $family = $fontdescription->get_family();
    
    # get font family
    $fontarray[0] = $family;

    # remove family
    $font_string =~ s/$family//;
    $font_string =~ s/, //;
    
    # get font size
    my @rest = split(" ",$font_string);
    my $size = pop(@rest);
    $fontarray[1] = $size;

    # get weight
    $fontarray[2] = join(" ",@rest);
    
    return @fontarray;
}


# ---------------------------------------------------------------------
#   Function: set_font
#   Set new font of a widget.
#
#   Parameters:
#   <name>              - Name of the widget. Must be unique.
#   <font_string>       - Font string. Font family AND size is required.
#   *OR*
#   <font_array>        - Font as an array: [family, size, [weight]]. Font family AND size is required.
#   *OR*
#   <Family>            - Font family.
#   <Size>              - Font size.
#   <Weight>            - Font weight.
#
#   Returns:
#   None.
#
#   Example:
#>  $win->set_font('frame1', Family => 'Bernard MT Condensed');
# ---------------------------------------------------------------------
sub set_font #(<name>, <font_string>, or [family, size, [weight]], or Family => <Family>, Size => <Size>, Weight => <Weight>)
{
    my $self = shift;
    my $name = shift;
    my %params;
    my ($new_family, $new_size, $new_weight) = undef;
    my $new_font_string = undef;
    if (@_ == 1) {
        my $reference = shift;
        # is it a font array?
        if (ref($reference) eq 'ARRAY') {
            $new_family = $$reference[0];
            $new_size = $$reference[1] if ($reference > 1);
            $new_weight = $$reference[2] if ($reference > 2);
        } else {
            # is it a string?
            $new_font_string = $reference;
        }
    } else {
        %params = $self->_normalize(@_);
        $new_family = $params{'family'} || undef;
        $new_size = $params{'size'} || undef;
        $new_weight = $params{'weight'} || undef;
    }

    # get widget object
    my $object = $self->get_object($name);
    my $type = $object->{type};

    # check if object has a text to change allready
    if ($type =~ m/(^|k|o)Button$|^Frame|^Label|^Entry|^Text|^NotebookPage/) {
        unless (defined($new_font_string)){
            my $context;
            if ($type =~ m/^Text/) {
                $context = $object->{textview}->get_pango_context();
            } else {
                $context = $object->{ref}->get_pango_context();
            }
            my $fontDesc = $context->get_font_description();
            my @new_font_array;
            unless (defined($new_family)) {
                $new_family = $fontDesc->get_family();
            }
            push(@new_font_array, $new_family);
            unless (defined($new_size)) {
                if ($type =~ m/^Text/) {
                    $new_size = &get_fontsize($object->{textview});
                } else {
                    $new_size = &get_fontsize($object->{ref});
                }
            }
            push(@new_font_array, $new_size);
            if (defined($new_weight)) {
                push(@new_font_array, $new_weight);
            }
            $new_font_string = &font_array_to_string(@new_font_array);
        }
        my $font_desc = Gtk2::Pango::FontDescription->from_string($new_font_string);
        
        # get the needed label
        my $label = $object->{ref};
        if ($type =~ m/^Frame/) {
            $label = $object->{ref}->get_label_widget();
        }
        elsif ($type =~ m/(^|k|o)Button$/) {
            $label = $object->{ref}->get_child();
        }
        elsif ($type =~ m/^Text/) {
           $label = $object->{textview};
        }
        elsif ($type eq 'NotebookPage'){
            $label = $object->{pagelabel};
        }
        $label->modify_font($font_desc);

        # update or add new font to object
        $object->{font} = $new_font_string;
        #print "new_font_string: $new_font_string\n";
    } else {
        if (defined($new_font_string)) {
            $self->internal_die($object, "Can't set font \"$new_font_string\" - wrong type \"$type\"!");
        } else {
            $self->internal_die($object, "Can't set font - wrong type \"$type\"!");
        }
        return;
    }
}


# ---------------------------------------------------------------------
#   Function: set_font_color
#   Set new font color of a widget.
#
#   Parameters:
#   <name>      - Name of the widget. Must be unique.
#   <color>     - Font color. Can be a X11 color name or hexadecimal value. See more at <'Table of Color' at http://www.farb-tabelle.de/en/table-of-color.htm>
#   [<state>]   - Optional. Widget state. Default is 'normal'. For more see <Gtk2-Perl StateType at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Widget.pod.html#enum_Gtk2_StateType>
#
#   Returns:
#   None.
#
#   Examples:
#>  $win->set_font_color('checkButton1','red');
#>  --------------------------------------
#>  $win->set_font_color('label1', '#8B008B');
# ---------------------------------------------------------------------
sub set_font_color #(<name>, <color>, [<state>])
{
    my $self = shift;
    my ($name, $new_color, $state) = @_;
    
    $state = 'normal' unless defined($state);
    
    # get widget object
    my $object = $self->get_object($name);
    my $type = $object->{type};

    my $gdk_color = Gtk2::Gdk::Color->parse($new_color);

    # get text widget to modify color
    my $label;
    if ($object->{type} =~ m/(^|k|o)Button$/) {
        $label = $object->{ref}->get_child();
    }
    elsif ($object->{type} =~ m/^Frame/) {
        $label = $object->{ref}->get_label_widget();
    }
    elsif ($object->{type} =~ m/^Label/) {
        $label = $object->{ref};
    }
    elsif ($type eq 'NotebookPage'){
        $label = $object->{pagelabel};
    }
    else {
        $self->internal_die($object, "Can't set color \"$new_color\" - wrong type \"$type\"!");
    }
    $label->modify_fg($state, $gdk_color);
}


######################################################################
#   Group: Windows
######################################################################

# *********************************************************************
#   Widget: GtkWindow
#   Toplevel window which can contain other widgets
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: new_window
#   Creates a new GtkWindow, a toplevel window, that contain other widgets.
#
#   It contains by default a fixed container in a scrollable window widget. 
#   So whether it is resized smaller than defined vertical and/or horizontal 
#   scrollbars appear.
#
#   Parameters:
#   Name        => <name>               - Name of the window object. Must be unique.
#   Title       => <window title>       - Title of the window (displayed in the title bar).
#   [Version    => version-string]      - Optional. Version string of the program. Will be appended after the title.
#   [Base       => <font_size>]         - Optional. This is the font size used while creating the layout. Default is 10.
#   [Size       => [width, height]]     - Optional. Width and height of the window.
#   [Fixed      => <0/1>]               - Optional. Default: 0 (resizable).
#   [Iconpath   => <icon_path>]         - Optional. Path to an icon shown in title bar or on iconify.
#   [ThemeIcon  => <theme_icon_name>]   - Optional. Icon name from current theme.
#   [Statusbar  => <show_time|1>]       - Optional. If set a statusbar is shown at the bottom
#                                                   of the window. <show_time> is the time in milliseconds the
#                                                   message will show or 1 if no <show_time> is wanted.
#
#   Returns:
#   The main window object.
#
#   Example:
#   (start code)
#   my $win = SimpleGtk2->new_window(Name => 'mainWindow', 
#                           Title      => 'testem-all', 
#                           Size       => [400, 400], 
#                           ThemeIcon  => 'emblem-dropbox-syncing');
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Window.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkWindow.html>
#
#   Available Support Function:
#   show ()
#
#   show_and_run ()
# ---------------------------------------------------------------------
sub new_window #(Name => <name>, Title => <window title>, [Version => <version-string>], [Base => <font_size>], [Size => [width, height]], [Fixed => <0/1>], [Iconpath => <icon_path>], [ThemeIcon => <theme_icon_name>], [Statusbar => <show_time|1>])
{
    my $class = shift;
    my $window;
    my $self = {};
    # hash for all widget objects
    $self->{objects} = {};
    # hash for all radio groups: <group_name> => [radio1, radio2, ...]
    $self->{groups} = {};
    # hash for all containers used in widgets: <frame/nbpage_name> => <fixed_object>
    $self->{containers} = {};
    # array of all widgets which must show at the end with show_all()
    $self->{lates} = [];
    # hash of subs which must execute between show_all() and gtk2->main
    $self->{subs} = {};
    # hash with all signal handlers used for this window
    $self->{handler} = {};
    $self->{scalefactor} = 1.0;
    $self->{name} = '';
    $self->{old_font} = undef;
    $self->{old_fontsize} = undef;
    $self->{allocated_colors} = {};

    bless $self, $class;

    my %params = $self->_normalize(@_);
    $self->{name} = $params{'name'};
    $self->{base} = $params{'base'} || 10;
    $self->{version} = $params{'version'} || undef;

    my $object = _new_widget(%params);
    $object->{type} = 'toplevel';
    $object->{fixed} = $params{'fixed'} || 0;
    $object->{statusbar} = defined($params{'statusbar'}) ? $params{'statusbar'} : undef;
    $object->{sbar_timeout} = defined($params{'statusbar'}) ? $params{'statusbar'} > 1 ? $params{'statusbar'} : 0 : undef;
    $object->{sbar_stack} = [];
    
    # create the window
    $window = new Gtk2::Window($object->{type});
    my $title = _($object->{title});
    if (defined($self->{version})) {$title = "$title $self->{version}";}
    $window->set_title($title);
    $object->{ref} = $self->{ref} = $window;

    # get font size in current theme
    $self->{fontsize} = &get_fontsize($window);
    # get SCALE_FACTOR
    $self->{scalefactor} = $self->_calc_scalefactor($self->{base}, $self->{fontsize});

    # set it fixed if wanted
    $window->set_resizable(0) if $object->{fixed};

    # add an identifier icon if defined
    if (defined($params{'iconpath'})) {
        $self->{ref}->set_icon_from_file($params{'iconpath'});  
    }
    elsif (defined($params{'themeicon'})) {
        $self->{ref}->set_icon_name($params{'themeicon'});
    }

    # add signal handler for quit and theme font changes
    if ($object->{type} eq 'toplevel') {
        $self->add_signal_handler($object->{name}, "destroy", sub {Gtk2->main_quit;});
        $self->add_signal_handler($object->{name}, "style-set", sub {$self->_on_font_changed();});
    }

    # Create the fixed container
    my $fixed = new Gtk2::Fixed();
    $self->{container} = $fixed;

    # if statusbar create vbox and the statusbar
    my $vbox = undef;
    if (defined($object->{statusbar})) {
        $vbox = Gtk2::VBox->new();
        # add fixed container
        $vbox->pack_start($fixed, 1, 1, 0);
        # create and add statusbar
        my $statusbar = Gtk2::Statusbar->new();
        # no resize grip
        $statusbar->set_has_resize_grip(0);
        $vbox->pack_start($statusbar, 0, 1, 0);
        $statusbar->show();
        
        # create object for later use
        my %sb_params = (type => 'Statusbar', name => 'win_sbar');
        my $sb_object = _new_widget(%sb_params);
        $sb_object->{sbar_timeout} = $object->{sbar_timeout};
        $sb_object->{statusbar} = $object->{statusbar} = $statusbar;
        # get context id
        my $context_id = $statusbar->get_context_id($object->{name});
        $sb_object->{contextid} = $context_id;
        # get size
        my $req = $statusbar->size_request();
        $sb_object->{width} = $req->width;
        $sb_object->{height} = $req->height;
        # add widget object to window objects list
        $self->{objects}->{$sb_object->{name}} = $sb_object;
        # add vbox instead of statusbar to object
        $sb_object->{ref} = $vbox;
    }

    # if window size is fixed, no scroll window is needed
    unless ($object->{fixed}) {
        # create a scrolled window to display scrollbars
        # if user is minimizing the main window
        my $scrolled_window = Gtk2::ScrolledWindow->new (undef, undef);
        $scrolled_window->set_policy ('automatic', 'automatic');

        # add fixed container or vbox
        if (defined($vbox)) {
            $scrolled_window->add_with_viewport($vbox);
        } else {
            $scrolled_window->add_with_viewport($fixed);
        }
        # add scrollbar to the window
        $self->{ref}->add($scrolled_window);
        $scrolled_window->show();
    } else {
        # add fixed container or vbox
        if (defined($vbox)) {
            $self->{ref}->add($vbox);
        } else {
            $self->{ref}->add($fixed);        
        }
    }

    $vbox->show() if defined($vbox);
    $fixed->show();

    # add geometry if defined
    if ($object->{width} && $object->{height}) {
        # scale if needed
        if ($self->{scalefactor} != 1) {
            $object->{width} = $self->_scale($object->{width});
            $object->{height} = $self->_scale($object->{height});
        }
        $window->set_default_size($object->{width}, $object->{height});
    } else {
        my $req = $window->size_request();
        $object->{width} = $req->width;
        $object->{height} = $req->height;
    }

    # set position of statusbar if defined
    if (defined($object->{statusbar})) {
        my $sb_object = $self->get_object('win_sbar');
        $sb_object->{pos_x} = 0;
        $sb_object->{pos_y} = $object->{height} - $sb_object->{height} -1; # <- 1 = separator
    }

    # add window object to window objects list
    $self->{objects}->{$object->{name}} = $object;
    # add current used font to object
    $self->{font} = $self->get_font_string($self->{name});

    return $self;
}


# ---------------------------------------------------------------------
#   Function: show
#   Show toplevel window with all widgets without running Gtk2->main
#
#   This is the default loop function if library will be used in FVWM modules.
#
#   Parameters:
#   None.
#
#   Returns:
#   None.
# ---------------------------------------------------------------------
sub show #()
{
    my $self = shift;
    $self->{ref}->show_all();
    # show some widgets which are in the lates array
    foreach my $name (@{$self->{lates}}) {
        my $object = $self->get_object($name);
        my $ref = 'ref';
        $object->{$ref}->show();
    }
    # execute functions like draw which have to be executed between
    # show_all() and Gtk2->main
    foreach my $sub (sort keys %{$self->{subs}}) {
        $self->{subs}->{$sub}->();
    }
    # Now the current base can be set if different from fontsize
    if ($self->{scalefactor} != 1) {
        $self->{base} = $self->{fontsize};
        $self->{scalefactor} = 1;
    }
}


# ---------------------------------------------------------------------
#   Function: show_and_run
#   Show toplevel window with all widgets and start Gtk2->main.
#
#   This is the default loop function.
#
#   Parameters:
#   None.
#
#   Returns:
#   None.
# ---------------------------------------------------------------------
sub show_and_run #()
{
    my $self = shift;
    $self->show();
    Gtk2->main;
}


# *********************************************************************
#   Widget: GtkMessageDialog
#   A convenient message window
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_msg_dialog
#   Creates a new GtkMessageDialog object.
#
#   GtkMessageDialog presents a dialog with an image representing the type of message (Error, Question, etc.) alongside some message text.
#
#   Internal Name Type:
#   MessageDialog
#
#   Parameters:
#   Name            => <name>                   - Name of the message dialog. Must be unique.
#   Modal           => <0/1>                    - Behaviour of the message dialog. Default: modal (1). Else nonmodal (0).
#   DType           => <dialog_type>            - Type of the message dialog. Default: 'none'. Else 'ok', 'close', 'cancel', 'yes-no' or 'ok-cancel'.
#   MTyp            => <message_type>           - Type of the message. Possible values: 'info', 'warning', 'question', 'error' or 'other'.
#   [Icon           => <path|stock|name>]       - Optional. The used Icon beside of the main message. Can be an icon file path, a stock icon or an icon name.
#   [RFunc          => <response_function>]     - Optional. Have to be set if nonmodal (Modal => 0) is chosen. Gets the response 'ok', 'close', 'cancel', 'yes' or 'no'.
#
#   Returns:
#   None.
#
#   Examples:
#   (start code)
#   # a modal message dialog
#   $win->add_msg_dialog(Name => 'diag1',
#           DType   => 'ok-cancel',
#           MType   => 'warning',
#           Icon    => 'gtk-quit');
#   --------------------------------------
#   # a non modal message dialog
#   $win->add_msg_dialog(Name => 'diag2',
#           DType   => 'yes-no',
#           MType   => 'info',
#           RFunc   => \&nonModal,
#           Modal   => 0);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/MessageDialog.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkMessageDialog.html>
#
#   Available Support Function:
#   show_msg_dialog (<name>, "<message_text1>", "<message_text2>")          - A normal one.
#
#   show_msg_dialog (<dialog_type>, <message_type>, "<message_text>")       - A standalone or simple one.
# ---------------------------------------------------------------------
sub add_msg_dialog #(Name => <name>, Modal => <0/1>, DType => <dialog_type>, MTyp => <message_type>, [Icon => <path|stock|name>], [RFunc => <response_function>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'MessageDialog';
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # message dialog specific fields
    $object->{modal} = defined($params{'modal'}) ? $params{'modal'} : 1;
    $object->{dialogtype} = $params{'dialogtype'} || 'none';
    $object->{messagetype} = $params{'messagetype'};
    $object->{icon} = $params{'icon'} || undef;
    unless ($object->{modal}) {
        $object->{rfunc} = $params{'responsefunction'};
    } else {
        $object->{rfunc} = undef;
    }
}


# ---------------------------------------------------------------------
#   Function: show_msg_dialog
#   Shows a standalone, simple or normal message dialog.
#
#   The normal message dialog needs a message dialog object created with <add_msg_dialog>.
#
#   The standalone and the simple message dialog don't need this object.
#
#   Parameters for a normal:
#   <name>                  - Name of the message dialog. Must be unique.
#   <message_text1>         - The main message text.
#   [<message_text2>]       - Optional. A second text
#
#   Parameters for a standalone or simple:
#   <dialog_type>           - Type of the message dialog. Default: 'none'. Else 'ok', 'close', 'cancel', 'yes-no' or 'ok-cancel'.
#   <message_type>          - Type of the message. Possible values: 'info', 'warning', 'question', 'error' or 'other'.
#   <message_text>          - The main message text.
#
#   Returns:
#   The response. Can be "ok", "close", "cancel", "yes", "no" depending on the dialog type.
#
#   Examples:
#   (start code)
#   # A standalone message dialog
#   my $response = SimpleGtk2::show_msg_dialog('warning', 'yes-no', "This is a simple standalone");
#   --------------------------------------
#   # A simple one
#   my $response = $win->show_msg_dialog('warning', 'yes-no', "This is a simple one");
#   --------------------------------------
#   # A normal non-modal message dialog
#
#   sub nonModal{
#       my $response = shift;
#       if ($response eq 'yes') {print "Yes\n";}
#       else {print "No\n";}
#   }
#      
#   my $FirstMsg = "<span foreground=\"blue\" size=\"x-large\">Message Type</span>";
#   my $SecondMsg = "<span foreground='red' size=\"small\" style ='italic'>Info box.</span>";
#   
#   $win->add_button(Name => 'Button2',
#           Pos     => [60, 60],
#           Size    => [80, 40],
#           Title   => "_NonModal");
#   $win->add_signal_handler('Button2', 'clicked', sub{$win->show_msg_dialog('diag2', $FirstMsg, $SecondMsg);});
#   
#   $win->add_msg_dialog(Name => 'diag2',
#           DType   => 'yes-no',
#           MType   => 'info',
#           RFunc   => \&nonModal,
#           Modal   => 0);
#   (end code)
# ---------------------------------------------------------------------
sub show_msg_dialog #(<name>, <message_text1>, <message_text2>, or <dialog_type>, <message_type>, <message_text>)
{
    my $self = shift;
    my ($name, $msg1, $msg2);
    # is it standalone? 
    unless (ref($self) =~ /^SimpleGtk2/) {
        $name = $self;
        ($msg1, $msg2) = @_;
    } else {
        ($name, $msg1, $msg2) = @_;
    }
    
    my $object = undef;
    my $parent_window = undef;
    my $modal;
    my $flags;
    my $messagetype;
    my $dialogtype;
    my $color;
    
    # Is it a standalone message dialog?
    my $standalone = 1 || 0 unless (ref($self) =~ /^SimpleGtk2/);
    my $simple = 0;
    unless ($standalone) {
        $simple = 1 unless exists($self->{objects}->{$name});
        $parent_window = $self->{ref};
    } else {
        $simple = 1;
    }
    
    # is it a simple message dialog?
    if ($simple) {
        $flags = [qw/modal destroy-with-parent/];
        $modal = 1;
        $dialogtype = $msg1;
        $messagetype = $name;
        #'info', 'warning', 'question', 'error'
        my $sign;
        if ($messagetype =~ /info|question/) {
            $color = 'blue';
            $sign = '.'
        } else {
            $color = 'red';
            $sign = '!'
        }
        $msg1 = "<span foreground=\"$color\" size=\"x-large\">" . _(ucfirst($messagetype)) . "$sign </span>"; 
    } else {
        # get object
        $object = $self->get_object($name);
        
        $flags = $object->{modal} ? [qw/modal destroy-with-parent/] : 'destroy-with-parent';
        $modal = $object->{modal};
        $dialogtype = $object->{dialogtype};
        $messagetype = $object->{messagetype};
    }
    
    # initialize message box
    my $msg_box = Gtk2::MessageDialog->new_with_markup($parent_window,
                                            $flags,
                                            $messagetype,
                                            $dialogtype,
                                            sprintf _("$msg1"));
    
    # if a second text is set
    if (defined($msg2)) {
        $msg_box->format_secondary_markup(_($msg2));
    }
    
    # set title
    $msg_box->set_title(_(ucfirst($messagetype)));
        
    if (defined($object)) {
        # if another icon is suggested set it
        if (defined($object->{icon})) {
            my $icon = $object->{icon};
            my $image;
            # stock icon?
            if ($icon =~ /^gtk-/) {
                $image = Gtk2::Image->new_from_stock($icon, 'dialog');
            }
            # path or theme icon name?
            elsif (-e $icon) {
                $image = Gtk2::Image->new_from_file($icon);
            } 
            else {
                $image = Gtk2::Image->new_from_icon_name($icon, 'dialog');
            }
            $msg_box->set_image($image);
            $image->show();
        }        
    }
        
    # modal or not ... that's the question ^^
    if ($modal) {
        my $response = $msg_box->run();
        $msg_box->destroy();
        return $response;
    } else {
        # react whenever the user responds.
        $msg_box->signal_connect(response => sub {
            my ($self, $response, $object) = @_;
            $self->destroy();
            $object->{rfunc}->($response);
        }, $object);
        $msg_box->show_all();
    }  
}


######################################################################
#   Group: Display Widgets
######################################################################

# *********************************************************************
#   Widget: GtkImage
#   A widget displaying an image.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_image
#   Creates a new GtkImage widget.
#
#   The GtkImage widget displays an image.
#   Various kinds of object can be displayed as an image; most typically, 
#   you would load a GdkPixbuf ("pixel buffer") from a file, and then display that.
#   Additionally it is possible to bind a left click action to the image. Also a tooltip is possible.
#
#   Internal Name Type:
#   Image
#   
#   Parameters:
#   Name                => <name>                           - Name of the image. Must be unique.
#   Path                => <file_path>                      - Path of a picture to show.
#   *OR*  
#   Pixbuf|Pixbuffer    => <pix_buffer_object>              - Pixbuffer object (see <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Gdk/Pixbuf.pod.html> or 
#                                                             <Gdk2 at https://developer.gnome.org/gdk-pixbuf/unstable//gdk-pixbuf-The-GdkPixbuf-Structure.html#GdkPixbuf>) of an image to show.
#   *OR*  
#   Stock               => [<stock_name>[,<stock_size>]]    - Stock icon to show. <stock_size> is per default 'dialog' because for scaling.
#                                                             So, if <stock_size> is given, Size is optional.
#   Size                => [width, height]                  - Width and height of the image. It will be scaled if bigger/smaller.
#   Pos|Position        => [pos_x, pos_y]                   - Position of the image.
#   [Frame              => <frame_name>]                    - Optional. Name of the frame if the image is located in one. Must be unique. See <add_frame>.
#   [Tip|Tooltip        => <tooltip_text>]                  - Optional. Text of the tooltip shown while hovering over the image.
#   [Func|Function      => <function_click>]                - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                                       *Note:* If data is used it have to be set as an array.
#   [Sig|Signal         => <signal>]                        - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                                       Most used is 'button_press_event'.
#   [Sens|Sensitive     => <sensitive>]                     - Optional. Sets the image active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   # with pixbuf object
#   my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file("./myimage.png");
#   $win->add_image(Name => 'image2', 
#           Pos     => [240, 100], 
#           Size    => [50, 50], 
#           Tip     => 'A second picture', 
#           Frame   => 'frame1', 
#           Pixbuf  => $pixbuf);
#   $win->add_signal_handler('image2', 'button_press_event', \&Maximize);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Label.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkLabel.html>
#
#   Available Support Functions:
#   image_reference = <get_image> (<name>, [<keyname>])
#
#   <set_image> (Name => <name>, Path => <file_path> *or* Pixbuffer => <pix_buffer_object> *or* Image => <image_object> *or* Stock => [<stock_name>, <stock_size>])
#
#   string = <get_value> (<name>, "Justify" *or* "Wrap|Wrapped")
#
#   <set_value> (<name>, Justify|Wrap|Wrapped => <new_value>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (width, height) = <get_size> (<name>)
#
#   <set_size> (<name>, <new_width>, <new_height>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_image #(Name => <name>, Path => <file_path>, or Pixbuffer => <pix_buffer_object>, or Stock => [<stock_name>[,<stock_size>]], Size => [width, height], Position => [pos_x, pos_y], [Frame => <frame_name>], [Tooltip => <tooltip_text>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Image';

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # image specific fields
    $object->{path} = $params{'path'} || undef;
    $object->{stock} = $params{'stock'}[0] || undef;
    my $stock_size =  $params{'stock'}[1] || 'dialog';
    $object->{pixbuf} = $params{'pixbuffer'} || undef;
    my $image = $params{'image'} || undef;
    $object->{image} = undef;

    # first create an eventbox to handle signals
    my $eventbox = Gtk2::EventBox->new();
    # bind an action to it - we support clicks only (at first time ^^)
    $eventbox->set_events('button_press_mask');
    $eventbox->show();
    
    unless (defined($image)) {
        # create the pixbuf
        my $scaled;
        if (defined($object->{path})) {
            $object->{pixbuf} = Gtk2::Gdk::Pixbuf->new_from_file("$object->{path}");
        }
        elsif (defined($object->{stock})) {
            my $temp_image = Gtk2::Image->new_from_stock($object->{stock}, $stock_size);
            $object->{pixbuf} = $temp_image->render_icon($object->{stock}, $stock_size);
            # if no size is defined take the size from stock icon
            my $scale_no = 2;
            my $req = $temp_image->size_request();
            unless (defined($object->{width})) {
                $object->{width} = $req->width;
                $scale_no -= 1;
            }
            unless (defined($object->{height})) {
                $object->{height} = $req->height;
                $scale_no -= 1;
            }
            # scale stock icon
            if ($scale_no != 0) {
                $scaled = $object->{pixbuf}->scale_simple($object->{width},$object->{height},'bilinear');
            } else {
                $scaled = $object->{pixbuf};
            }
        }
        
        # scale pixbuf
        unless (defined($object->{stock})) {
            $scaled = $object->{pixbuf}->scale_simple($object->{width},$object->{height},'bilinear');
        }
        
        $image = Gtk2::Image->new_from_pixbuf($scaled);
    }
    
    # for later manipulation we put the image reference to the image object
    $object->{image} = $image;

    # add image to eventbox
    $eventbox->add($image);

    # add eventbox object as the image object to window objects hash
    # because of the signal handling
    $object->{ref} = $eventbox;

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the image
    $self->_add_to_container($object->{name});
    
    $image->show();
}


# ---------------------------------------------------------------------
#   Function: get_image
#   Returns the image reference, the pixbuffer or the path.
#   If no key is given the current Gtk2::Image reference will be returned. Else an object or path depending to the key.
#
#   Parameters:
#   <name>      - Name of the image. Must be unique.
#   <keyname>   - Optional. Possible keynames are: 'Path', 'Image' or 'Pixbuf|Pixbuffer'.
#
#   Returns:
#   The image reference, the pixbuffer or the path. 
#
#   Examples:
#>  # get the pixbuffer
#>  my $pixbuff = $win->get_image('Image1', 'Pixbuf');
#>  --------------------------------------
#>  # get path of the picture
#>  my $file_path = $win->get_image('Image1', 'Image');
# ---------------------------------------------------------------------
sub get_image #(<name>, [<keyname>])
{
    my $self = shift;
    my $name = shift;
    my $key = _extend(lc(shift)) || undef;
    my $image = 'Error';

    # get image object
    my $object = $self->get_object($name);
    my $type = $object->{type};

    if ($type =~ /Image/) {
        # get image reference
        unless ($key ne 'image' or defined($key)) {$image = $object->{image};}
        # get pixbuf
        elsif ($key eq 'pixbuffer') {$image = $object->{pixbuf};}
        # get path
        elsif ($key eq 'path') {$image = $object->{path};}
    
        unless ($image eq 'Error') {
            return $image;
        } else {
            $self->internal_die($object, "Unknown parameter \"$key\".");
        }
    } else {
        $self->internal_die($object, "Not an image object.");
    }
}


# ---------------------------------------------------------------------
#   Function: set_image
#   Sets a new image, stock icon, pixbuffer or file path.
#
#   Parameters:
#   Name                => <name>                       - Name of the image. Must be unique.
#   Path                => <image_path>                 - Path of the new image.
#   *OR*
#   Pixbuf|Pixbuffer    => <pix_buffer_object>          - A Gtk2::Gdk::Pixbuf object of a new image.
#   *OR*
#   Image               => <image_object>               - A Gtk2::Image object of a new image.
#   *OR*
#   Stock               => [<stock_name>,<stock_size>]  - A Gtk2::Stock icon as a new image. <stock_size> is per default 'dialog' because for scaling.
#                                                         *Note:* If <stock_size> is given, width and height of the image will be changed.
#
#   Returns:
#   None. 
#
#   Example:
#>  # set a new image by path
#>  $win->set_image('Image1', Path => '/usr/share/icons/gnome/256x256/actions/appointment-new');
# ---------------------------------------------------------------------
sub set_image #(Name => <name>, Path => <file_path>, or Pixbuffer => <pix_buffer_object>, or Image => <image_object>, or Stock => [<stock_name>, <stock_size>])
{
    my $self = shift;
    my $name = shift;
    my %params = $self->_normalize(@_);
    
    my $object = $self->get_object($name);
    
    my $image;
    if (defined($params{'path'}) or defined($params{'pixbuffer'})) {
        # path want be changed
        if (defined($params{'path'})) {
            $object->{path} = $params{'path'};
            $object->{pixbuf} = Gtk2::Gdk::Pixbuf->new_from_file("$object->{path}");
        }
        # pixbuf want be changed
        elsif (defined($params{'pixbuffer'})) {
            $object->{pixbuf} = $params{'pixbuffer'};
        }
        
        # scale image
        my $scaled = $object->{pixbuf}->scale_simple($object->{width},$object->{height},'bilinear');
        $image = Gtk2::Image->new_from_pixbuf($scaled);
    }
    elsif (defined($params{'image'})) {
        $image = $params{'image'};
    }
    elsif (defined($params{'stock'})) {
        $object->{stock} = $params{'stock'}[0] || undef;
        my $stock_size =  $params{'stock'}[1] || 'dialog';

        my $temp_image = Gtk2::Image->new_from_stock($object->{stock}, $stock_size);
        $object->{pixbuf} = $temp_image->render_icon($object->{stock}, $stock_size);
        # if no size is defined take the size from stock icon
        my $scale_no = 2;
        my $req = $temp_image->size_request();
        unless (defined($object->{width})) {
            $object->{width} = $req->width;
            $scale_no -= 1;
        }
        unless (defined($object->{height})) {
            $object->{height} = $req->height;
            $scale_no -= 1;
        }
        # scale stock icon
        my $scaled;
        if ($scale_no != 0) {
            $scaled = $object->{pixbuf}->scale_simple($object->{width},$object->{height},'bilinear');
        } else {
            $scaled = $object->{pixbuf};
        }
        $image = Gtk2::Image->new_from_pixbuf($scaled);
    }
    else {
        my $rest = join(", ", keys %params);
        $self->internal_die($object, "Unknown parameter(s): \"$rest\".");
    }
    
    # remove old one from eventbox
    $object->{ref}->remove($object->{image});
    
    # put the new image reference to the image object
    $object->{image} = $image;

    # add image to eventbox
    $object->{ref}->add($image);
    
    # show new image
    $object->{image}->show();
#    $object->{ref}->show();
}


# *********************************************************************
#   Widget: GtkLabel
#   A widget that displays a small to medium amount of text.
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: add_label
#   Creates a new GtkLabel widget.
#
#   The GtkLabel widget displays a small amount of text. As the name implies, most labels are used to label another widget such as a GtkButton or a GtkMenuItem.
#
#   Internal Name Type:
#   Label
#   
#   Parameters:
#   Name            => <name>                       - Name of the label. Must be unique.
#   Pos|Position    => [pos_x, pos_y]               - Position of the label.
#   Title           => <title>                      - Text of the label.
#   [Frame          => <frame_name>]                - Optional. Name of the frame if the label is located in one. Must be unique. See <add_frame>.
#   [Font           => [family, size, weight]]      - Optional. Sets the initial font. Font family and size are required if set.
#   [Widget         => <name_of_linked_widget>]     - Optional. Links the text with a widget - in conjunction with underlined.
#   [Justify        => <justify>]                   - Optional. Justification of the text. Possible values: left, right, center, fill
#   [Wrap|Wrapped   => <0/1>]                       - Optional. Wraps the text. Only usable in a frame.
#   [Tip|Tooltip    => <tooltip_text>]              - Optional. Text of the tooltip shown while hovering over the label.
#   [Sens|Sensitive => <sensitive>]                 - Optional. Sets the label active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_label(Name => 'label1', 
#           Pos     => [10, 20], 
#           Title   => "A Label.\n"."A new line", 
#           Justify => 'left');
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Label.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkLabel.html>
#
#   Available Support Functions:
#   string = <get_value> (<name>, "Justify" *or* "Wrap|Wrapped")
#
#   <set_value> (<name>, Justify|Wrap|Wrapped => <new_value>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_label #(Name => <name>, Position => [pos_x, pos_y], Title => <title>, [Frame => <frame_name>], [Font => [family, size, weight]], [Widget => <name_of_linked_widget>], [Justify => <justify>], [Wrapped => <0/1>], [Tooltip => <tooltip_text>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Label';
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # label specific fields
    $object->{widget} = $params{'widget'} || undef;
    my $justify = $params{'justify'} || undef;
    my $wrapped = $params{'wrapped'} || 0;
    my $font = $params{'font'} || undef;
    my $color = $params{'color'}[0] || undef;
    my $cstate = $params{'color'}[1] || undef;

    # create label
    my $label;

    # remove all spaces/tabs if a backslash is found => wrap in script
    # in long text for better readability
    $object->{title} =~ s/\R\h+//g;

    if ($self->is_underlined($object->{title})) {
        $label = Gtk2::Label->new_with_mnemonic(_($object->{title}));
        my $obj_ref = $self->_get_ref($object->{widget});
        $label->set_mnemonic_widget($obj_ref);
    } else {
        $label = Gtk2::Label->new(_($object->{title}));
    }
    
    # add widget reference to widget object
    $object->{ref} = $label;
    
    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # if text should wrapped
    $label->set_line_wrap($wrapped);
    
    # should text justified
    $label->set_justify($justify) if defined($justify);
    
    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);
    
    # set font color if defined
    $self->set_font_color($object->{name}, $color, $cstate) if defined($color);

    # position the label
    $self->_add_to_container($object->{name});
    
    $label->show();
}


# ---------------------------------------------------------------------
# add_progressbar(  Name => <name>,                     <= widget name - must be unique
#                   Pos => [pos_x, pos_y], 
#                   Size => [width, height],            <= Optional
#                   Mode => <mode>,                     <= percent, pulse
#                   Steps => <>
#                   orient => <orientation>,            <= 
#                   Timer => <update_time>              <= in ms
#                   Align => <align>                    <= Optional (left, right)
#                   Tip => <tooltip_text>)              <= Optional
#)
# ---------------------------------------------------------------------




#                   Step => <step_in/decrease>      
#                   Align => <align>                <= Optional (left, right)
#                   Climbrate => <from 0.0 to 1.0>  <= Optional (default: 0.0)
#                   Digits => <used_digits>         <= Optional (default: 0)

# ---------------------------------------------------------------------

# *********************************************************************
#   Widget: GtkStatusbar
#   Report messages of minor importance to the user.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_statusbar
#   Creates a new GtkStatusbar widget.
#
#   A GtkStatusbar is usually placed along the bottom of an application's main GtkWindow.
#
#   It may provide a regular commentary of the application's status, or may be used to simply output a message when the status changes.
#
#   Internal Name Type:
#   Statusbar
#   
#   Parameters:
#   Name            => <name>                       - Name of the status bar. Must be unique.
#   Pos|Position    => [pos_x, pos_y]               - Position of the status bar.
#   [Size           => [width, height]]             - Optional. Size of the status bar. Default is the complete window width.
#   [Frame          => <frame_name>]                - Optional. Name of the frame if the status bar is located in one. Must be unique. See <add_frame>.
#   [Timeout        => <show_time>]                 - Optional. The time in milliseconds the message will be shown. Default is 1 (no timeout).
#   [Sens|Sensitive => <sensitive>]                 - Optional. Sets the status bar active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_statusbar(Name => 'sbar1',
#           Pos     => [0, 0],
#           Timeout => 2000);
#   (end code)
#
#   Note:
#   The main window supports a statusbar at the bottom, too. See <new_window> for more details.
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Statusbar.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkStatusbar.html>
#
#   Available Support Functions:
#   <set_sb_text> ([<name>], <text>)
#
#   <remove_sb_text> ([<name>], [<text>|<msg-id>])
#
#   <clear_sb_stack> (<name>)
#
#   string = <get_value> (<name>, "message" *or* "msgid" *or* "stackref" *or* "stackcount")
#
#   <set_value> (<name>, message|msgid|stackref|stackcount => <new_value>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
# ---------------------------------------------------------------------
sub add_statusbar #(Name => <name>, Position => [pos_x, pos_y], [Size => [width, height]], [Frame => <frame_name>], [Timeout => <show_time>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Statusbar';
    

    # statusbar specific fields
    $object->{sbar_stack} = [];
    $object->{sbar_last_msg_id} = undef;
    $object->{sbar_timeout} = defined($params{'timeout'}) ? $params{'timeout'} > 1 ? $params{'timeout'} : 0 : undef;
    my $sensitive = defined($params{'sensitive'}) ? $params{'sensitive'} : undef;

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;
    
    # create vbox to put statusbar in (for showing)
    my $vbox = Gtk2::VBox->new();
    
    # check if width and height is given
    if ($object->{width} || $object->{height}) {
        $vbox->set_size_request ($object->{width}, $object->{height});
    } else {
        # get the width of the main window
        my $win_width = $self->get_object($self->{name})->{width};
        
        if ($win_width != 0) {
            # add 2 pixels to pos_x for centering
            $object->{pos_x} += 2;
            
            # create statusbar width (-2 is needed because of the vertical scrollbar)
            my $sbar_width = $win_width - 2*$object->{pos_x} - 2;
            $vbox->set_size_request ($sbar_width, -1);
        }
    }

    # create statusbar
    my $statusbar = Gtk2::Statusbar->new();
    # no resize grip
    $statusbar->set_has_resize_grip(0);
    # get context id
    my $context_id = $statusbar->get_context_id($object->{name});
    $object->{contextid} = $context_id;
    $statusbar->show();
    
    # for later manipulation we put the statusbar reference to the statusbar object
    $object->{statusbar} = $statusbar;
    
    $vbox->add($statusbar);
    
    # add vbox instead of statusbar to object
    $object->{ref} = $vbox;
    
    # add object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # position the statusbar
    $self->_add_to_container($object->{name});

    # get size
    my $req = $vbox->size_request();
    $object->{width} = $req->width;
    $object->{height} = $req->height;

     # set sensitive state
    $object->{ref}->set_sensitive($sensitive) if defined($sensitive);
    
    $vbox->show();
}


# ---------------------------------------------------------------------
#   Function: set_sb_text
#   Sets/display a new status bar message.
#
#   Parameters:
#   <name>          - Optional. Name of the status bar. Must be unique. If not set the main window status bar will be used.
#   <text>          - New text message for the status bar.
#
#   Returns:
#   Message id.
#
#   Example:
#>  $win->set_sb_text('sbar1', $text);
# ---------------------------------------------------------------------
sub set_sb_text #([<name>], <text>)
{
    my $self = shift;
    my ($name, $text) = @_;
    
    unless (defined($text)) {
        $text = $name;
        $name = 'win_sbar';
    }
    
    # get statusbar object
    my $object = $self->get_object($name);
    
    # show message
    my $msg_id = $object->{statusbar}->push($object->{contextid}, $text);
    push(@{$object->{sbar_stack}}, {$msg_id => $text});
    unless ($object->{sbar_timeout} <= 1) {
        Glib::Timeout->add($object->{sbar_timeout},
            sub{
                $self->remove_sb_text($name, $msg_id);
            });
    }
    return $msg_id;
}


# ---------------------------------------------------------------------
#   Function: remove_sb_text
#   Removes a message from the status bar.
#
#   Parameters:
#   <name>              - Optional. Name of the status bar. Must be unique. If not set the main window status bar will be used.
#   <text|msg-id>       - Optional. The id or its' text message. If not set the last message will be removed.
#
#   Returns:
#   None.
#
#   Example:
#>  $win->remove_sb_text('sbar1', $msg_id[3]);
# ---------------------------------------------------------------------
sub remove_sb_text #([<name>], [<text>|<msg-id>])
{
    my $self = shift;
    my ($name, $text_or_id) = @_;
    
    unless (defined($text_or_id)) {
        $text_or_id = $name if defined($name);
        $name = 'win_sbar';
    }
    
    # get statusbar object
    my $object = $self->get_object($name);
    
    if (defined($text_or_id)) {
        my $msg_id;
        my $msg;
        if (looks_like_number($text_or_id)) {
            my @new_sb_stack;
            foreach my $i (0..$#{$object->{sbar_stack}}) {
                foreach my $key (keys %{$object->{sbar_stack}[$i]}) {
                    unless ($key == $text_or_id) {
                        push(@new_sb_stack, {$key => $object->{sbar_stack}[$i]{$key}});
                    } else {
                        $object->{statusbar}->remove($object->{contextid}, $text_or_id);
                    }
                }
            }
            $object->{sbar_stack} = \@new_sb_stack;
        } else {
            if ($text_or_id eq 'last') {
                $object->{statusbar}->pop($object->{contextid});
                pop(@{$object->{sbar_stack}});
            } else {
                my @new_sb_stack;
                foreach my $i (0..$#{$object->{sbar_stack}}) {
                    foreach my $key (keys %{$object->{sbar_stack}[$i]}) {
                        unless ($object->{sbar_stack}[$i]{$key} eq $text_or_id) {
                            push(@new_sb_stack, {$key => $object->{sbar_stack}[$i]{$key}});
                        } else {
                            $object->{statusbar}->remove($object->{contextid}, $key);
                        }
                    }
                }
                $object->{sbar_stack} = \@new_sb_stack;
            }
        }
    } else {
        $object->{statusbar}->pop($object->{contextid});
        pop(@{$object->{sbar_stack}});
    }
}


# ---------------------------------------------------------------------
#   Function: clear_sb_stack
#   Clears the message stack of a status bar.
#
#   Parameters:
#   <name>              - Name of the status bar. Must be unique. If not set the main window status bar will be used.
#
#   Returns:
#   None.
#
#   Example:
#>  $win->clear_sb_stack();
# ---------------------------------------------------------------------
sub clear_sb_stack #(<name>)
{
    my $self = shift;
    my $name = @_;
    
    unless (defined($name)) {
        $name = 'win_sbar';
    }
    
    # get statusbar object
    my $object = $self->get_object($name);
    
    # remove from the beginning
    foreach my $i (0..$#{$object->{sbar_stack}}) {
        foreach my $key (keys %{$object->{sbar_stack}[$i]}) {
            $object->{statusbar}->remove($object->{contextid}, $key);
        }
    }
    $object->{sbar_stack} = [];
}


######################################################################
#   Group: Buttons and Toggles
######################################################################

# *********************************************************************
#   Widget: GtkButton
#   A widget that creates a signal when clicked on.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_button
#   Creates a new GtkButton widget.
#
#   The GtkButton widget is generally used to attach a function to that is called when the button is pressed.
#
#   Internal Name Type:
#   Button
#
#   Parameters:
#   Name            => <name>                   - Name of the button. Must be unique.
#   Pos|Position    => [pos_x, pos_y]           - Position of the button.
#   Title           => <title>                  - Title of the button (displayed in the button).
#   [Frame          => <frame_name>]            - Optional. Name of the frame if the button is located in one. Must be unique. See <add_frame>.
#   [Font           => [family, size, weight]]  - Optional. Sets a title font. To use the defaults set values with undef.
#   [Color          => [<color>, <state>]]      - Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                           State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (see Gtk2::State).
#   [Size           => [width, height]]         - Optional. Width and height of the button. Default is 80x25.
#   [Tip|Tooltip    => <tooltip_text>]          - Optional. Text of the tooltip shown while hovering over the button.
#   [Func|Function  => <function_click>]        - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                           *Note:* If data is used it have to be set as an array.
#   [Sig|Signal     => <signal>]                - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                           Can be 'activate', 'clicked', 'enter', 'leave' or 'pressed'.
#   [Sens|Sensitive => <sensitive>]             - Optional. Sets the button active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_button(Name => 'closeButton', 
#           Pos    => [10, 45], 
#           Title  => "_Close", 
#           Tip    => 'Closes the Application', 
#           Frame  => 'frame2');
#   $win->add_signal_handler('closeButton', 'clicked', sub{Gtk2->main_quit;});
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Button.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkButton.html>
#
#   Available Support Functions:
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   (width, height) = <get_size> (<name>)
#
#   <set_size> (<name>, <new_width>, <new_height>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_button #(Name => <name>, Position => [pos_x, pos_y], Title => <title>, [Frame => <frame_name>], [Font => [family, size, weight]], [Color => [<color>, <state>]], [Size => [width, height]], [Tooltip => <tooltip_text>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Button';

    # button specific fields
    my $font = $params{'font'} || undef;
    my $color = $params{'color'}[0] || undef;
    my $cstate = $params{'color'}[1] || undef;
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # create button
    my $button;
    if (defined($object->{title})) {
        # if underline in text should use
        if ($self->is_underlined($object->{title})) {
            $button = Gtk2::Button->new_with_mnemonic(_($object->{title}));
            $button->set_use_underline(1);
        } else {
            $button = Gtk2::Button->new_with_label(_($object->{title}));
        }
    } else {
        $button = Gtk2::Button->new();
    }
    
    # add widget reference to widget object
    $object->{ref} = $button;
    
    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);
    
    # set font color if defined
    $self->set_font_color($object->{name}, $color, $cstate) if defined($color);

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the button
    $self->_add_to_container($object->{name});

    $button->show();
}


# *********************************************************************
#   Widget: GtkCheckButton
#   A widget that creates a discrete toggle button with label.
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: add_check_button
#   Creates a new GtkCheckButton widget.
#
#   A GtkCheckButton places a discrete toggle button next to a label.
#
#   Internal Name Type:
#   CheckButton
#
#   Parameters:
#   Name            => <name>                   - Name of the button. Must be unique.
#   Pos|Position    => [pos_x, pos_y]           - Position of the button.
#   Title           => <title>                  - Title of the button (displayed in the button).
#   [Frame          => <frame_name>]            - Optional. Name of the frame if the button is located in one. Must be unique. See <add_frame>.
#   [Active         => <0/1>]                   - Optional. Sets the active state. Default: 0 (not active)
#   [Font           => [family, size, weight]]  - Optional. Sets a title font. To use the defaults set values with undef.
#   [Color          => [<color>, <state>]]      - Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                           State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (see Gtk2::State).
#   [Tip|Tooltip    => <tooltip_text>]          - Optional. Text of the tooltip shown while hovering over the button.
#   [Func|Function  => <function_click>]        - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                           *Note:* If data is used it have to be set as an array.
#   [Sig|Signal     => <signal>]                - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                           Can be 'activate', 'clicked', 'enter', 'leave' or 'pressed'.
#   [Sens|Sensitive => <sensitive>]             - Optional. Sets the button active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Examples:
#   (start code)
#   $win->add_check_button( Name => 'checkEnabled' . $name_number, 
#           Pos     => [170, 10], 
#           Title   => 'Enabled', 
#           Tip     => "Enables or disables this output.", 
#           Active  => $enabled, 
#           Frame   => "NB_page" . $nr);
#   $win->add_signal_handler('checkEnabled' . $name_number, 'toggled', \&on_checkbox_enabled_toggled, $name);
#   --------------------------------------
#   $win->add_check_button(Name => 'checkButton1', 
#           Pos     => [80, 20], 
#           Title   => 'Check button', 
#           Tip     => 'This is a checkbox', 
#           Sig     => 'toggled', 
#           Func    => [\&DeleteFile, 'bla.txt']);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/CheckButton.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkCheckButton.html>
#
#   Available Support Functions:
#   state = <get_value> (<name>, "active")
#
#   <set_value> (<name>, Active => <0/1>)
#
#   state = <is_active> (<name>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   (width, height) = <get_size> (<name>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_check_button #(Name => <name>, Position => [pos_x, pos_y], Title => <title>, [Frame => <frame_name>], [Active => <0/1>], [Font => [family, size, weight]], [Color => [<color>, <state>]], [Tooltip => <tooltip_text>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'CheckButton';
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;
    
    # create check button
    my $check_button = $self->_create_check_widget($object->{name}, %params);

    # position the button
    $self->_add_to_container($object->{name});
    
    $check_button->show();
}


# ---------------------------------------------------------------------
# _create_check_widget(<name>, <params>)
# ---------------------------------------------------------------------
sub _create_check_widget($@) {
    my $self = shift;
    my ($name, %params) = @_;
    
    # get object
    my $object = $self->get_object($name);
    
    # check button/item menu specific fields
    my $active = $params{'active'} || 0;
    my $font = $params{'font'} || undef;
    my $color = $params{'color'}[0] || undef;
    my $cstate = $params{'color'}[1] || undef;
    
    # create check button/item menu
    my $check_widget;
    if (defined($object->{title})) {
        # if underline in text should use
        if ($self->is_underlined($object->{title})) {
            if ($object->{type} eq 'CheckButton') {
                $check_widget = Gtk2::CheckButton->new_with_mnemonic(_($object->{title}));
            } else {
                $check_widget = Gtk2::CheckMenuItem->new_with_mnemonic(_($object->{title}));
            }
            $check_widget->set_use_underline(1);
        } else {
            if ($object->{type} eq 'CheckButton') {
                $check_widget = Gtk2::CheckButton->new_with_label(_($object->{title}));
            } else {
                $check_widget = Gtk2::CheckMenuItem->new_with_label(_($object->{title}));
            }
        }
    } else {
        if ($object->{type} eq 'CheckButton') {
            $check_widget = Gtk2::CheckButton->new();
        } else {
            $check_widget = Gtk2::CheckMenuItem->new();
        }
    }
    
    # add widget reference to widget object
    $object->{ref} = $check_widget;
    
    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);

    # set font color if defined
    $self->set_font_color($object->{name}, $color, $cstate) if defined($color);

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # set check button/item menu active
    $check_widget->set_active($active);
    
    return $check_widget;
}


# *********************************************************************
#   Widget: GtkRadioButton
#   A choice from multiple check buttons.
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: add_radio_button
#   Creates a new GtkRadioButton widget.
#
#   A single radio button performs the same basic function as a GtkCheckButton, as its position in the object hierarchy reflects. 
#   It is only when multiple radio buttons are grouped together that they become a different user interface component in their own right.
#
#   Every radio button is a member of some group of radio buttons. When one is selected, all other radio buttons in the same group are deselected.
#
#   Internal Name Type:
#   RadioButton
#
#   Parameters:
#   Name            => <name>                   - Name of the button. Must be unique.
#   Pos|Position    => [pos_x, pos_y]           - Position of the button.
#   Title           => <title>                  - Title of the button (displayed in the button).
#   Group           => <button_group>,          - Name of the buttongroup. Must be unique.
#   [Frame          => <frame_name>]            - Optional. Name of the frame if the button is located in one. Must be unique. See <add_frame>.
#   [Active         => <0/1>]                   - Optional. Sets the active state. Default: 0 (not active)
#   [Font           => [family, size, weight]]  - Optional. Sets a title font. To use the defaults set values with undef.
#   [Color          => [<color>, <state>]]      - Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                           State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (see Gtk2::State).
#   [Tip|Tooltip    => <tooltip_text>]          - Optional. Text of the tooltip shown while hovering over the button.
#   [Func|Function  => <function_click>]        - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                           *Note:* If data is used it have to be set as an array.
#   [Sig|Signal     => <signal>]                - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                           Can be 'activate', 'clicked', 'enter', 'leave' or 'pressed'.
#   [Sens|Sensitive => <sensitive>]             - Optional. Sets the button active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   # Group of 3 Radio Buttons
#   $win->add_radio_button(Name => 'radio1', Pos => [10, 90], 
#           Title   => "First", Group => "radio1", 
#           Active  => 1, Tip => "1st radio button", 
#           Frame   => 'frame1');
#   $win->add_radio_button(Name => 'radio2', Pos => [10, 110], 
#           Title   => "_Second", Group => "radio1", 
#           Tip     => "2nd radio button", Frame => 'frame1');
#   $win->add_radio_button(Name => 'radio3', Pos => [10, 130], 
#           Title   => "Third", Group => "radio1", 
#           Tip     => "3rd radio button", Frame => 'frame1');
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/RadioButton.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkRadioButton.html>
#
#   Available Support Functions:
#   value = <get_value> (<name>, "active" *or* "Group" *or* "Groupname|Gname")
#
#   <set_value> (<name>, Active => <0/1>)
#
#   state = <is_active> (<name>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   (width, height) = <get_size> (<name>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_radio_button #(Name => <name>, Position => [pos_x, pos_y], Title => <title>, Group => <button_group>, [Frame => <frame_name>], [Active => <0/1>], [Font => [family, size, weight]], [Color => [<color>, <state>]], [Tooltip => <tooltip_text>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'RadioButton';

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;
    
    # create radio button
    my $radio_button = $self->_create_radio_widget($object->{name}, %params);
    
    # position the radio button
    $self->_add_to_container($object->{name});
    
    $radio_button->show();
}

# ---------------------------------------------------------------------
# _create_radio_widget(<name>, <params>)
# ---------------------------------------------------------------------
sub _create_radio_widget($@) {
    my $self = shift;
    my ($name, %params) = @_;
    
    # get object
    my $object = $self->get_object($name);
    
    # radio button/menu item specific fields
    $object->{group} = $params{'group'} || undef;
    my $active = $params{'active'} || 0;
    my $font = $params{'font'} || undef;
    my $color = $params{'color'}[0] || undef;
    my $cstate = $params{'color'}[1] || undef;
    
    # create radio button/menu item
    my $radio_widget;
    
    # get the last button/menu item in the group
    my $group = [];
    my $last = undef;
    if (exists($self->{groups}->{$object->{group}})) {
        $last = $self->_get_ref($self->{groups}->{$object->{group}}[-1]);
        #$group = $last->get_group();
    } else {
        $self->{groups}->{$object->{group}} = [];
    }
    
    if (defined($object->{title})) {
        if ($object->{type} eq 'RadioButton') {
            $radio_widget = Gtk2::RadioButton->new($last, _($object->{title}));
        } else {
            $radio_widget = Gtk2::RadioMenuItem->new($last, _($object->{title}));
        }
        
        # if underline in text should use
        if ($self->is_underlined($object->{title})) {
            $radio_widget->set_use_underline(1);
        }
        
    } else {
        if ($object->{type} eq 'RadioButton') {
            $radio_widget = Gtk2::RadioButton->new($last);
        } else {
            $radio_widget = Gtk2::RadioMenuItem->new($last);
        }
    }
    
    # add widget reference to widget object
    $object->{ref} = $radio_widget;
    
    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);

    # set font color if defined
    $self->set_font_color($object->{name}, $color, $cstate) if defined($color);

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # add button/menu item to buttons list
    push(@{$self->{groups}->{$object->{group}}}, $object->{name});
    
    # set radio button/menu item active
    $radio_widget->set_active($active);
    
    return $radio_widget;
}


# *********************************************************************
#   Widget: GtkLinkButton
#   A button bound to an URL.
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: add_link_button
#   Creates a new GtkLinkButton widget.
#
#   A GtkLinkButton is a GtkButton with a hyperlink, similar to the one used by web browsers, which triggers an action when clicked. It is useful to show quick links to resources. 
#
#   Internal Name Type:
#   LinkButton
#
#   Parameters:
#   Name            => <name>                   - Name of the button. Must be unique.
#   Pos|Position    => [pos_x, pos_y]           - Position of the button.
#   Title           => <title>                  - Title of the button (displayed in the button).
#   Uri             => <uri-text>               - A valid URI. It is the tooltip as well and will be shown while hovering over the widget.
#   [Frame          => <frame_name>]            - Optional. Name of the frame if the button is located in one. Must be unique. See <add_frame>.
#   [Font           => [family, size, weight]]  - Optional. Sets a title font. To use the defaults set values with undef.
#   [Color          => [<color>, <state>]]      - Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                           State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (see Gtk2::State).
#   [Size           => [width, height]]         - Optional. Width and height of the button. Default is 80x25.
#   [Func|Function  => <function_click>]        - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                           *Note:* If data is used it have to be set as an array.
#   [Sig|Signal     => <signal>]                - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                           Can be 'activate', 'clicked', 'enter', 'leave' or 'pressed'.
#   [Sens|Sensitive => <sensitive>]             - Optional. Sets the button active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_link_button(Name => 'linkButton', 
#           Pos     => [10, 45], 
#           Title   => "To SimpleGtk2 site", 
#           Uri     => 'https://github.com/ThomasFunk/SimpleGtk2', 
#           Frame   => 'frame2');
#   $win->add_signal_handler('linkButton', 'clicked', 
#                           [\&openPage, $win->get_value('linkButton', 'Uri')]);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/LinkButton.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkLinkButton.html>
#
#   Available Support Functions:
#   state = <get_value> (<name>, "Uri")
#
#   <set_value> (<name>, Uri => <uri-text>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   (width, height) = <get_size> (<name>)
#
#   <set_size> (<name>, <new_width>, <new_height>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
# ---------------------------------------------------------------------
sub add_link_button #(Name => <name>, Position => [pos_x, pos_y], Title => <title>, Uri => <uri-text>, [Frame => <frame_name>], [Font => [family, size, weight]], [Color => [<color>, <state>]], [Size => [width, height]], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'LinkButton';
    
    # link button specific fields
    my $uri = $params{'uri'} || undef;
    my $font = $params{'font'} || undef;
    my $color = $params{'color'}[0] || undef;
    my $cstate = $params{'color'}[1] || undef;

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # create link button
    my $link_button;
    if (defined($uri)) {
        $link_button = Gtk2::LinkButton->new($uri, _($object->{title}));
    } else {
        $self->internal_die($object, "No Uri defined!");
    }

    # set relief to none
    $link_button->set_relief('none');
    
    # add widget reference to widget object
    $object->{ref} = $link_button;
    
    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);

    # set font color if defined
    $self->set_font_color($object->{name}, $color, $cstate) if defined($color);

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the button
    $self->_add_to_container($object->{name});

    $link_button->show();
}


######################################################################
#   Group: Numeric/Text Data Entry
######################################################################

# *********************************************************************
#   Widget: GtkEntry
#   A single line text entry field.
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: add_entry
#   Creates a new GtkEntry widget.
#
#   The GtkEntry widget is a single line text entry widget. 
#   A fairly large set of key bindings are supported by default. 
#   If the entered text is longer than the allocation of the widget, 
#   the widget will scroll so that the cursor position is visible.
#
#   Internal Name Type:
#   Entry
#   
#   Parameters:
#   Name            => <name>                       - Name of the entry. Must be unique.
#   Pos|Position    => [pos_x, pos_y]               - Position of the entry.
#   Size            => [width, height]              - Width and height of the entry.
#   [Title          => <title>]                     - Optional. Text in the entry field.
#   [Frame          => <frame_name>]                - Optional. Name of the frame if the entry is located in one. Must be unique. See <add_frame>.
#   [Font           => [family, size, weight]]      - Optional. Sets the initial font. Font family and size are required if set.
#   [Align          => <xalign>]                    - Optional: Sets the alignment for the contents of the entry. Default: left or right.
#   [Tip|Tooltip    => <tooltip_text>]              - Optional. Text of the tooltip shown while hovering over the entry.
#   [Func|Function  => <function_click>]            - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                               *Note:* If data is used it have to be set as an array.
#   [Sig|Signal     => <signal>]                    - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                               Most used are 'activate', 'changed'. For more see References below.
#   [Sens|Sensitive => <sensitive>]                 - Optional. Sets the entry active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_entry(Name => 'entry1', 
#           Pos     => [200, 20], 
#           Size    => [100, 20], 
#           Title   => 'A text entry field', 
#           Align   => 'right');
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Entry.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkEntry.html>
#
#   Available Support Functions:
#   string = <get_value> (<name>, "Align")
#
#   <set_value> (<name>, Align => "<xalign>")
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_entry #(Name => <name>, Position => [pos_x, pos_y], Size => [width, height], [Title => <title>], [Frame => <frame_name>], [Font => [family, size, weight]], [Align => <xalign>], [Tooltip => <tooltip_text>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Entry';
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # entry specific fields
    my $align = $params{'align'} || 0;
    my $font = $params{'font'} || undef;
    
    # create entry
    my $entry = Gtk2::Entry->new();
    if ($object->{title}) {
        $entry->set_text(_($object->{title}));
    }
    
    # add widget reference to widget object
    $object->{ref} = $entry;
    
    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);

    # add handler 'changed' to update object every time text is changing
    $self->add_signal_handler($object->{name}, 'changed', \&_on_changed_update, $self);
    
    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # check if alignment for text is set
    if ($align eq 'right') {$entry->set_alignment(1);}
    
    # position the entry
    $self->_add_to_container($object->{name});
    
    $entry->show();
}


# *********************************************************************
#   Widget: GtkSlider
#   A horizontal or vertical slider widget for selecting a value from a range.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_slider
#   Creates a new GtkSlider widget.
#
#   The GtkSlider (GtkHScale/GtkVScale) widget is used to allow the user to select a value using a horizontal or vertical slider.
#   The position to show the current value and/or the number of decimal places can be shown, too.
#
#   Internal Name Type:
#   Slider
#   
#   Parameters:
#   Name                => <name>                   - Name of the slider. Must be unique.
#   Pos|Position        => [pos_x, pos_y]           - Position of the slider.
#   Orient|Orientation  => <orientation>            - The orientation of the slider (horizontal, vertical).
#   [Size               => [width, height]]         - Optional. Width and height of the slider.
#   [Start              => <start_value>]           - Optional. The initial start value. Default: 0.0 (double).
#   Min                 => <min_value>              - The minimum allowed value (double).
#   Max                 => <max_value>              - The maximum allowed value (double).
#   Step                => <step_in/decrease>       - The step increment (double).
#   [DrawValue          => <1/0>]                   - Optional. Specifies whether the current value is displayed as a string next to the slider.
#   [ValuePos           => <value_position>]        - Optional: Sets the position in which the current value is displayed. Default: top. Others: left, right, bottom.
#   [Digits             => <used_digits>]           - Optional. Number of decimal places the value will be displayed. Default: 0 (1 digit).
#   [Frame              => <frame_name>]            - Optional. Name of the frame if the slider is located in one. Must be unique. See <add_frame>.
#   [Tip|Tooltip        => <tooltip_text>]          - Optional. Text of the tooltip shown while hovering over the slider.
#   [Func|Function      => <function_click>]        - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                               *Note:* If data is used it have to be set as an array.
#   [Sig|Signal         => <signal>]                - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                               Most used signal is 'value-changed'. For more see References below.
#   [Sens|Sensitive     => <sensitive>]             - Optional. Sets the slider active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_slider(Name => 'hslider', 
#           Pos     => [10, 220], 
#           Size    => [200, -1], 
#           Orient  => 'horizontal', 
#           Start   => 5, 
#           Min     => 0, 
#           Max     => 100, 
#           Step    => 0.1, 
#           Digits  => 1, 
#           Tip     => 'Round and round we go', 
#           Frame   => 'frame2');
#   (end code)
#
#   References:
#   <Gtk2-Perl HScale at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/HScale.pod.html>, 
#   <Gtk2-Perl VScale at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/VScale.pod.html>, 
#   <Gtk2 HScale at https://developer.gnome.org/gtk2/stable//GtkHScale.html>, 
#   <Gtk2 VScale at https://developer.gnome.org/gtk2/stable//GtkVScale.html>
#
#   Available Support Functions:
#   string = <get_value> (<name>, "Active" *or* "Min|Minimum" *or* "Max|Maximum" *or* "Step" *or* "DrawValue" *or* "ValuePos|ValuePosition" *or* "Digits")
#
#   <set_value> (<name>, Start => <start_value> *or* Active => <active_value> *or* 
#                        Min => <min_value> *or* Max => <max_value> *or* 
#                        Step => <step_in/decrease> *or* DrawValue => <1/0> *or* 
#                        ValuePos|ValuePosition => "<value_position>" *or* Digits => <used_digits>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_slider #(Name => <name>, Position => [pos_x, pos_y], Orientation => <orientation>, [Size => [width, height]], [Start => <start_value>], Minimum => <min_value>, Maximum => <max_value>, Step => <step_in/decrease>, [DrawValue => <1/0>], [ValuePosition => <value_position>], [Digits => <used_digits>], [Frame => <frame_name>], [Tooltip => <tooltip_text>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Slider';

    $self->_create_range_widget($object, %params);
# ---------------------------------------------------------------------
# TODO: If a draw value is active the slider is moved to another position.
#       Have to be fixed ?
# ---------------------------------------------------------------------
}


# *********************************************************************
#   Widget: GtkSpinButton
#   Retrieve an integer or floating-point number from the user.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_spin_button
#   Creates a new GtkSpinButton widget.
#
#   A GtkSpinButton is an ideal way to allow the user to set the value of some attributes.
#
#   Rather than having to directly type a number into a GtkEntry, GtkSpinButton allows the 
#   user to click on one of two arrows to increment or decrement the displayed value. 
#
#   A value can still be typed in, with the bonus that it can be checked to ensure it is in a given range.
#
#   Internal Name Type:
#   SpinButton
#   
#   Parameters:
#   Name            => <name>                   - Name of the spin button. Must be unique.
#   Pos|Position    => [pos_x, pos_y]           - Position of the spin button.
#   [Size           => [width, height]]         - Optional. Width and height of the spin button.
#   [Start          => <start_value>]           - Optional. The initial start value. Default: 0.0 (double).
#   Min             => <min_value>              - The minimum allowed value (double).
#   Max             => <max_value>              - The maximum allowed value (double).
#   Step            => <step_in/decrease>       - The step increment (double).
#   Page            => <page_in/decrease>       - The page increment (double).
#   [Snap           => <snap_to_tick>]          - Optional. Sets the policy as to whether values are corrected to the nearest step increment when an invalid value is provided.
#   [Align          => <xalign>]                - Optional: Sets the alignment for the contents of the spin button. Default: left or right.
#   [Rate           => <from 0.0 to 1.0>]       - Optional. Sets the amount of acceleration that the spin button has (0.0 to 1.0). Default: 0.0
#   [Digits         => <used_digits>]           - Optional. Number of decimal places the value will be displayed. Default: 0 (1 digit).
#   [Frame          => <frame_name>]            - Optional. Name of the frame if the spin button is located in one. Must be unique. See <add_frame>.
#   [Tip|Tooltip    => <tooltip_text>]          - Optional. Text of the tooltip shown while hovering over the spin button.
#   [Func|Function  => <function_click>]        - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                           *Note:* If data is used it have to be set as an array.
#   [Sig|Signal     => <signal>]                - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                           Most used signal is 'value-changed'. For more see References below.
#   [Sens|Sensitive => <sensitive>]             - Optional. Sets the spin button active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_spin_button(Name => 'spin1', 
#           Pos     => [10, 60], 
#           Start   => 5, 
#           Min     => 0, 
#           Max     => 10, 
#           Step    => 1, 
#           Tip     => 'Thats a spin button', 
#           Align   => 'right', 
#           Frame   => 'frame1');
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/SpinButton.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkSpinButton.html>
#
#   Available Support Functions:
#   string = <get_value> (<name>, "Active" *or* "Align" *or* "Min|Minimum" *or* "Max|Maximum" *or* "Step" *or* "Snap" *or* "Rate|Climbrate" *or* "Digits")
#
#   <set_value> (<name>, Min => <min_value> *or* Max => <max_value> *or* 
#                        Step => <step_in/decrease> *or* Page => <page_in/decrease> *or* 
#                        Snap => <snap_to_tick> *or* Align => <xalign> *or* 
#                        Rate => <from 0.0 to 1.0> *or* Digits => <used_digits>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_spin_button #(Name => <name>, Position => [pos_x, pos_y], [Size => [width, height]], [Start => <start_value>], Minimum => <min_value>, Maximum => <max_value>, Step => <step_in/decrease>, Page => <page_in/decrease>, [Snap => <snap_to_tick>], [Align => <xalign>], [Rate => <from 0.0 to 1.0>], [Digits => <used_digits>], [Frame => <frame_name>], [Tooltip => <tooltip_text>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'SpinButton';

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # spin button specific fields
    my $start = $params{'start'} || 0.0;
    my $min = $params{'minimum'} || 0.0;
    my $max = $params{'maximum'} || 0.0;
    my $step = $params{'step'} || 0;
    my $page = $params{'page'} || 0;
    my $align = $params{'align'} || 0;
    my $snap = $params{'snap'} || 0;
    my $climbrate = $params{'climbrate'} || 0.0;
    my $digits = $params{'digits'} || 0;

    # first create an adjustment widget to hold information about the range of 
    # values that the spin button can take
    my $adjustment = Gtk2::Adjustment->new( $start,
                                            $min,
                                            $max,
                                            $step,
                                            $page,
                                            0.0);

    # add to object for later manipulation
    $object->{adjustment} = $adjustment;
    
    # now the spin button follows
    my $spin_button = Gtk2::SpinButton->new($adjustment, $climbrate, $digits);
    
    # as climbrate doesn't exist to get/set we hold it in the object
    $object->{climbrate} = $climbrate;
    
    # add widget reference to widget object
    $object->{ref} = $spin_button;
    
    # get initial set value
    $object->{value} = $spin_button->get_value();
    
    # add handler 'value-changed' to update object every time value is changing
    $self->add_signal_handler($object->{name}, 'value-changed', \&_on_changed_update, $self);
    
    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # spin button can contain only numeric values
    $spin_button->set_numeric(1);
    
    # Sets the policy as to whether values are corrected to the nearest step increment
    $spin_button->set_snap_to_ticks($snap);
    
    # set the spin button to wrap around between the upper and lower range values
    $spin_button->set_wrap(1);
    
    # The update policy of the spin button
    $spin_button->set_update_policy ('if-valid');
    
    # set alignment of values
    if ($align eq 'right') {$spin_button->set_alignment(1);}

    # position the spin button
    $self->_add_to_container($object->{name});
    
    $spin_button->show();
}


######################################################################
#   Group: Multiline Text Editor
######################################################################

# *********************************************************************
#   Widget: GtkTextView
#   Widget that displays a GtkTextBuffer.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_text_view
#   Creates a new GtkTextView widget.
#
#   A GtkTextView is a widget which can display a GtkTextBuffer, which represents the text being edited or viewed.
#
#   Internal Name Type:
#   TextView
#   
#   Parameters:
#   Name                => <name>                   - Name of the text view. Must be unique.
#   Pos|Position        => [pos_x, pos_y]           - Position of the text view.
#   Size                => [width, height]          - Width and height of the spin button.
#   Path                => <file_path>              - Path of the text file.
#   *OR*
#   Textbuf|Textbuffer  => <text_buffer_object>     - Sets the buffer being displayed by the text view.
#   *OR*
#   Text                => <text_string>            - Text string to display.
#   [LeftMargin         => <in_pixel>]              - Optional. Sets the default left margin for text in the text view. Default: 0.
#   [RightMargin        => <in_pixel>]              - Optional. Sets the default right margin for text. Default: 0.
#   [Wrap|Wrapped       => <wrap_mode>]             - Optional. Sets the line wrapping for the view. Default: left (right, center, fill).
#   [Justify            => <justification>]         - Optional. Sets the default justification of text. Default: none (char, word, word-char).
#   [Frame              => <frame_name>]            - Optional. Name of the frame if the text view is located in one. Must be unique. See <add_frame>.
#   [Tip|Tooltip        => <tooltip_text>]          - Optional. Text of the tooltip shown while hovering over the text view.
#   [Func|Function      => <function_click>]        - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                               *Note:* If data is used it have to be set as an array.
#   [Sig|Signal         => <signal>]                - Optional. The used action signal. Only in conjunction with Func|Function.
#   [Sens|Sensitive     => <sensitive>]             - Optional. Sets the text view active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   # with file
#   $win->add_text_view(Name => 'tview1', 
#           Pos         => [40, 260], 
#           Size        => [200, 120], 
#           Tip         => 'A text', 
#           Frame       => 'frame2', 
#           Path        => './testem.txt', 
#           Wrapped     => 'char', 
#           LeftMargin  => 10, 
#           RightMargin => 10);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/TextView.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkTextView.html>
#
#   Available Support Functions:
#   value = <get_textview> (<name>, "Path" *or* "Textview" *or* "Textbuf|Textbuffer")
#
#   <set_textview> (<name>, Path => <file_path> *or* Textbuf|Textbuffer => <text_buffer_object> *or* Text => <text_string>)
#
#   string = <get_value> (<name>, "LeftMargin" *or* "RightMargin" *or* "Wrap|Wrapped" *or* "Justify")
#
#   <set_value> (<name>, LeftMargin => <in_pixel> *or* RightMargin => <in_pixel> *or* Wrap|Wrapped => <wrap_mode> *or* Justify => <justification>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   (width, height) = <get_size> (<name>)
#
#   <set_size> (<name>, <new_width>, <new_height>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_text_view #(Name => <name>, Position => [pos_x, pos_y], Size => [width, height], Path => <file_path>, or Textbuffer => <text_buffer_object>, or Text => <text_string>, [LeftMargin => <in_pixel>], [RightMargin => <in_pixel>], [Wrapped => <wrap_mode>], [Justify => <justification>], [Frame => <frame_name>], [Tooltip => <tooltip_text>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'TextView';
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # textview specific fields
    $object->{textview} = undef;
    $object->{path} = $params{'path'} || undef;
    $object->{textbuf} = $params{'textbuffer'} || undef;
    $object->{font} = $params{'font'} || undef;
    my $left_margin = $params{'leftmargin'} || 0;
    my $right_margin = $params{'rightmargin'} || 0;
    my $wrapped = $params{'wrapped'} || 'none';
    my $justify = $params{'justify'} || 'left';
    my $text = $params{'text'} || undef;
    my $sensitive = defined($params{'sensitive'}) ? $params{'sensitive'} : undef;
    my $font = $params{'font'} || undef;

    # create textview
    my $content;
    my $textview = Gtk2::TextView->new();
    
    # for later manipulation we put the textview reference to the textview object
    $object->{textview} = $textview;
    
    # disable edit mode
    $textview->set_editable(0);
    
    # set margins
    $textview->set_left_margin($left_margin);
    $textview->set_right_margin($right_margin);
    
    # set wrap mode
    $textview->set_wrap_mode($wrapped);
    
    # set justification
    $textview->set_justification($justify);
    
    # add content from path or text buffer to textview buffer
    if (defined($object->{path}) or defined($text)) {
        my $buffer = $textview->get_buffer();
        if (defined($object->{path})) {
            $content = `cat $object->{path}` || $self->internal_die($object, "Can't find $object->{path}. Check path.");
        } else {
            $content = $text;
        }
        $buffer->set_text($content);
        $object->{textbuf} = $buffer;
    }
    $textview->set_buffer($object->{textbuf});
    
    $textview->show();
    
    # create a scrolled window to display scrollbars
    my $scrolled_window = Gtk2::ScrolledWindow->new (undef, undef);
    $scrolled_window->set_policy ('automatic', 'automatic');

    # size of the text widget (scrolled window)
    $scrolled_window->set_size_request($object->{width}, $object->{height});
       
    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);
    
    # add textview to scrolled window
    $scrolled_window->add_with_viewport($textview);
    
    # add scrolled window (parent) to window objects list
    $object->{ref} = $scrolled_window;

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the image
    $self->_add_to_container($object->{name});

    $scrolled_window->show();
}


# ---------------------------------------------------------------------
#   Function: get_textview
#   Returns the textview reference, its' textbuffer or the file path.
#   If no <keyname> is given it returns the textview reference only.
#
#   Parameters:
#   <name>      - Name of the textview widget. Must be unique.
#   [<keyname>] - Optional. Possible values: Path, Textview, Textbuf"|"Textbuffer.
#
#   Returns:
#   The textview reference, its' textbuffer or the file path.
# ---------------------------------------------------------------------
sub get_textview #(<name>, [<keyname>])
{
    my $self = shift;
    my $name = shift;
    my $key = _extend(lc(shift)) || undef;
    my $textview = 'Error';

    # get textview object
    my $object = $self->get_object($name);
    my $type = $object->{type};

    if ($type =~ /Textview/) {
        # get textview reference
        if ($key eq 'textview' or $key == undef) {$textview = $object->{textview};}
        # get text buffer
        elsif ($key eq 'textbuffer') {$textview = $object->{textbuf};}
        # get path
        elsif ($key eq 'path') {$textview = $object->{path};}
        # not supported
        elsif ($key =~ /margin$|wrapped|justify/) {
            $self->internal_die($object, "'get_textview' returns textbuffer/textview reference only. Use 'get_value' for \"$key\" instead.");
        }
    
        unless ($textview eq 'Error') {
            return $textview;
        } else {
            $self->internal_die($object, "Unknown parameter \"$key\".");
        }
    } else {
        $self->internal_die($object, "Not a textview object.");
    }
}


# ---------------------------------------------------------------------
#   Function: set_textview
#   Sets a new text, textbuffer or file path.
#
#   Parameters:
#   Name                => <name>                   - Name of the text view. Must be unique.
#   Path                => <file_path>"             - Path of the new text file.
#   *OR*
#   Textbuf|Textbuffer  => <text_buffer_object>     - A new buffer being displayed by the text view.
#   *OR*
#   Text                => <text_string>            - A new Text string to display.
#
#   Returns:
#   None. 
# ---------------------------------------------------------------------
sub set_textview #(Name => <name>, Path => <file_path>, or Textbuffer => <text_buffer_object>, or Text => <text_string>)
{
    my $self = shift;
    my $name = shift;
    my %params = $self->_normalize(@_);
    
    my $object = $self->get_object($name);
    
    # add a new content from path
    my $buffer;
    if (defined($params{'path'})) {
        # add new path
        $object->{path} = $params{'path'};
        # add new content from path to text buffer
        $buffer = $object->{textview}->get_buffer();
        my $content = `cat $object->{path}` || '';
        $buffer->set_text($content);
        $object->{textbuf} = $buffer;
    }
    # add a given string
    elsif (defined($params{'text'})) {
        # add new content from text to text buffer
        $buffer = $object->{textview}->get_buffer();
        my $content = $params{'text'};;
        $buffer->set_text($content);
        $object->{textbuf} = $buffer;
    }
    # add a given text buffer
    elsif (defined($params{'textbuffer'})) {
        $object->{textbuf} = $params{'textbuffer'};
    }
    # unsupported
    else {
        my $rest = join(", ", keys %params);
        $self->internal_die($object, "Unknown parameter(s): \"$rest\".");
    }
    
    # add  to textview buffer
    $object->{textview}->set_buffer($object->{textbuf});
    
    # show it
    $object->{textview}->show();
}


######################################################################
#   Group: Tree and List Widgets
######################################################################

# *********************************************************************
#   Widget: GtkTreeView
#   A widget for displaying both trees and lists.
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: add_treeview
#   Creates a new GtkTreeView widget.
#
#   A Widget that displays List and Tree objects implemented by the GtkTreeModel interface.
#
#   Internal Name Type:
#   List or Tree
#   
#   Parameters:
#   Name                => <name>                       - Name of the tree view. Must be unique.
#   Type                => <List|Tree>                  - Type of the tree view. 'List' or 'Tree'.
#   Pos|Position        => [pos_x, pos_y]               - Position of the tree view.
#   Size                => [width, height]              - Width and height of the tree view.
#   Headers             => [<Array_of_column_pairs>]]   - List of <column_text> => <column_type>. 
#   [Data               => [<Array_of_arrays>]]         - Optional. Data of the list or tree. Can be set later with <set_value>.
#   [Treeview           => <Gtk2::TreeView>             - Optional. An existing Gtk2::TreeView object.
#   [Mode               => <selection mode>]            - Optional. Set selection mode. Default is 'single'. Other
#                                                                   possibilities: 'none', 'browse' and 'multiple'.
#   [Frame              => <frame_name>]                - Optional. Name of the frame if the text view is located in one. Must be unique. See <add_frame>.
#   [Func|Function      => <function_click>]            - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                                   *Note:* If data is used it have to be set as an array.
#   [Sig|Signal         => <signal>]                    - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                                   Most used is 'cursor-changed'.
#   [Sens|Sensitive     => <sensitive>]                 - Optional. Sets the tree view active/inactive. Default: 1 (active).
#
#   Possible column types:
#   text    -   Normal text strings.
#   int     -   Integer values.
#   double  -   Double-precision floating point values.
#   bool    -   Boolean values, displayed as toggle-able checkboxes.
#   scalar  -   A perl scalar, displayed as a text string by default.
#   pixbuf  -   A Gtk2::Gdk::Pixbuf.
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   # list
#   $win->add_treeview(Name => 'slist',
#           Type    => 'List',
#           Pos     => [10, 10],
#           Size    => [150, 150],
#           Headers => ['No'    => 'int', 
#                       'Text1' => 'text',
#                       'Text2' => 'text'],
#           Data    => [[1, 'bla', 'lol'],
#                       [2, 'snore', 'moe'],
#                       [3, 'yalla', 'meh']]);
#   $window->add_signal_handler('slist', 'cursor-changed', \&show_index);
#   --------------------------------------
#   # tree
#   $win->add_treeview(Name => 'stree',
#           Type    => 'Tree',
#           Pos     => [10, 10],
#           Size    => [350, 320],
#           Headers => $headers,
#           Data    => \@tree,
#           Sens    => 1);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/TreeView.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkTreeView.html>
#
#   Available Support Functions:
#   reference = <get_treeview> (<name>, "List" *or* "Tree")
#
#   <set_value> (<name>, mode => <selection_mode> *or* sortable => <0/1> *or* reordable => <0/1>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   (width, height) = <get_size> (<name>)
#
#   <set_size> (<name>, <new_width>, <new_height>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   List only Support Functions:
#   value = <get_value> (<name>, "Editable" *or* "Path" *or* "Cell")
#
#   <set_value> (<name>, select => <row|[row_list]> *or* unselect => <row|[row_list]>)
#
#   Tree only Support Functions:
#   value = <get_value> (<name>, "Iter" *or* "Path" *or* "Row")
#
#   <set_value> (<name>, iter => <iter> *or* path => <path_object> *or* row => [row_values])
#
# ---------------------------------------------------------------------
sub add_treeview #(Name => <name>, Type => <List|Tree>, Position => [pos_x, pos_y], Size => [width, height], Headers => [<Array_of_column_pairs>], [Data => [<Array_of_arrays>]], [Treeview => <Gtk2::TreeView>], [Mode => <selection mode>], [Frame => <frame_name>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);

    # check for correct type
    my $tview_type = $params{'type'} || undef;
    if ($tview_type =~ /List|Tree/) {
        $object->{type} = $tview_type;
    } else {
        unless (defined($tview_type)) {
            $self->internal_die("No treeview type defined! Possible values are: 'List' or 'Tree'.");
        } else {
            $self->internal_die($object, "Wrong treeview type defined! Possible values are: 'List' or 'Tree'.");
        }
    }

    # treeview specific fields
    $object->{headers} = $params{'headers'} || $self->internal_die($object, "No column header(s) defined!");
    $object->{data} = $params{'data'} || undef;
    my $treeview = $params{'treeview'} || undef;
    my $selection_mode = $params{'mode'} || undef;
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    my $list_or_tree;
    if ($tview_type eq 'List') {
        # create list
        if (defined($treeview)) {
            $list_or_tree = Gtk2::Ex::Simple::List->new_from_treeview($treeview, @{$object->{headers}});
        } else {
            $list_or_tree = Gtk2::Ex::Simple::List->new(@{$object->{headers}});
        }
    } else {
        if (defined($treeview)) {
            $list_or_tree = Gtk2::Ex::Simple::Tree->new_from_treeview($treeview, @{$object->{headers}});
        } else {
            $list_or_tree = Gtk2::Ex::Simple::Tree->new(@{$object->{headers}});
        }
    }

    # for later manipulation we put the list/tree reference to the treeview object
    $object->{treeview} = $list_or_tree;
    
    # if data available
    if (defined($object->{data})) {
        $list_or_tree->set_data_array($object->{data});
        $object->{data} = $list_or_tree->{data};
    }
    
    # if selection mode is set
    if (defined($selection_mode)) {
        my $treeselection = $list_or_tree->get_selection();
        $treeselection->set_mode($selection_mode);
    }
    
    # create a scrolled window to display scrollbars
    my $scrolled_window = Gtk2::ScrolledWindow->new (undef, undef);
    $scrolled_window->set_policy ('automatic', 'automatic');

    # size of the list/tree widget (scrolled window)
    $scrolled_window->set_size_request($object->{width}, $object->{height});
       
    # add list/tree to scrolled window
    $scrolled_window->add_with_viewport($list_or_tree);
    
    # add scrolled window (parent) to window objects list
    $object->{ref} = $scrolled_window;

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the list/tree
    $self->_add_to_container($object->{name});

    $scrolled_window->show();
}


# ---------------------------------------------------------------------
#   Function: get_treeview
#   Returns the treeview reference.
#
#   Parameters:
#   <name>          - Name of the treeview widget. Must be unique.
#   [<keyname>]     - Optional. Possible values: "List" or "Tree".
#
#   Returns:
#   The textview reference, its' textbuffer or the file path.
# ---------------------------------------------------------------------
sub get_treeview #(<name>, [<keyname>])
{
    my $self = shift;
    my $name = shift;
    my $key = shift;
    $key = _extend(lc($key)) if defined($key);
    my $treeview = 'Error';

    # get treeview object
    my $object = $self->get_object($name);
    my $type = $object->{type};

    if ($type =~ /List|Tree/) {
        if (defined($key)) {
            # get list reference
            if ($key eq 'list') {$treeview = $object->{treeview};}
            # get tree reference
            elsif ($key eq 'tree') {$treeview = $object->{treeview};}
            # not supported
            elsif ($key =~ /editable|path|cell/) {
                $self->internal_die($object, "'get_treeview' returns $type reference only. Use 'get_value' for \"$key\" instead.");
            }
        } else {
            $treeview = $object->{treeview};
        }
    
        unless ($treeview eq 'Error') {
            return $treeview;
        } else {
            $self->internal_die($object, "Unknown parameter \"$key\". Possible values are: list or tree.");
        }
    } else {
        $self->internal_die($object, "Not a treeview object.");
    }
}


# ---------------------------------------------------------------------
# row manipulation
# modify_list_data(<name>, <command> => <modification_array>)
# <command> are: 'push' 'pop', 'unshift', 'shift', 'delete', 'clear'
# cell manipulation
# modify_list_data(<name>, set => [<row|iter>, <column>, <modification>])
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
#   Function: modify_list_data
#   Modifies the list data.
#
#   Parameters:
#   <name>                                                  - Name of the treeview widget. Must be unique.
#   <command>   => <modification_array>                     - For row manipulation. Possible commands: "push" "pop", "unshift", "shift", "delete", "clear".
#   *OR*
#   <command>                                               - For row manipulation. Possible commands: "push" "pop", "unshift", "shift", "delete", "clear".
#   set         => [<row|iter>, <column>, <modification>]   - For cell manipulation.
#
#   Returns:
#   None.
#
#   Examples:
#   (start code)
#   # *** Row manipulation ***
#
#   # push a row onto the end of the list
#   $win->modify_list_data('slist', push => [(++$i), 'woop', 'chakka']);
#   # pop a row off of the end of the list
#   $rowref = pop @{$slist->{data}};
#   # unshift a row onto the beginning of the list
#   unshift @{$slist->{data}}, [col1_data, col2_data, ..., coln_data];
#   # shift a row off of the beginning of the list
#   $rowref = shift @{$slist->{data}};
#   # delete the row at index $n, 0 indexed
#   splice @{ $slist->{data} }, $n, 1;
#   # set the entire list to be the data in a array
#   @{$slist->{data}} = ( [row1, ...], [row2, ...], [row3, ...] );
#
# Getting at the data in the list:
#
#   # get an array reference to the entire nth row
#   $rowref = $slist->{data}[n];
#   # get the scalar in the mth column of the nth row, 0 indexed
#   $val = $slist->{data}[n][m];
#   # set an array reference to the entire nth row
#   $slist->{data}[n] = [col1_data, col2_data, ..., coln_data];
#   # get the scalar in the mth column of the nth row, 0 indexed
#   $slist->{data}[n][m] = $rowm_coln_value;
#   --------------------------------------
#   (end code)
 # ---------------------------------------------------------------------
sub modify_list_data($@) {
    my $self = shift;
    my $name = shift;
    my %cmd_hash = @_;
    my @keys = keys %cmd_hash;
    my $command = $keys[0];
    my $modification = $cmd_hash{$command};
    $command = _extend(lc($command));
    my $rc = 1;
    
    # get list object
    my $list = $self->get_object($name);
    
    # check if set or others
    if ($command eq 'set') {
        my $row_iter = $$modification[0];
        my $column = $$modification[1];
        # check if first part is an iter object
        if (ref($row_iter) =~ /Gtk2::TreeIter/) {
            $list->{treeview}->set($row_iter, $column, $$modification[2]);
        } else {
            $list->{data}[$row_iter][$column] = $$modification[2];
        }
        $rc = 0;
    } else {
        unless (defined($modification)) {
            # clear array
            if ($command eq 'clear') {@{$list->{data}} = []; $rc = 0;}
            # pop a row off of the end of the list
            elsif ($command eq 'pop') {$rc = pop(@{$list->{data}});}
            # shift a row off of the beginning of the list
            elsif ($command eq 'shift') {$rc = shift(@{$list->{data}});}
        } else {
            # push a row onto the end of the list
            if ($command eq 'push') {push(@{$list->{data}}, $modification); $rc = 0;}
            # unshift a row onto the beginning of the list
            elsif ($command eq 'unshift') {unshift(@{$list->{data}}, $modification); $rc = 0;}
            # delete the row at index $n, 0 indexed
            elsif ($command eq 'delete') {splice(@{$list->{data}}, $modification, 1); $rc = 0;}
        }
    }

    unless ($rc == 1) {
        return $rc;
    } else {
        $self->internal_die($list, "Unknown parameter \"$command\". Possible values are: 'push' 'pop', 'unshift', 'shift', 'delete' or 'clear'.");
    }
}


# ---------------------------------------------------------------------
# modify_tree_data(<name>, <command> => <path>, <modification>)
# modify_tree_data(<name>, add => <path>, [x,y,z,...])
# modify_tree_data(<name>, change => <path>, <index> => <value>)
# modify_tree_data(<name>, delete => <path>)
# <command> are: 'add', 'delete', change
# <path> can be a treepath or treepath string
# ---------------------------------------------------------------------
sub modify_tree_data($@) {
    my $self = shift;
    my $name = shift;
    my (%cmd_hash, $modification) = @_;
    
#    $command = _extend(lc($command));
#    my $rc = 1;
    
    # get tree object
    my $tree = $self->get_object($name);
    
#    unless (defined($modification)) {
#        # delete entry
#        if ($command eq 'clear') {@{$list->{data}} = []; $rc = 0;}
#        # pop a row off of the end of the list
#        elsif ($command eq 'pop') {$rc = pop(@{$list->{data}});}
#        # shift a row off of the beginning of the list
#        elsif ($command eq 'shift') {$rc = shift(@{$list->{data}});}
#    } else {
#        # push a row onto the end of the list
#        if ($command eq 'push') {push(@{$list->{data}}, $modification); $rc = 0;}
#        # unshift a row onto the beginning of the list
#        elsif ($command eq 'unshift') {unshift(@{$list->{data}}, $modification); $rc = 0;}
#        # delete the row at index $n, 0 indexed
#        elsif ($command eq 'delete') {splice(@{$list->{data}}, $modification, 1); $rc = 0;}
#    }
#    unless ($rc == 1) {
#        return $rc;
#    } else {
#        $self->internal_die($list, "Unknown parameter \"$command\". Possible values are: 'push' 'pop', 'unshift', 'shift', 'delete' or 'clear'.");
#    }
}


######################################################################
#   Group: Combo Box and Menus
######################################################################

# *********************************************************************
#   Widget: GtkComboBox
#   A widget used to choose from a list of items.
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: add_combo_box
#   Creates a new GtkComboBox widget.
#
#   A GtkComboBox is a widget that allows the user to choose from a list of valid choices. 
#   The GtkComboBox displays the selected choice. When activated, the GtkComboBox displays 
#   a popup which allows the user to make a new choice.
#
#   Internal Name Type:
#   ComboBox
#   
#   Parameters:
#   Name            => <name>                       - Name of the combo box. Must be unique.
#   Pos|Position    => [pos_x, pos_y]               - Position of the combo box.
#   Data            => [Array_of_values>]           - Array of values/strings being displayed in the combo box.
#   [Start          => <start_value>]               - Optional. Sets the active item of the combo box to be the item at index. Default: 0.
#   [Size           => [width, height]]             - Optional. Width and height of the combo box.
#   [Frame          => <frame_name>]                - Optional. Name of the frame if the combo box is located in one. Must be unique. See <add_frame>.
#   [Tip|Tooltip    => <tooltip_text>]              - Optional. Text of the tooltip shown while hovering over the combo box.
#   [Func|Function  => <function_click>]            - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                               *Note:* If data is used it have to be set as an array.
#   [Sig|Signal     => <signal>]                    - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                               Most used signal is 'changed'. For more see References below.
#   [Sens|Sensitive => <sensitive>]                 - Optional. Sets the combo box active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_combo_box(Name => 'combo1', 
#           Pos     => [100, 60], 
#           Data    => ['one', 'two', 'three', 'four'], 
#           Start   => 1, 
#           Tip     => 'Jup', 
#           Frame   => 'frame1');
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/ComboBox.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkComboBox.html>
#
#   Available Support Functions:
#   state = <is_active> (<name>, <value|string>)
#
#   string = <get_value> (<name>, "Active" or "Data" or "Columns")
#
#   <set_value> (<name>, Active => "<active_index>" *or* Data => [<Array_of_values>] *or* Columns => <wrap_list_to_x_columns>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_combo_box #(Name => <name>, Position => [pos_x, pos_y], Data => [Array_of_values>], [Start => <start_value>], [Size => [width, height]], [Frame => <frame_name>], [Tooltip => <tooltip_text>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'ComboBox';

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # combo box specific fields
    $object->{data} = $params{'data'} || [];
    my $start = $params{'start'} || 0;
    my $columns = $params{'columns'} || undef;

    # create Gtk2::TreeModel object
    my $model = Gtk2::ListStore->new(qw/Glib::String/);
    
    # add data to ListStore object
    foreach(@{$object->{data}}) {
        my $iter = $model->append;
        $model->set($iter,0 => _($_));
    }   
    
    # create combo box
    my $combo_box = Gtk2::ComboBox->new_text();
    $combo_box->set_model($model);
    
    # add widget reference to widget object
    $object->{ref} = $combo_box;
    
    # set active item
    $combo_box->set_active($start);
    
    # check if list should wrap into x columns
    $combo_box->set_wrap_width($columns) if defined($columns);
    
    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the combo box
    $self->_add_to_container($object->{name});
    
    $combo_box->show();
}


# *********************************************************************
#   Widget: GtkMenuBar
#   A standard menu bar.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_menu_bar
#   Creates a new GtkMenuBar widget.
#
#   The GtkMenuBar is a subclass of GtkMenuShell which contains one to many GtkMenuItem. The result is a standard menu bar which can hold many menu items.
#
#   Internal Name Type:
#   MenuBar
#   
#   Parameters:
#   Name            => <name>                       - Name of the menu bar. Must be unique.
#   Pos|Position    => [pos_x, pos_y]               - Position of the menu bar.
#   [Size           => [width, height]]             - Optional. Width and height of the menu bar. Default: at top of the window.
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_menu_bar(Name => 'menubar1', Pos => [0,0]);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/MenuBar.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkMenuBar.html>
#
#   Available Support Functions:
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (width, height) = <get_size> (<name>)
#
#   <set_size> (<name>, <new_width>, <new_height>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
# ---------------------------------------------------------------------
sub add_menu_bar #(Name => <name>, Position => [pos_x, pos_y], [Size => [width, height]])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'MenuBar';
    
    # create vbox to put menubar in (for showing)
    my $vbox = Gtk2::VBox->new();
    
    # check if width and height is given
    if ($object->{width} || $object->{height}) {
        $vbox->set_size_request ($object->{width}, $object->{height});
    } else {
        # get the width of the main window
        my $win_width = $self->get_object($self->{name})->{width};
        
        if ($win_width != 0) {
            # add 2 pixels to pos_x for centering
            $object->{pos_x} += 2;
            
            # create menu bar width (-2 is needed because of the vertical scrollbar)
            my $mbar_width = $win_width - 2*$object->{pos_x} - 2;
            $vbox->set_size_request ($mbar_width, -1);
        }
    }
    
    # create menu bar
    my $menu_bar = Gtk2::MenuBar->new();
    
    # for later manipulation we put the menubar reference to the menubar object
    $object->{menubar} = $menu_bar;
    
    # add vbox instead of menu bar to object
    $object->{ref} = $vbox;
    
    # add object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # position the menu bar
    $self->_add_to_container($object->{name});

    $vbox->add($menu_bar);
    #$vbox->pack_start($menu_bar,1,1,0);
    
    # get size
    my $req = $vbox->size_request();
    $object->{width} = $req->width;
    $object->{height} = $req->height;
    
    # add menubar item to lates list => will show while show_all()
    push(@{$self->{lates}}, $object->{name});
}


# *********************************************************************
#   Widget: GtkMenu
#   A menu widget.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_menu
#   Creates a new GtkMenu widget.
#
#   A GtkMenu is a GtkMenuShell that implements a drop down menu consisting of a list of GtkMenuItem 
#   objects which can be navigated and activated by the user to perform application functions.
#
#   A GtkMenu is most commonly dropped down by activating a GtkMenuItem in a GtkMenuBar or popped up by activating a GtkMenuItem in another GtkMenu. 
#
#   Internal Name Type:
#   Menu
#   
#   Parameters:
#   Name            => <name>                       - Name of the menu. Must be unique.
#   Menubar         => <menu_bar>                   - Name of the menu bar the menu is registered. Must be unique. See <add_menubar>.
#   Title           => <title>                      - Text of the menu. An underline at the beginning of the text actvates a hotkey.
#   [Justify        => <justification>]             - Optional. The position in the menu bar. Default: left (right).
#   [Sens|Sensitive => <sensitive>]                 - Optional. Sets the menu active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   # menu Edit
#   $win->add_menu(Name => 'menu_edit',
#           Title   => '_Edit', 
#           Menubar => 'menubar1');
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Menu.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkMenu.html>
#
#   Available Support Functions:
#   string = <get_value> (<name>, "Justify")
#
#   <set_value> (Justify => <justification>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   (width, height) = <get_size> (<name>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
# ---------------------------------------------------------------------
sub add_menu #(Name => <name>, Menubar => <menu_bar>, Title => <title>, [Justify => <justification>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Menu';
    
    # menu specific fields
    my $justify = defined($params{'justify'}) and $params{'justify'} eq 'right' ? 1 : 0;
    my $sensitive = defined($params{'sensitive'}) ? $params{'sensitive'} : undef;
    my $mbar_name = defined($params{'menubar'}) ? $params{'menubar'} : undef;

    # create menu
    my $menu = Gtk2::Menu->new();

    # add widget object to window objects list
    $object->{ref} = $menu;
    $self->{objects}->{$object->{name}} = $object;

    # add title to menu
    my $menu_title_item = Gtk2::MenuItem->new(_($object->{title}));
    
    # add menu title item to menu object for later manipulation
    $object->{title_item} = $menu_title_item;

    #set menu title item as sub menu
    $menu_title_item->set_submenu($menu);
                
    # set position of the menu in the menubar
    $menu_title_item->set_right_justified($justify);
    
    # set sensitive state
    $object->{title_item}->set_sensitive($sensitive) if defined($sensitive);

    # add it to menubar
    my $menu_bar = $self->get_object($mbar_name);
    $menu_bar->{menubar}->append($menu_title_item);
}


# ---------------------------------------------------------------------
# sub add_menu_popup(Name => 'PopupMenu', Func => <function_click>, Area => [310, 345])
# ---------------------------------------------------------------------


# *********************************************************************
#   Widget: GtkMenuItem
#   The widget used for item in menus.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_menu_item
#   Creates a new GtkMenuItem widget.
#
#   The GtkMenuItem widget and the derived widgets are the only valid childs for menus.
#
#   Their function is to correctly handle highlighting, alignment, events and submenus.
#
#   Internal Name Types:
#   MenuItem, TearOffMenuItem, SeparatorMenuItem, RadioMenuItem or CheckMenuItem
#   
#   Parameters:
#   Name            => <name>               - Name of the menu item. Must be a unique.
#   Menu            => <menu_name>          - Name of the menu which shall hold the menu item. Must be a unique. See <add_menu>.
#   [Type           => <type>]              - Optional. Menu item type. Default: Item. Others are: tearoff, radio, check, separator.
#   [Title          => <title>]             - Optional. Title of the menu item. Not available for tearoff and separator.
#   [Tip|Tooltip    => <tooltip_text>]      - Optional. Text of the tooltip shown while hovering over the menu item. Not available for separator.
#   [Icon           => <path|stock|name>]   - Optional. Path of an icon, stock id or icon name on a standard menu item. Not available for separator.
#   Group           => <group_name>         - Name of the radio menu group the menu item is associated to. Must be unique.
#   Active          => <0/1>                - Sets the status of the radio menu. Only one in the group can be set to 1! Default: 0
#   [Func|Function  => <function>]          - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                       *Note:* If data is used it have to be set as an array.
#   [Sig|Signal     => <signal>]            - Optional. Signal/event. Only in conjunction with 'Func'.
#   [Sens|Sensitive => <sensitive>]         - Optional. Set menu item active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   # menu tearoff
#   $win->add_menu_item(Name => 'menu_item_toff',
#           Type    => 'tearoff', 
#           Menu    => 'menu_edit', 
#           Tip     => 'This is a tearoff');
#
#   # menu item Save
#   $win->add_menu_item(Name => 'menu_item_save', 
#           Icon    => 'gtk-save', 
#           Menu    => 'menu_edit', 
#           Tip     => 'This is the Save entry');
#
#   # separator
#   $win->add_menu_item(Name => 'menu_item_sep1', 
#           Type    => 'separator', 
#           Menu    => 'menu_edit');
#
#   # icon
#   $win->add_menu_item(Name => 'menu_item_icon', 
#           Title   => 'Burger', 
#           Icon    => './1.png', 
#           Menu    => 'menu_edit', 
#           Tip     => 'This is a Burger');
#
#   # check menu
#   $win->add_menu_item(Name => 'menu_item_check', 
#           Type    => 'check', 
#           Title   => 'Check em', 
#           Menu    => 'menu_edit', 
#           Tip     => 'This is a Check menu', 
#           Active  => 1);
#
#   # radio menu
#   $win->add_menu_item(Name => 'menu_item_radio1', 
#           Type    => 'radio', 
#           Title   => 'First', 
#           Menu    => 'menu_edit', 
#           Tip     => 'First radio', 
#           Group   => 'Yeah', 
#           Active  => 1);
#   $win->add_menu_item(Name => 'menu_item_radio2', 
#           Type    => 'radio', 
#           Title   => 'Second', 
#           Menu    => 'menu_edit', 
#           Tip     => 'Second radio', 
#           Group   => 'Yeah');
#   $win->add_menu_item(Name => 'menu_item_radio3', 
#           Type    => 'radio', 
#           Title   => '_Third', 
#           Menu    => 'menu_edit', 
#           Tip     => 'Third radio', 
#           Group   => 'Yeah');
#   (end code)
#
#   References:
#   Gtk2-Perl <MenuItem at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/MenuItem.pod.html>, 
#   <RadioMenuItem at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/RadioMenuItem.pod.html>, 
#   <CheckMenuItem at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/CheckMenuItem.pod.html>, 
#   <SeparatorMenuItem at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/SeparatorMenuItem.pod.html>,
#   <TearoffMenuItem at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/TearoffMenuItem.pod.html>
#
#   Gtk2 <MenuItem at https://developer.gnome.org/gtk2/stable//GtkMenuItem.html>, 
#   <RadioMenuItem at https://developer.gnome.org/gtk2/stable//GtkRadioMenuItem.html>, 
#   <CheckMenuItem at https://developer.gnome.org/gtk2/stable//gtk2-gtkcheckmenuitem.html>, 
#   <SeparatorMenuItem at https://developer.gnome.org/gtk2/stable//GtkSeparatorMenuItem.html>,
#   <TearoffMenuItem at https://developer.gnome.org/gtk2/stable//GtkTearoffMenuItem.html>
#
#   Available Support Functions:
#   string = <get_value> (<name>, "IconPath" *or* "StockIcon" *or* "IconName" *or* "Icon" *or* "Active" *or* "Group" *or* "Groupname|Gname")
#
#   <set_value> (Icon => <path|stock|name> *or* Active => <0/1>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   (width, height) = <get_size> (<name>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_menu_item #(Name => <name>, Menu => <menu_name>, [Type => <type>], [Title => <title>], [Tip|Tooltip => <tooltip_text>], [Icon => <path|stock|name>], Group => <group_name>, Active => <0/1>, [Func|Function => <function>], [Sig|Signal => <signal>], [Sens|Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    
    # sort out useless params depending on the item type
    if (exists($params{'type'})) {
        if ($params{'type'} =~ /tearoff|separator/) {
            $params{'type'} = $params{'type'} eq 'tearoff' ? 'TearOffMenuItem' : 'SeparatorMenuItem';
            # remove params
            delete $params{'title'};
            delete $params{'icon'};
            delete $params{'function'};
        }
        elsif ($params{'type'} eq 'radio') {
            $params{'type'} = 'RadioMenuItem';
            delete $params{'icon'};
        }
        elsif ($params{'type'} eq 'check') {
            $params{'type'} = 'CheckMenuItem';
            delete $params{'icon'};
        }
        else {
            $params{'type'} = 'MenuItem';
        }
    } else {
        $params{'type'} = 'MenuItem';
    }
    
    my $object = _new_widget(%params);
    
    # add object to object list
    $self->{objects}->{$object->{name}} = $object;

    # common menu item specific fields
    my $menu = $self->_get_ref($params{'menu'});
    my $icon = $object->{icon} = $params{'icon'} || undef;
        
    # create menu item
    my $menu_item;
    
    # check what type of menu item should be created
    unless ($object->{type} eq 'CheckMenuItem' or $object->{type} eq 'RadioMenuItem') {
        my $sensitive = defined($params{'sensitive'}) ? $params{'sensitive'} : undef;
        if (!defined($object->{type}) or $object->{type} eq 'MenuItem') {
            # standard menu item specific fields
            my $function = $params{'function'} || undef;
            my $signal = $params{'signal'} || 'active';
    
            # first check if icon is suggested
            if (defined($icon)) {
                # stock icon?
                if ($icon =~ /^gtk-/) {
                    $menu_item = Gtk2::ImageMenuItem->new_from_stock($icon, undef);
                } else {
                    $menu_item = Gtk2::ImageMenuItem->new(_($object->{title}));
                    my $image;
                    # path or theme icon name?
                    if (-e $icon) {
                        $image = Gtk2::Image->new_from_file($icon);
                    } else {
                        $image = Gtk2::Image->new_from_icon_name($icon, 'menu');
                    }
                    $menu_item->set_image($image);
                }
            } else {
                # is standard menu item underlined?
                if ($self->is_underlined($object->{title})) {
                    $menu_item = Gtk2::MenuItem->new_with_mnemonic(_($object->{title}));
                } else {
                    $menu_item = Gtk2::MenuItem->new_with_label(_($object->{title}));
                }
            }
            # add signal handler if function is given
            if (defined($function)) {
                $self->add_signal_handler($object->{name}, $signal, $function);
            }
        } else {
            if ($object->{type} eq 'TearOffMenuItem') {
                $menu_item = Gtk2::TearoffMenuItem->new();
            }        
            elsif ($object->{type} eq 'SeparatorMenuItem') {
                $menu_item = Gtk2::SeparatorMenuItem->new();
            }
        }
            
        # add widget reference to window objects list
        $object->{ref} = $menu_item;
    
        # size of the menu item
        my $req = $menu_item->size_request();
        $object->{width} = $req->width;
        $object->{height} = $req->height;
        
        # set tooltip if needed
        $self->add_tooltip($object->{name});
    
        # set sensitive state
        $object->{ref}->set_sensitive($sensitive) if defined($sensitive);
    } else {
        if ($object->{type} eq 'CheckMenuItem') {
            $menu_item = $self->_create_check_widget($object->{name}, %params);
        }
        elsif ($object->{type} eq 'RadioMenuItem') {
            $menu_item = $self->_create_radio_widget($object->{name}, %params);
        }
    }
    
    # add menu item to menu
    $menu->append($menu_item);
}


######################################################################
#   Group: Selectors (File/Font)
######################################################################

# *********************************************************************
#   Widget: GtkFileChooserButton
#   A button to launch a file selection dialog.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_filechooser_button
#   Creates a new GtkFileChooserButton widget.
#
#   The GtkFileChooserButton is a widget that lets the user select a file or folder. It implements the GtkFileChooser interface.
#
#   Internal Name Type:
#   FileChooserButton
#   
#   Parameters:
#   Name            => <name>                                           - Name of the button. Must be unique.
#   Pos|Position    => [pos_x, pos_y]                                   - Position of the button.
#   Title           => <title>                                          - Title of the button (displayed in the button).
#   Action          => <open_mode>                                      - Sets the mode which confirmation dialog should appear. The open modes are: 'open' and 'select-folder'.
#   [Frame          => <frame_name>]                                    - Optional. Name of the frame if the button is located in one. Must be unique. See <add_frame>.
#   [File           => <file_path>]                                     - Optional. Sets a file path for 'open' action.
#   [Filter         => <pattern|mimetype> | [<name>, <pattern|mimetype>]]      - Optional. Sets the current file filter for 'open' action.
#   [Folder         => <directory>]                                     - Optional. Sets a directory for 'select-folder' action or if no file path is set for 'open' action.
#   [Size           => [width, height]]                                 - Optional. Width and height of the button. Default is 80x25.
#   [Tip|Tooltip    => <tooltip_text>]                                  - Optional. Text of the tooltip shown while hovering over the button.
#   [Func|Function  => <function_click>]                                - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                                                   *Note:* If data is used it have to be set as an array.
#   [Sig|Signal     => <signal>]                                        - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                                                   Can be 'activate', 'clicked', 'enter', 'leave' or 'pressed'.
#   [Sens|Sensitive => <sensitive>]                                     - Optional. Sets the button active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   # show only images. Start folder is ~/Pictures
#   $win->add_filechooser_button(Name => 'FButton2',
#           Pos     => [40, 70],
#           Size    => [120, 40],
#           Title   => "Select an image",
#           Action  => 'open',
#           Folder  => "$ENV{HOME}/Pictures",
#           Filter  => ['Images', '*.png']);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/FileChooserButton.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkFileChooserButton.html>
#
#   Available Support Functions:
#   string = <get_value> (<name>, )
#
#   <set_value> ()
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   (width, height) = <get_size> (<name>)
#
#   <set_size> (<name>, <new_width>, <new_height>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_filechooser_button #(Name => <name>, Position => [pos_x, pos_y], Title => <title>, Action => <open_mode>, [Frame => <frame_name>], [File => <file_path>], [Filter => <pattern|mimetype> | [<name>, <pattern|mimetype>]], [Folder => <directory>], [Size => [width, height]], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'FileChooserButton';
    
    # filechooser button specific fields
    my $action = $params{'action'} || undef;
    my $file = $params{'file'} || undef;
    my @filter = (undef, undef);
    if (defined($params{'filter'})) {
        if (ref($params{'filter'}) eq 'ARRAY') {
            $filter[0] = $params{'filter'}[0];
            $filter[1] = $params{'filter'}[1];
        } else {
            $filter[1] = $params{'filter'};
        }
    }
    $object->{filter} = undef;
    my $folder = $params{'folder'} || undef;

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # create filechooser button
    my $filechooser_button;
    if (defined($action)) {
        $filechooser_button = Gtk2::FileChooserButton->new(_($object->{title}), $action);
    } else {
        $self->internal_die($object, "No action defined!");
    }

    # set file or folder if defined
    if ($action eq 'open') {
        if (defined($file)) {
            $filechooser_button->set_filename($file);
        } else {
            $filechooser_button->set_current_folder($folder) if defined($folder);
        }
    } else {
        $filechooser_button->set_current_folder($folder) if defined($folder);
    }
    
    # set filter if defined
    if (defined($filter[1])) {
        my $file_filter = Gtk2::FileFilter->new();
        # filter type name
        if (defined($filter[0])) {
            $file_filter->set_name($filter[0]);
        }
        # mimetype or pattern
        if ($filter[1] =~ /\//) {
            $file_filter->add_mime_type($filter[1]);
        } else {
            $file_filter->add_pattern($filter[1]);
        }
        # add filter to object for later manipulation
        $object->{filter} = $file_filter;
        # add filter to button
        if (defined($filter[0])) {
            $filechooser_button->add_filter($file_filter);
        } else {
            $filechooser_button->set_filter($file_filter);
        }
    }
    
    # add widget reference to widget object
    $object->{ref} = $filechooser_button;
    
    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the button
    $self->_add_to_container($object->{name});

    $filechooser_button->show();
}


# *********************************************************************
#   Widget: GtkFileChooserDialog
#   A file chooser dialog.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_filechooser_dialog
#   Creates a new GtkFileChooserDialog widget.
#
#   GtkFileChooserDialog is a dialog box suitable for use with "File/Open" or "File/Save as" commands.
#
#   Internal Name Type:
#   FileChooserDialog
#   
#   Parameters:
#   Name            => <name>                                           - Name of the dialog. Must be unique.
#   Action          => <open_mode>                                      - Sets the mode which confirmation dialog should appear. 
#                                                                         The open modes are: 'open', 'save', 'select-folder' and 'create-folder'.
#   [Title          => <title>]                                         - Optional. Title of the dialog (displayed in the dialog titlebar).
#   [File           => <file_name>]                                     - Optional. Sets the default file name for 'open' or 'save' action.
#   [Filter         => <pattern|mimetype> | [<name>, <pattern|mimetype>]]      - Optional. Sets the current file filter for 'open' action.
#   [Folder         => <directory>]                                     - Optional. Sets a directory for 'select-folder' action or if no file path 
#                                                                         in <show_filechooser_dialog> is set for 'open' or 'save' action.
#   [RFunc          => <response_function>]                             - Optional. If not set <show_filechooser_dialog> will return the response.
#
#   Returns:
#   The chosen path/folder or 0.
#
#   Example:
#   (start code)
#   sub response {
#       my $resp = shift;
#       print "response: " . $resp . "\n"; 
#   }
#   
#   my $win = SimpleGtk2->new_window(Name => 'mainWindow', 
#                           Title   => 'File Chooser dialog', 
#                           Size    => [200, 100]);
#   
#   $win->add_button( Name => 'tryButton', 
#           Pos     => [20, 15], 
#           Size    => [80, 25], 
#           Title   => "Try");
#   $win->add_signal_handler('tryButton', 'clicked', sub{$win->show_filechooser_dialog('fchooserdiag');});
#   
#   $win->add_filechooser_dialog(Name => 'fchooserdiag',
#           Title   => 'Open a file',
#           Action  => 'open',
#           RFunc   => \&response);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/FileChooserDialog.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkFileChooserDialog.html>
#
#   Available Support Functions:
#   response = <show_filechooser_dialog> (<name>, <filename|file|folder>)
#
#   string = <get_value> (<name>, )
#
#   <set_value> ()
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
# ---------------------------------------------------------------------
sub add_filechooser_dialog #(Name => <name>, Action => <open_mode>, [Title => <title>], [FName => <file_name>], [Filter => <pattern|mimetype> | [<name>, <pattern|mimetype>]], [Folder => <directory>], [RFunc => <response_function>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'FileChooserDialog';

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # filechooser dialog specific fields
    $object->{action} = $params{'action'} || undef;
    $object->{file} = $params{'filename'} || undef;
    $object->{folder} = $params{'folder'} || $ENV{'HOME'};

    my @filter = (undef, undef);
    if (defined($params{'filter'})) {
        if (ref($params{'filter'}) eq 'ARRAY') {
            @filter = $params{'filter'};
        } else {
            $filter[1] = $params{'filter'};
        }
    }
    $object->{filter} = @filter;

    $object->{rfunc} = $params{'responsefunction'} || undef;
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # prepare the 'ok' button depending on the current action
    my $stock_item;
    if ($object->{action} eq 'open') {
        $stock_item = 'gtk-open';
    }
    elsif ($object->{action} eq 'save') {
        $stock_item = 'gtk-save';
    }
    else {
        $stock_item = 'gtk-ok';
    }

    # create filechooser dialog
    my $filechooser_dialog;
    if (defined($object->{action})) {
        $filechooser_dialog = Gtk2::FileChooserDialog->new(
                                    _($object->{title}), 
                                    undef, 
                                    $object->{action}, 
                                    'gtk-cancel' => 'cancel', 
                                    $stock_item => 'ok');
    } else {
        $self->internal_die($object, "No action defined! Exiting.");
    }

    # add widget reference to widget object
    $object->{ref} = $filechooser_dialog;
}


# ---------------------------------------------------------------------
#   Function: show_filechooser_dialog
#   Shows a simple or normal filechooser dialog.
#
#   The normal filechooser dialog needs a filechooser dialog object created with <add_filechooser_dialog>.
#
#   The simple filechooser dialog doesn't need this object.
#
#   Parameters for normal:
#   <name>                      - Name of the filechooser dialog. Must be unique.
#   <filename|file|folder>      - The filename or file path or folder.
#
#   Parameters for simple:
#   <action_type>                                       - The mode which confirmation dialog should appear. 
#                                                         Could be: 'open', 'save', 'select-folder' and 'create-folder'.
#   <filename|file|folder>                              - The filename for 'open' or 'save' action, 
#   <pattern|mimetype> | [<name>, <pattern|mimetype>]   - The used file filter for 'open' action.
#
#   Returns:
#   The chosen path/folder or 0.
#
#   Examples:
#   (start code)
#   # A simple filechooser dialog
#
#   sub response {
#       my $win = shift;
#       my $resp = $win->show_filechooser_dialog('create-folder');
#       print "response: " . $resp . "\n"; 
#   }
#   
#   $win->add_button( Name => 'tryButton', 
#           Pos     => [70, 45], 
#           Size    => [80, 25], 
#           Tip     => "Shows a simple filechooser dialog.",
#           Title   => "Simple");
#   $win->add_signal_handler('tryButton', 'clicked', sub{&response($win);});
#   --------------------------------------
#   # A normal filechooser dialog
#
#   sub response {
#       my $resp = shift;
#       print "response: " . $resp . "\n"; 
#   }
#   
#   $win->add_button( Name => 'tryButton', 
#           Pos     => [70, 15], 
#           Size    => [80, 25],
#           Tip     => "Shows a normal filechooser dialog.",
#           Title   => "Normal");
#   $win->add_signal_handler('tryButton', 'clicked', sub{$win->show_filechooser_dialog('fchooserdiag');});
#   
#   $win->add_filechooser_dialog(Name => 'fchooserdiag',
#           Title   => 'Open a file',
#           Action  => 'open',
#           RFunc => \&response);
#   (end code)
# ---------------------------------------------------------------------
sub show_filechooser_dialog #(<name>, <filename|file|folder>), or (<action_type>, <filename|file|folder>, <pattern|mimetype>, or [<name>, <pattern|mimetype>])
{
    my $self = shift;
    my ($name, $file_folder, $_filter) = @_;
    
    my $object = undef;
    my $action;
    my $title = undef;
    my $filechooser_dialog;
    my $defaultdir = $ENV{'HOME'};
    my $defaultfname = undef;
    my @filter = (undef, undef);
    my $rfunc = undef;
    
    # is it an existing or simple filechooser dialog?
    if (exists($self->{objects}->{$name})) {
        # get object
        $object = $self->get_object($name);
        
        # fullfill the needed variables
        $action = $object->{action};
        $title = _($object->{title});
        $filechooser_dialog = $object->{ref};
        $defaultdir = $object->{folder};
        $defaultfname = $object->{filename};
        @filter = $object->{filter};
        $rfunc = $object->{rfunc};
        
    } else {
        $action = $name;
        
        # prepare the 'ok' button depending on the current action
        my $stock_item;
        if ($action eq 'open') {
            $stock_item = 'gtk-open';
            $title = _("Open File");
        }
        elsif ($action eq 'save') {
            $stock_item = 'gtk-save';
            $title = _("Save File");
        }
        else {
            $stock_item = 'gtk-ok';
            if ($action eq 'select-folder') {
                $title = _("Select Folder");
            } else {
                $title = _("Create Folder");
            }
        }

        # prepare filter array if defined
        if (defined($_filter)) {
            if (ref($_filter) eq 'ARRAY') {
                @filter = @$_filter;
            } else {
                $filter[1] = $_filter;
            }
        }
        
        # initialize the simple filechooser dialog
        $filechooser_dialog =  Gtk2::FileChooserDialog->new( 
                                    $title,
                                    undef,
                                    $action,
                                    'gtk-cancel' => 'cancel',
                                    $stock_item => 'ok');
    }

    # set filter
    if (defined($filter[1])) {
        my $file_filter = Gtk2::FileFilter->new();
        # filter type name
        if (defined($filter[0])) {
            $file_filter->set_name($filter[0]);
        }
        # mimetype or pattern
        if ($filter[1] =~ /\//) {
            $file_filter->add_mime_type($filter[1]);
        } else {
            $file_filter->add_pattern($filter[1]);
        }
        # add filter to button
        if (defined($filter[0])) {
            $filechooser_dialog->add_filter($file_filter);
        } else {
            $filechooser_dialog->set_filter($file_filter);
        }
    }

    # depending on the action the second parameter will be interpreted
    # but first set the defaults
    (defined $defaultfname) && $filechooser_dialog->set_current_name($defaultfname);
    $filechooser_dialog->set_current_folder($defaultdir);

    if ($action eq 'open') {
        if (defined $file_folder){
            # a file ?
            if (-f $file_folder) {
                $filechooser_dialog->set_filename($file_folder);
            }
            # a folder ?
            elsif (-d $file_folder) {
                $filechooser_dialog->set_current_folder($file_folder);
            }
        }
    }
    elsif ($action eq 'save') {
        if (defined $file_folder){
            # a folder ?
            if (-f $file_folder) {
                $filechooser_dialog->set_current_folder($file_folder);
            }
            else {
                $filechooser_dialog->set_filename($file_folder);
            }
        }
        # Ask whether a file exists should be overwritten
        $filechooser_dialog->set_do_overwrite_confirmation(1);
    }
    else {
        if (defined $file_folder){
            $filechooser_dialog->set_current_folder($file_folder);
        }
    }

    # return value (simple dialog) or response function (custom dialog)
    unless (defined $rfunc) {
        my $response = $filechooser_dialog->run();
        if ($response eq 'ok') {
            $response = $filechooser_dialog->get_filename();
        } else {
            $response = 0;
        }
        $filechooser_dialog->destroy();
        return $response;
    } else {
        # react whenever the user responds.
        $filechooser_dialog->signal_connect(response => sub {
            my ($self, $response, $object) = @_;
            if ($response eq 'ok') {
                $response = $filechooser_dialog->get_filename();
            } else {
                $response = 0;
            }
            $self->destroy();
            $object->{rfunc}->($response);
        }, $object);
        $filechooser_dialog->show_all();
    }
}


# *********************************************************************
#   Widget: GtkFontButton
#   A button to launch a font selection dialog.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_font_button
#   Creates a new GtkFontButton widget.
#
#   The GtkFontButton is a button which displays the currently selected font an allows to open a font selection dialog to change the font.
#
#   Internal Name Type:
#   FontButton
#   
#   Parameters:
#   Name            => <name>                   - Name of the button. Must be unique.
#   Pos|Position    => [pos_x, pos_y]           - Position of the button.
#   Title           => <title>                  - Title of the button (displayed in the button).
#   [Frame          => <frame_name>]            - Optional. Optional. Name of the frame if the button is located in one. Must be unique. See <add_frame>.
#   [Font           => [family, size, weight]]  - Optional. Sets the initial font. Font family and size are required if set.
#   [Size           => [width, height]]         - Optional. Width and height of the button. Default is 80x25.
#   [Tip|Tooltip    => <tooltip_text>]          - Optional. Text of the tooltip shown while hovering over the button.
#   [Func|Function  => <function_click>]        - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                           *Note:* If data is used it have to be set as an array.
#   [Sig|Signal     => <signal>]                - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                           Can be 'activate', 'clicked', 'enter', 'leave' or 'pressed'.
#   [Sens|Sensitive => <sensitive>]             - Optional. Sets the button active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $window->add_font_button(Name => 'font_button', 
#               Pos     => [20, 40], 
#               Font    => ["Arial", 12]);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/FontButton.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkFontButton.html>
#
#   Available Support Functions:
#   string = <get_value> (<name>, "Uri")
#
#   <set_value> (<name>, Uri => <uri-text>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   (width, height) = <get_size> (<name>)
#
#   <set_size> (<name>, <new_width>, <new_height>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_font_button #(Name => <name>, Position => [pos_x, pos_y], Title => <title>, Action => <open_mode>, [Frame => <frame_name>], [Font => [family, size, weight]], [Size => [width, height]], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'FontButton';
    
    # font button specific fields
    $object->{font} =  undef;

    # create font button
    my $font_button;
    if (defined $params{'font'}) {
        $object->{font} = scalar(@{$params{'font'}}) == 2 ? join(" ", @{$params{'font'}}) : "$params{'font'}[0] $params{'font'}[2] $params{'font'}[1]";
        $font_button = Gtk2::FontButton->new($object->{font});
    } else {
        $font_button = Gtk2::FontButton->new();
    }
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # set title
    if (defined($object->{title})) {
        $font_button->set_title(_($object->{title}));
    }
    
    # add widget reference to widget object
    $object->{ref} = $font_button;
    
    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the button
    $self->_add_to_container($object->{name});

    $font_button->show();
}


# *********************************************************************
#   Widget: GtkFontSelectionDialog
#   A dialog box for selecting fonts.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_fontselection_dialog
#   Creates a new GtkFontSelectionDialog widget.
#
#   The GtkFontSelectionDialog widget is a dialog box for selecting a font.
#
#   Internal Name Type:
#   FontSelectionDialog
#   
#   Parameters:
#   Name        => <name>                       - Name of the dialog. Must be unique.
#   Title       => <title>                      - Title of the dialog (displayed in the dialog titlebar).
#   [Font       => [family, size, weight]]      - Optional. Sets the initial font. Font family and size are required if set.
#   [Preview    => <preview text>]              - Optional. Sets the previewed text.
#   [RFunc      => <response_function>]         - Optional. If not set <show_font_dialog> will return the response.
#
#   Returns:
#   The font string: "fontname weight size" or 0.
#
#   Example:
#   (start code)
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/FontSelectionDialog.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkFontSelectionDialog.html>
#
#   Available Support Functions:
#   response = <show_font_dialog> (<name>)
#
#   string = <get_value> (<name>, "previewstring" *or* "fontstring" *or* "fontfamily" *or* "fontsize" *or* "fontweight")
#
#   <set_value> (<name>, previewstring => <preview_text> *or* fontstring => <font_string> *or* fontfamily => <font_family> *or* fontsize => <font_size> *or* fontweight => <font_weight>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
# ---------------------------------------------------------------------
sub add_fontselection_dialog #(Name => <name>, Title => <title>, [Font => [family, size, weight]], [Preview => <preview text>], [RFunc => <response_function>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'FontSelectionDialog';
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # fontselection dialog specific fields
    $object->{font} =  undef;
    if (defined $params{'font'}) {
        $object->{font} = scalar(@{$params{'font'}}) == 2 ? join(" ", @{$params{'font'}}) : "$params{'font'}[0] $params{'font'}[2] $params{'font'}[1]";
    }
    $object->{preview} =  $params{'preview'} || undef;
    $object->{rfunc} = $params{'responsefunction'} || undef;

    # create fontselection dialog
    my $fontselection_dialog;
    if (defined($object->{title})) {
        $fontselection_dialog = Gtk2::FontSelectionDialog->new(_($object->{title}));
    } else {
        $self->internal_die($object, "No title defined! Exiting.");
    }
    
    # set another preview text if defined
    if (defined $object->{preview}) {
        $fontselection_dialog->set_preview_text($object->{preview});
    }

    # add widget reference to widget object
    $object->{ref} = $fontselection_dialog;
}


# ---------------------------------------------------------------------
#   Function: show_fontselection_dialog
#   Shows simple or normal fontselection dialog.
#
#   The normal fontselection dialog needs a fontselection dialog object created with <add_fontselection_dialog>.
#
#   The simple fontselection dialog doesn't need this object.
#
#   Parameters for normal:
#   <name>      - Name of the fontselection dialog. Must be unique.
#
#   Parameters for simple:
#   <family>    - The initial font family. 
#   <size>      - The initial font size. 
#   <weight>    - The initial font weight.
#
#   Returns:
#   The font string: "fontname weight size" or 0.
#
#   Examples:
#   (start code)
#   # A simple fontselection dialog
#   --------------------------------------
#   # A normal fontselection dialog
#   (end code)
# ---------------------------------------------------------------------
sub show_fontselection_dialog #(<name>) or (<family>, <size>, <weight>)
{
    my $self = shift;
    my ($name, $size, $weight) = @_;
    
    my $object = undef;
    my $title = "Select a Font";
    my $fontselection_dialog;
    my $rfunc = undef;
    
    # is it an existing or simple fontselection dialog?
    if (exists($self->{objects}->{$name})) {
        # get object
        $object = $self->get_object($name);
        $fontselection_dialog = $object->{ref};
        # set font
        (defined $object->{font}) && $fontselection_dialog->set_font_name($object->{font});
        # set preview text
        (defined $object->{preview}) && $fontselection_dialog->set_preview_text($object->{preview});
    } else {
        # initialize the simple fontselection dialog
        $fontselection_dialog = Gtk2::FontSelectionDialog->new($title);
    }

    # return value (simple dialog) or response function (custom dialog)
    unless (defined $rfunc) {
        my $response = $fontselection_dialog->run();
        if ($response eq 'ok') {
            $response = $fontselection_dialog->get_font_name();
        } else {
            $response = 0;
        }
        $fontselection_dialog->destroy();
        return $response;
    } else {
        # react whenever the user responds.
        $fontselection_dialog->signal_connect(response => sub {
            my ($self, $response, $object) = @_;
            if ($response eq 'ok') {
                $response = $fontselection_dialog->get_font_name();
            } else {
                $response = 0;
            }
            $self->destroy();
            $object->{rfunc}->($response);
        }, $object);
        $fontselection_dialog->show_all();
    }
    
}


######################################################################
#   Group: Layout Containers
######################################################################

# *********************************************************************
#   Widget: GtkNotebook
#   A tabbed notebook container.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_notebook
#   Creates a new GtkNotebook widget.
#
#   The GtkNotebook widget is a GtkContainer whose children are pages that 
#   can be switched between using tab labels along one edge.
#
#   There are many configuration options for GtkNotebook. Among other things, 
#   you can choose on which edge the tabs appear (whether, if there are too many 
#   tabs to fit the notebook should be made bigger or scrolling arrows added, 
#   and whether there will be a popup menu allowing the users to switch pages.
#
#   Internal Name Type:
#   Notebook
#
#   Parameters:
#   Name                => <name>               - Name of the notebook. Must be unique.
#   Pos|Position        => [pos_x, pos_y]       - Position of the notebook.
#   Size                => [width, height]      - Width and height of the notebook.
#   [Tabs               => <position>]          - Optional. Sets the edge at which the tabs for switching pages in the notebook are drawn.
#                                                 Default: top (left, right, bottom, none).
#   [Scroll|Scrollable  => <0/1>]               - Optional. Sets whether the tab label area will have arrows for scrolling if there are too many tabs to fit in the area.
#                                                 Default: 1.
#   [Popup              => <0/1>]               - Optional. Enables (1) the popup menu: if the user clicks with the right mouse button on the tab labels, a menu with all the pages will be popped up.
#   [Frame          => <frame_name>]            - Optional. Name of the frame if the notebook is located in one. Must be unique. See <add_frame>.
#   [Sens|Sensitive => <sensitive>]             - Optional. Sets the notebook active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_notebook(Name => 'NB1', 
#           Pos     => [10, 10], 
#           Size    => [200, 200], 
#           Tabs    => 'top', 
#           Popup   => 1);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Notebook.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkNotebook.html>
#
#   Available Support Functions:
#   <add_nb_page> (Name => <name>, Notebook => <notebook_name>, [Font => [family, size, weight]], [Color => [<color>, <state>]], [Pos_n|PositionNumber => <number>], [Tip|Tooltip => <tooltip_text>], [Sens|Sensitive => <sensitive>])
#
#   <remove_nb_page> (<nb_name>, <title|number>)
#
#   string = <get_value> (<name>, "Current|CurrentPage" *or* "Pages" *or* "Popup" *or* "No2Name|Number2Name" *or* "Scroll|Scrollable" *or* "Tabs")
#
#   <set_value> (<name>, Current|CurrentPage => <page_number|next|prev> *or* Popup => <0/1> *or* Scroll|Scrollable => <0/1> *or* Tabs => <edges>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   (width, height) = <get_size> (<name>)
#
#   <set_size> (<name>, <new_width>, <new_height>)
# ---------------------------------------------------------------------
sub add_notebook #(Name => <name> , Pos|Position => [pos_x, pos_y], Size => [width, height], [Tabs => <position>], [Scroll|Scrollable => <0/1>], [Popup => <0/1>], [Frame => <frame_name>], [Sens|Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Notebook';

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # notebook specific fields
    my $scrollable = defined($params{'scrollable'}) ? $params{'scrollable'} : 1;
    $object->{popup} = $params{'popup'} || 0;
    my $tabs = $params{'tabs'} || 'top';

    # create notebook
    my $notebook = Gtk2::Notebook->new();
    
    # scrollable?
    $notebook->set_scrollable($scrollable); 
    
    # popup available?
    if ($object->{popup}) {
        $notebook->popup_enable();
    } else {
        $notebook->popup_disable();
    }
    
    # set the tabs position or no tabs
    unless ($tabs eq 'none') {
        $notebook->set_show_tabs(1);
        $notebook->set_tab_pos($tabs);
    } else {
        $notebook->set_show_tabs(0);
    }
    
    # add notebook to window objects list
    $object->{ref} = $notebook;

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the notebook
    $self->_add_to_container($object->{name});

    $notebook->show();
}


# *********************************************************************
#   Widget: GtkNotebookPage
#   A notebook page.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_nb_page
#   Creates a new GtkNotebook page.
#
#   Appends a new page to a notebook. The index starting from 0.
#
#   Internal Name Type:
#   NotebookPage
#
#   Parameters:
#   Name                    => <name>                   - Name of the notebook page. Must be unique.
#   Title                   => <title>                  - Title of the notebook page (displayed in the tab).
#   Notebook                => <notebook_name>          - Name of the notebook where the page shall appear. Must be unique.
#   [Font                   => [family, size, weight]]  - Optional. Sets a title font. To use the defaults set values with undef.
#   [Color                  => [<color>, <state>]]      - Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                         State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (see Gtk2::State).
#   [Pos_n|PositionNumber   => <number>]                - Optional. Insert a page into the notebook at the given position.
#   [Tip|Tooltip            => <tooltip_text>]          - Optional. Text of the tooltip shown while hovering over the page.
#   [Sens|Sensitive         => <sensitive>]             - Optional. Sets the notebook page active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_nb_page(Name => "NB_page1", 
#           Pos_n   => 0, 
#           Title   => "Page 1", 
#           Notebook => 'NB1', 
#           Tip     => "This is the first page");
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Notebook.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkNotebook.html>
#
#   Available Support Functions:
#   string = <get_value> (<name>, "PageNumber" *or* "Notebook")
#
#   <set_value> (<name>, Reorder => <0/1>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_nb_page #(Name => <name>, Notebook => <notebook_name>, [Font => [family, size, weight]], [Color => [<color>, <state>]], [Pos_n|PositionNumber => <number>], [Tip|Tooltip => <tooltip_text>], [Sens|Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'NotebookPage';

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # notebook page specific fields
    $object->{notebook} = $params{'notebook'};
    my $pos_n = defined($params{'positionnumber'}) ? $params{'positionnumber'} : undef;
    my $font = $params{'font'} || undef;
    my $color = $params{'color'}[0] || undef;
    my $cstate = $params{'color'}[1] || undef;

    # Create a fixed container
    my $fixed = new Gtk2::Fixed();
    
    # add it to the containers hash
    $self->{containers}->{$object->{name}} = $fixed;
    
    # create a viewport for the fixed container
    my $viewport = Gtk2::Viewport->new(undef, undef);
    # change its shadow to 'none' because default is 'in' which looks odd
    $viewport->set_shadow_type('none');
    # for later manipulation add the viewport to the page object
    $object->{viewport} = $viewport;

    # create a scrolled window to display scrollbars
    # if the widgets needs more place as the notebook provides
    my $scrolled_window = Gtk2::ScrolledWindow->new(undef, undef);
    $scrolled_window->set_policy ('automatic', 'automatic');
    
    # add fixed container to the viewport
    $viewport->add($fixed);
    # add the viewport to the scrolled window
    $scrolled_window->add($viewport);

    # add scrolled window as page reference to widget object
    $object->{ref} = $scrolled_window;
    
    # show all three
    $scrolled_window->show();
    $viewport->show();
    $fixed->show();

    # create label for notebook tab because the default label
    # in the page isn't available at creation date and thus
    # tooltip can't bind to that
    my $label = Gtk2::Label->new(_($object->{title}));

    # add label widget of the page to object if avaliable
    $object->{pagelabel} = $label;

    # add page to notebook
    my $notebook = $self->_get_ref($object->{notebook});
    
    if (defined($pos_n)) {
        $notebook->insert_page($object->{ref}, undef, $pos_n);
    } else {
        $notebook->append_page($object->{ref});
    }

    # set tab and menu label
    $notebook->set_tab_label($object->{ref}, $object->{pagelabel});

    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);

    # set font color if defined
    $self->set_font_color($object->{name}, $color, $cstate) if defined($color);

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
}


# ---------------------------------------------------------------------
#   Function: remove_nb_page
#   Removes a notebook page from a notebook.
#
#   Parameters:
#   <nb_name>           - Name of the notebook. Must be unique.
#   <title|number>      - Title or number (0 indexed) of the notebook page.
#
#   Returns:
#   None.
# ---------------------------------------------------------------------
sub remove_nb_page #(<nb_name>, <title|number>)
{
    my $self = shift;
    my ($name, $number) = @_;
    my $nb_object;
    my $page_object;
    my $page_number;
    
    # number is given
    if (defined($number)) {
        $page_number = $number;
        # get notebook object
        $nb_object = $self->get_object($name);
        # get page object for deletion
        my $page_widget = $nb_object->{ref}->get_nth_page($page_number);
        $page_object = $self->get_object($page_widget);
    } else {
        # get page object
        $page_object = $self->get_object($name);
        # set notebook object
        $nb_object = $self->get_object($page_object->{notebook});
        # get number
        $page_number = $nb_object->{ref}->page_num($page_object->{ref});
    }

    # error handling
    if ($page_number == -1) {
        $self->show_error($nb_object, "No notebook page with number \"$number\" found.");
        return 0;
    }

    # remove nb page from objects hash
    delete $self->{objects}{$page_object->{name}};

    # delete page in notebook
    $nb_object->{ref}->remove_page($page_number);

    # update popup if activated
    if ($nb_object->{popup}) {
        $nb_object->{ref}->popup_disable();
        $nb_object->{ref}->popup_enable();
    }
    return 1;
}


######################################################################
#   Group: Ornaments
######################################################################

# *********************************************************************
#   Widget: GtkFrame
#   A bin with a decorative frame and optional label.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_frame
#   Creates a new GtkFrame widget.
#
#   The frame widget is a Bin that surrounds its child with a decorative frame and an optional label. If present, the label is drawn in a gap in the top side of the frame.
#
#   Internal Name Type:
#   Frame
#   
#   Parameters:
#   Name            => <name>                                           - Name of the frame. Must be unique.
#   Size            => [width, height]                                  - Width and height of the frame.
#   Pos|Position    => [pos_x, pos_y]                                   - Position of the frame.
#                                                                         *Note:* Inside a frame the positioning of a widget starts at the frame and not at the window edges.
#   [Title          => <title>]                                         - Optional. Title of the frame.
#   [Frame          => <frame_name>]                                    - Optional. Name of the frame if the frame is located in one. Must be unique. See <add_frame>.
#   [Font           => [family, size, weight]]                          - Optional. Sets the initial font. Font family and size are required if set.
#   [Tip|Tooltip    => <tooltip_text>]                                  - Optional. Text of the tooltip shown while hovering over the frame.
#   [Sens|Sensitive => <sensitive>]                                     - Optional. Sets the frame active/inactive. Default: 1 (active).
#                                                                                   *Note:* All widgets inside the frame will be deactivated if frame is set to inactive.
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_frame(Name => 'frame1', 
#                   Pos => [5, 5], 
#                   Size => [390, 190], 
#                   Title => ' A Frame around ');
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/Frame.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkFrame.html>
#
#   Available Support Functions:
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   string = <get_title> (<name>)
#
#   <set_title> (<name>, <text>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_frame #(Name => <name>, Position => [pos_x, pos_y], [Title => <title>], [Frame => <frame_name>], [Font => [family, size, weight]], [Tooltip => <tooltip_text>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Frame';
    my $font = $params{'font'} || undef;
    my $color = $params{'color'}[0] || undef;
    my $cstate = $params{'color'}[1] || undef;
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # create frame
    my $frame;
    if ($object->{title}) {
        $frame = Gtk2::Frame->new(_($object->{title}));
    } else {
        $frame = Gtk2::Frame->new();        
    }
    
    # add widget reference to widget object
    $object->{ref} = $frame;
    
    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);

    # set font color if defined
    $self->set_font_color($object->{name}, $color, $cstate) if defined($color);

    # Create the fixed container
    my $fixed = new Gtk2::Fixed();
    $self->{containers}->{$object->{name}} = $fixed;
    $frame->add($fixed);
    $fixed->show();
    
    # set positon of the frame
    unless (defined($object->{container})) {
        $self->{container}->put($frame, $object->{pos_x}, $object->{pos_y});
    } else {
        $self->_add_to_container($object->{name});
    }
    
    $frame->show();
}


# *********************************************************************
#   Widget: GtkSeparator
#   A horizontal or vertical separator.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_separator
#   Creates a new GtkSeparator widget.
#
#   The GtkSeparator (GtkHSeparator/GtkVSeparator) widget is a horizontal or vertical separator, used to group the widgets within a window. 
#   It displays a horizontal/vertical line with a shadow to make it appear sunken into the interface.
#
#   *Note:* The GtkSeparator widget is not used as a separator within menus. To create a separator in a menu create an empty GtkSeparatorMenuItem in <add_menu_item>.
#
#   Internal Name Type:
#   Separator
#   
#   Parameters:
#   Name                => <name>                   - Name of the separator. Must be unique.
#   Orient|Orientation  => <orientation>            - Orientation of the separator (horizontal, vertical).
#   Pos|Position        => [pos_x, pos_y]           - Position of the separator.
#   [Size               => [width, height]]         - Optional. Width and height of the separator.
#   [Frame              => <frame_name>]            - Optional. Name of the frame if the separator is located in one. Must be unique. See <add_frame>.
#   [Sens|Sensitive     => <sensitive>]             - Optional. Sets the separator active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   (end code)
#
#   References:
#   <Gtk2-Perl GtkHSeparator at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/HSeparator.pod.html>, 
#   <Gtk2-Perl GtkVSeparator at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/VSeparator.pod.html>, 
#   <Gtk2 GtkHSeparator at https://developer.gnome.org/gtk2/stable//GtkHSeparator.html>
#   <Gtk2 GtkVSeparator at https://developer.gnome.org/gtk2/stable//GtkVSeparator.html>
#
#   Available Support Functions:
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
# ---------------------------------------------------------------------
sub add_separator #(Name => <name>, Orient|Orientation => <orientation>, Pos|Position => [pos_x, pos_y], [Size => [width, height]], [Frame => <frame_name>], [Sens|Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Separator';
    
    # separator specific fields
    $object->{orientation} = $params{'orientation'} || undef;

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;
    
    # create V or HBox and separator depending on the orientation
    my $box;
    my $separator;
    if ($object->{orientation} eq 'horizontal') {
        $box = Gtk2::HBox->new(1,0);
        $separator = Gtk2::HSeparator->new();
    }
    elsif ($object->{orientation} eq 'vertical') {
        $box = Gtk2::VBox->new(1,0);
        $separator = Gtk2::VSeparator->new();
    } else {
        $self->internal_die($object, "Wrong orientation '" . $object->{orientation} . "' defined!");
    }
    
    # for later manipulation we put the separator reference to the object
    $object->{separator} = $separator;

    # add separator to the box
    $box->pack_start($separator, 1, 1, 5);

    # add box object as the separator object to window objects hash
    $object->{ref} = $box;
    
    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the separator
    $self->_add_to_container($object->{name});

    $separator->show();
    $box->show();
}


######################################################################
#   Group: Scrolling
######################################################################

# *********************************************************************
#   Widget: GtkScrollBar
#   A horizontal or vertical scrollbar.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_scrollbar
#   Creates a new GtkScrollBar widget.
#
#   The GtkScrollBar widget is a widget arranged horizontally or vertically creating a scrollbar.
#
#   Internal Name Type:
#   Scrollbar
#   
#   Parameters:
#   Name                => <name>                   - Name of the slider. Must be unique.
#   Pos|Position        => [pos_x, pos_y]           - Position of the scrollbar.
#   Orient|Orientation  => <orientation>            - The orientation of the scrollbar (horizontal, vertical).
#   [Size               => [width, height]]         - Optional. Width and height of the scrollbar.
#   [Start              => <start_value>]           - Optional. The initial start value. Default: 0.0 (double).
#   Min                 => <min_value>              - The minimum allowed value (double).
#   Max                 => <max_value>              - The maximum allowed value (double).
#   Step                => <step_in/decrease>       - The step increment (double).
#   [Digits             => <used_digits>]           - Optional. Number of decimal places the value will be displayed. Default: 0 (1 digit).
#   [Frame              => <frame_name>]            - Optional. Name of the frame if the scrollbar is located in one. Must be unique. See <add_frame>.
#   [Tip|Tooltip        => <tooltip_text>]          - Optional. Text of the tooltip shown while hovering over the scrollbar.
#   [Func|Function      => <function_click>]        - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                               *Note:* If data is used it have to be set as an array.
#   [Sig|Signal         => <signal>]                - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                               Most used signal is 'value-changed'. For more see References below.
#   [Sens|Sensitive     => <sensitive>]             - Optional. Sets the scrollbar active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Examples:
#   (start code)
#   # Horizontal
#   $win->add_scrollbar(Name => 'hscroll', 
#           Pos     => [10, 220], 
#           Size    => [200, -1], 
#           Orient  => 'horizontal', 
#           Start   => 5, 
#           Min     => 0, 
#           Max     => 100, 
#           Step    => 1, 
#           Digits  => 1, 
#           Tip     => 'From left to right', 
#           Frame   => 'frame2');
#
#   # Vertical
#   $win->add_scrollbar(Name => 'vscroll', 
#           Pos     => [320, 30], 
#           Size    => [-1, 150], 
#           Orient  => 'vertical', 
#           Start   => 1.5, 
#           Min     => 0, 
#           Max     => 100, 
#           Step    => 1, 
#           Digits  => 1, 
#           Tip     => 'Up and down', 
#           Frame   => 'frame1');
#   (end code)
#
#   References:
#   <Gtk2-Perl HScrollbar at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/HScrollbar.pod.html>, 
#   <Gtk2-Perl VScrollbar at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/VScrollbar.pod.html>, 
#   <Gtk2 HScrollbar at https://developer.gnome.org/gtk2/stable//GtkHScrollbar.html>, 
#   <Gtk2 VScrollbar at https://developer.gnome.org/gtk2/stable//GtkVScrollbar.html>
#
#   Available Support Functions:
#   string = <get_value> (<name>, "Active" *or* "Min|Minimum" *or* "Max|Maximum" *or* "Step" *or* "Digits")
#
#   <set_value> (<name>, Start => <start_value> *or* Active => <active_value> *or* Min => <min_value> *or* Max => <max_value> *or* Step => <step_in/decrease> *or* Digits => <used_digits>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
#
#   string = <get_tooltip> (<name>)
#
#   <set_tooltip> (<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub add_scrollbar #(Name => <name>, Position => [pos_x, pos_y], Orientation => <orientation>, [Size => [width, height]], [Start => <start_value>], Minimum => <min_value>, Maximum => <max_value>, Step => <step_value>, [Digits => <used_digits>], [Frame => <frame_name>], [Tooltip => <tooltip_text>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Scrollbar';

    $self->_create_range_widget($object, %params);
}


# ---------------------------------------------------------------------
# common function for sliders and scrollbars
# TODO: the scrollbar hasn't a draw value. Perhaps adding a label with the
# value via signal_emit('value_changed')
# Problem: where do we get the position of the thumb? We have the length
# of the scrollbar but not from the arrows. We have the min, max, steps and
# the digits. So, if we get the length of the arrow we could calculate the
# pixels ...
# ---------------------------------------------------------------------
sub _create_range_widget($@) {
    my $self = shift;
    my ($object, %params) = @_;
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # slider specific fields
    my $orient = $params{'orientation'} || undef;
    my $start = $params{'start'} || 0;
    my $min = $params{'minimum'} || 0;
    my $max = $params{'maximum'} || 0;
    my $step = $params{'step'} || 0;
    my $draw_value = defined($params{'drawvalue'}) ? $params{'drawvalue'} : 1;
    my $value_pos = $params{'valueposition'} || 'top';
    my $digits = $params{'digits'} || 0;

    # first create an adjustment widget to hold information about the range of 
    # values that the slider can take
    my $adjustment = Gtk2::Adjustment->new( $start,
                                            $min,
                                            $max,
                                            $step,
                                            0.0,
                                            0.0);
    
    # add to object for later manipulation
    $object->{adjustment} = $adjustment;
    
    # now the range widget follows
    my $range_widget;
    if ($object->{type} eq 'Slider'){
        if ($orient eq 'horizontal') {
            $range_widget = Gtk2::HScale->new($adjustment);
        } else {
            $range_widget = Gtk2::VScale->new($adjustment);
        }
    }
    elsif ($object->{type} eq 'Scrollbar'){
        if ($orient eq 'horizontal') {
            $range_widget = Gtk2::HScrollbar->new($adjustment);
        } else {
            $range_widget = Gtk2::VScrollbar->new($adjustment);
        }
    }
    
    # add widget reference to widget object
    $object->{ref} = $range_widget;
    
    # should the current slider value shown and where
    if ($object->{type} eq 'Slider') {
        $range_widget->set_draw_value($draw_value);
        # set the position of the value
        $range_widget->set_value_pos($value_pos);
        # set the digits
        $range_widget->set_digits($digits);
    }

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    # position the slider
    $self->_add_to_container($object->{name});
    $range_widget->show();
}


######################################################################
#   Group: Miscellaneous
######################################################################

# *********************************************************************
#   Widget: GtkDrawingArea
#   A widget for custom user interface elements.
# *********************************************************************

# ---------------------------------------------------------------------
#   Function: add_drawing_area
#   Creates a new GtkImage widget.
#
#   The GtkDrawingArea widget is used for creating custom user interface elements. It's essentially a blank widget. 
#   After creating a drawing area, the application may want to connect to:
#   * Mouse and button press signals to respond to input from the user. Use <add_signal_handler> for that.
#   * The "realize" signal to take any necessary actions when the widget is instantiated on a particular display. (Create GDK resources in response to this signal.)
#   * The "configure_event" signal to take any necessary actions when the widget changes size.
#   * The "expose_event" signal to handle redrawing the contents of the widget.
#
#   Internal Name Type:
#   DrawingArea
#   
#   Parameters:
#   Name                => <name>                           - Name of the drawing area. Must be unique.
#   Pos|Position        => [pos_x, pos_y]                   - Position of the drawing area.
#   Size                => [width, height]                  - Width and height of the drawing area.
#                                                             *Note:* Gtk2 pixmaps have a current limit of short unsigned INT, highest pixels is 32767-1 (8bit int max).
#   [Frame              => <frame_name>]                    - Optional. Name of the frame if the drawing area is located in one. Must be unique. See <add_frame>.
#   [Func|Function      => <function_click>]                - Optional. Function reference/sub. Can be set later with <add_signal_handler>.
#                                                                       *Note:* If data is used it have to be set as an array.
#   [Sig|Signal         => <signal>]                        - Optional. The used action signal. Only in conjunction with Func|Function.
#                                                                       Most used is 'button_press_event'.
#   [Sens|Sensitive     => <sensitive>]                     - Optional. Sets the drawing area active/inactive. Default: 1 (active).
#
#   Returns:
#   None.
#
#   Example:
#   (start code)
#   $win->add_drawing_area(Name => 'drawArea',
#           Pos     => [10, 10], 
#           Size    => [$draw_surface[0], $draw_surface[1]]);
#   $win->add_signal_handler('drawArea', 'button_press_event', \&button_press_event);
#   $win->add_signal_handler('drawArea', 'button_release_event', \&button_release_event);
#   $win->add_signal_handler('drawArea', 'motion_notify_event', \&motion_notify_event);
#   (end code)
#
#   References:
#   <Gtk2-Perl at http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/Gtk2/DrawingArea.pod.html>, 
#   <Gtk2 at https://developer.gnome.org/gtk2/stable//GtkDrawingArea.html>
#
#   Available Support Functions:
#   <initial_draw> (<drawing_area_name>, <function>, [<data>])
#
#   string = <get_value> (<name>, "" *or* "")
#
#   <set_value> (<name>,  => <new_value>)
#
#   <hide_widget> (<name>)
#
#   <show_widget> (<name>)
#
#   (width, height) = <get_size> (<name>)
#
#   <set_size> (<name>, <new_width>, <new_height>)
#
#   (x_pos, y_pos) = <get_pos> (<name>)
#
#   <set_pos> (<name>, <new_x>, <new_y>)
#
#   state = <is_sensitive> (<name>)
#
#   <set_sensitive> (<name>, <state>)
# ---------------------------------------------------------------------
sub add_drawing_area #(Name => <name>, Pos => [pos_x, pos_y], Size => [width, height], [Frame => <frame_name>], [Function => <function_click>], [Signal => <signal>], [Sensitive => <sensitive>])
{
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'DrawingArea';
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;

    # DrawingArea specific fields
    $object->{pixmap} = undef; # holds the drawing as a pixmap created in the configure_event

    # create a scrolled window to display scrollbars
    my $scrolled_window = Gtk2::ScrolledWindow->new (undef, undef);
    $scrolled_window->set_policy ('automatic', 'automatic');
    
    # size of the text widget (scrolled window)
    $scrolled_window->set_size_request($object->{width}, $object->{height});

    # Create the drawing area.
    my $drawing_area = new Gtk2::DrawingArea(); #don't confuse with Gtk2::Drawable
    #$drawing_area->set_size_request($object->{width}, $object->{height});

    # for later manipulation we put the drawing_area reference to the drawing area object
    $object->{drawing_area} = $drawing_area;

    # set possible events
    $drawing_area->set_events ([qw/exposure-mask
                                leave-notify-mask
                                button-press-mask
                                button-release-mask
                                pointer-motion-mask
                                pointer-motion-hint-mask/]);
    
    # Signals used to handle backing pixmap
    $self->add_signal_handler($object->{name}, "configure_event", \&_configure_event, $self);
    $self->add_signal_handler($object->{name}, "expose_event", \&_expose_event, $self);
    
    # add drawing_area to scrolled window
    $scrolled_window->add_with_viewport($drawing_area);
    
    # add scrolled window (parent) to window objects list
    $object->{ref} = $scrolled_window;

    # set some common functions: size and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the drawing area
    $self->_add_to_container($object->{name});

    $scrolled_window->show();
    #push(@{$self->{lates}}, $object->{name});
}


# ---------------------------------------------------------------------
#   Function: initial_draw
#   Base function to draw with the drawing area.
#
#   This base function is needed to draw in SimpleGtk2 because drawings need to initialize *before* Gtk2->main() is called.
#
#   Parameters:
#   <drawing_area_name>     - Name of the drawing area.  Must be unique.
#   <function>              - Used custom draw function.
#   [<data>]                - Optional. The data you wish to have passed to this function.
#
#   Returns:
#   None.
#
#   Example:
#>  $win->initial_draw('drawArea', sub{&draw_rect($win->get_object('drawArea'), \@{$rects{$rect}[0]},$rects{$rect}[1]);});
# ---------------------------------------------------------------------
sub initial_draw #(<drawing_area_name>, <function>, [<data>])
{
    my $self = shift;
    my ($name, $function, $data) = @_;
    
    # get object
    my $object = $self->get_object($name);
    
    # is it a drawing area
    if ($object->{type} eq 'DrawingArea') {
        # add function to subs hash
        $self->_add_subs($function, $data);
    } else {
        $self->internal_die($object, "Isn't a drawing area object type => \"$object->{type}\"!");
    }
}


# ---------------------------------------------------------------------
# get an allocated color or add one for later use
# ---------------------------------------------------------------------
sub get_color($@) {
    my $self = shift;
    my ($colormap, $name) = @_;
    my $ret;

    if ($ret = $self->{allocated_colors}->{$name}) {
        return $ret;
    }

    my $color = Gtk2::Gdk::Color->parse($name);
    $colormap->alloc_color($color,1,1);

    $self->{allocated_colors}{$name} = $color;

    return $color;
}


# *********************************************************************
#   Widget: GtkTooltip
#   Add tips to your widgets.
# *********************************************************************
# ---------------------------------------------------------------------
#   Function: add_tooltip
#   Add a tooltip to a widget.
#
#   The tooltip text should be written in double quotes to support control characters.
#   Longer text can break with '\' at the end for better overview.
#
#   Restriction:
#   Not available for the following widgets: <GtkMenu>, <GtkMenuBar>, <GtkFileChooserDialog>, <GtkFontSelectionDialog>, 
#   <GtkMessageDialog>, <GtkTreeView>, <GtkStatusbar>, <GtkTextView>, <GtkSeparator> and <GtkNotebook>.
#
#   Parameters:
#   <name>              - Name of a widget.  Must be unique.
#   <tooltip_text>      - Text of the tooltip
#
#   Returns:
#   None.
#
#   Examples:
#>  $win->add_tooltip('image1', "This is a tooltip");
#>  --------------------------------------
#>  $win->add_tooltip('image1', "This is a longer tooltip text \
#>                               with a visual break to handle \
#>                               it nicer in the code.\nAlso line \
#>                               breaks can be added, too.");
# ---------------------------------------------------------------------
sub add_tooltip #(<name>, <text>)
{
    my $self = shift;
    my $name = shift;
    my $object = $self->get_object($name);

    # Check if tooltip can be used
    if (defined($object->{tip})) {
        # remove all spaces/tabs if a backslash is found => wrap in script
        # in long text for better readability
        $object->{tip} =~ s/\R\h+//g;
        if ($object->{type} eq 'NotebookPage') {
            # add tooltip to label widget of the page if avaliable
            my $notebook = $self->_get_ref($object->{notebook});
            my $page_label = $notebook->get_menu_label($object->{ref});
            $object->{pagelabel}->set_tooltip_text(_($object->{tip}));
        } else {
            $object->{ref}->set_tooltip_text(_($object->{tip}));
        }
        
        $self->add_signal_handler($object->{name}, "query_tooltip", \&_query_tooltip);
    }
}


# ---------------------------------------------------------------------
#   Function: get_tooltip
#   Returns the current tooltip text of a widget.
#
#   Restriction:
#   Not available for the following widgets: <GtkMenu>, <GtkMenuBar>, <GtkFileChooserDialog>, <GtkFontSelectionDialog>, 
#   <GtkMessageDialog>, <GtkTreeView>, <GtkStatusbar>, <GtkTextView>, <GtkSeparator> and <GtkNotebook>.
#
#   Parameters:
#   <name>      - Name of a widget.
#
#   Returns:
#   Tooltip text or undef.
#
#   Example:
#>  my $text = $win->get_tooltip('image1');
# ---------------------------------------------------------------------
sub get_tooltip #(<name>)
{
    my $self = shift;
    my $name = @_;
    
    # get object and type
    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless($type =~ /(MenuBar|Menu$|Dialog$|LinkButton|List|Tree|Notebook$|Statusbar|Separator$|DrawingArea|TextView)/) {
        return $object->{tip};
    } else {
        $self->show_error($object, "\"$type\" hasn't a tooltip!");
        return;
    }
}


# ---------------------------------------------------------------------
#   Function: set_tooltip
#   Sets a new tooltip text on a widget.
#
#   If no tooltip exists function will add it.
#
#   Restriction:
#   Not available for the following widgets: <GtkMenu>, <GtkMenuBar>, <GtkFileChooserDialog>, <GtkFontSelectionDialog>, 
#   <GtkMessageDialog>, <GtkTreeView>, <GtkStatusbar>, <GtkTextView>, <GtkSeparator> and <GtkNotebook>.
#
#   Parameters:
#   <name>          - Name of a widget.
#   <tooltip_text>  - Text of the tooltip
#
#   Returns:
#   None.
#
#   Example:
#>  my $text = $win->set_tooltip('image1');
# ---------------------------------------------------------------------
sub set_tooltip #(<name>, <tooltip_text>)
{
    my $self = shift;
    my ($name, $text) = @_;
    
    my $object = $self->get_object($name);
    my $type = $object->{type};


    unless($type =~ /(MenuBar|Menu$|Dialog$|LinkButton|List|Tree|Notebook$|Statusbar|Separator$|DrawingArea|TextView)/) {
        # Check if tooltip is set
        if (defined($object->{tip})) {
            $object->{tip} = $text;
            $object->{ref}->set_tooltip_text(_($object->{tip}));
        } else {
            $object->{tip} = $text;
            $self->add_tooltip($object->{name});
        }
    } else {
        $self->show_error($object, "\"$type\" hasn't a tooltip!");
        return;
    }
}

1;
__END__
=head1 NAME

SimpleGtk2 - Rapid Application Development Library for Gtk+ version 2

For full documentation use the enclosed dhtml file (searchable).

=cut
