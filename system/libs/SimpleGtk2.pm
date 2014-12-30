# Copyright (c) 2014 Thomas Funk
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

package SimpleGtk2;

#use 5.004;
use strict;
use Gtk2 '-init';
use POSIX qw(setlocale);
use Locale::gettext;
use I18N::Langinfo qw(langinfo CODESET);
use Encode qw(decode encode);;

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

# This allows declaration	use SimpleGtk2 ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
%EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw(
	
);

$VERSION = '0.64';
$LANGUAGE = $ENV{LANG} || 'en_US.UTF-8';
$CODESET = langinfo(CODESET());
$GETTEXT = 0;

POSIX::setlocale(&POSIX::LC_ALL, $LANGUAGE);

######################################################################
# internal functions
######################################################################

# ---------------------------------------------------------------------
# Specifies a colon separated list of "locale path" in which to search
# for the string translation file and the translation file.
# use_gettext(<locale_paths>, <translation_file>, <codeset>)
# ---------------------------------------------------------------------
sub use_gettext {
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
# internal translation function
# ---------------------------------------------------------------------
sub _ {
    my $text = shift;
    return ($GETTEXT == 1 ? decode("utf-8", Locale::gettext::gettext($text)) : $text);
}

# ---------------------------------------------------------------------
# external translation function used to translate text part
# ---------------------------------------------------------------------
sub translate($$) {
    my $self = shift;
    my $text = shift;
    $text =~ s/\R\h+//g;
    return _($text);
}
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
    
    if ($short =~ /^(pos|tip|func|sig|sens|min|max|orient|valuepos|pixbuf|textbuf|scroll|dtype|mtype|rfunc|fname)/) {
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
        elsif ($short eq 'fname') {$short = 'filename';}
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
    unless($type =~ /^(Menubar|Notebook$|Menu$)/) {
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
                    $widget = $self->get_container($object->{name});
                }
                my $req = $widget->size_request();
                $object->{width} = $req->width;
                $object->{height} = $req->height;
            }
        }
	}
}

sub _clear_sb_after_timeout {
    my ($object, $msg_id) = @_; 
    my $pid = fork;
    return if $pid;     # in the parent process
    
    # wait x seconds before removing message
    print "start\n";
    print "-------------------------------\n";
    print Dumper(\$object);
    sleep 2;
    #remove message
#    $object->{statusbar}->push($object->{contextid}, 'bla');
    $object->{statusbar}->remove($object->{contextid}, $msg_id);
    print "end\n";
    exit;  # end child process
}


# ---------------------------------------------------------------------
# get the current fontsize of a widget
# get_fontsize(<widget>)
# ---------------------------------------------------------------------
sub get_fontsize($) {
    my $widget = shift;
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
# get the current font family of a widget
# get_fontfamily(<widget>)
# ---------------------------------------------------------------------
sub get_fontfamily($) {
    my $widget = shift;
    my $context = $widget->get_pango_context();
    my $fontDesc = $context->get_font_description();
    my $fontfamily = $fontDesc->get_family();
    return $fontfamily
}

# ---------------------------------------------------------------------
# get the current font weight of a widget
# get_fontweight(<widget>)
# ---------------------------------------------------------------------
sub get_fontweight($) {
    my $widget = shift;
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
# calculate the current scaling factor depending on the font size
# _calc_scalefactor(<old_font_size>, <new_font_size>)
# ---------------------------------------------------------------------
sub _calc_scalefactor($@) {
    my $self = shift;
    my ($old_size, $new_size) = @_;
    
    my $context = $self->{ref}->get_pango_context();
    my $language = $context->get_language();

    my $old_fdesc = Pango::FontDescription->from_string('Sans ' . $old_size);
    my $old_metrics = $context->get_metrics($old_fdesc, $language);
    my $old_char_widths = $old_metrics->get_approximate_char_width();

    my $new_fdesc = Pango::FontDescription->from_string('Sans ' . $new_size);
    my $new_metrics = $context->get_metrics($new_fdesc, $language);
    my $new_char_widths = $new_metrics->get_approximate_char_width();
    
    my $new_scalefactor = sprintf "%.1f", $new_char_widths/$old_char_widths;
    #print "new_scalefactor: $new_scalefactor";
    
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
                my $container = $self->get_container($object->{container});
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


######################################################################
# Main class
######################################################################

# ---------------------------------------------------------------------
# new Window (  Name => '<name>'                <= must be unique
#               Title => '<window title>
#               Version => 'version-string'     <= Optional. Version string of the program. Will be appended after the title
#               Base => <font_size>             <= This is the font size used while creating the layout. Default is 10
#               Size => [width, height],        <= Optional
#               Fixed => <0/1>,                 <= Optional. Default: 0 (resizable)
#               Iconpath => <icon_path>         <= Optional. Path to an icon shown in title bar or on iconify
#               ThemeIcon => <theme_icon_name>  <= Optional. Icon name from current theme
#               Statusbar => <show_time>        <= Optional. If set a statusbar will show at the bottom
#                                                  of the window. <show_time> is the time in seconds the
#                                                  message will show.
#)
# ---------------------------------------------------------------------
sub new_window ($@) {
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
    # hash with all signal handlers used for this window
    $self->{handler} = {};
    $self->{scalefactor} = 1.0;
    $self->{name} = '';
    $self->{base} = 10;
    $self->{old_font} = undef;
    $self->{old_fontsize} = undef;

    bless $self, $class;

    my %params = $self->_normalize(@_);
    $self->{name} = $params{'name'};
    $self->{base} = $params{'base'} || 10;
    $self->{version} = $params{'version'} || undef;

    my $object = _new_widget(%params);
    $object->{type} = 'toplevel';
    $object->{fixed} = $params{'fixed'} || 0;
    $object->{statusbar} = $params{'statusbar'} || undef;

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
        $sb_object->{timeout} = 5;
        $sb_object->{statusbar} = $statusbar;
        # get context id
        my $context_id = $statusbar->get_context_id($object->{name});
        $sb_object->{contextid} = $context_id;
        # get size
        my $req = $statusbar->size_request();
        $sb_object->{width} = $req->width;
        $sb_object->{height} = $req->height;
        # add widget object to window objects list
        $self->{objects}->{$sb_object->{name}} = $sb_object;
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


######################################################################
# Helper functions
######################################################################

# ---------------------------------------------------------------------
# internal die if fatal error occur
# ---------------------------------------------------------------------
sub internal_die ($@) {
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
# print error message to standard error
# ---------------------------------------------------------------------
sub show_error ($@) {
    my $self = shift;
    my ($object, $msg) = @_;
    if (defined($msg)) {
        print STDERR "[" . $self->{name} . "->$object->{name}][err]: $msg\n";
    } else {
        print STDERR "[" . $self->{objects}->{$self->{name}}->{title} . "][err]: $object\n";
    }
}


# ---------------------------------------------------------------------
# print message to standard error
# ---------------------------------------------------------------------
sub show_message ($@) {
    my $self = shift;
    my ($object, $msg) = @_;
    if (defined($msg)) {
        print STDERR "[" . $self->{name} . "->$object->{name}][msg]: $msg\n";
    } else {
        print STDERR "[" . $self->{objects}->{$self->{name}}->{title} . "][msg]: $object\n";
    }
}


# ---------------------------------------------------------------------
# show window with all widgets without run Gtk2->main
# this is important if lib will use in FVWM module
# ---------------------------------------------------------------------
sub show($) {
    my $self = shift;
    $self->{ref}->show();
    # show some widgets which are in the lates array
    foreach my $name (@{$self->{lates}}) {
        my $object = $self->get_object($name);
        $object->{ref}->show_all();
    }
    # Now the current base can be set if different from fontsize
    if ($self->{scalefactor} != 1) {
        $self->{base} = $self->{fontsize};
        $self->{scalefactor} = 1;
    }
}


# ---------------------------------------------------------------------
# show window with all widgets anf start Gtk2->main
# ---------------------------------------------------------------------
sub show_and_run($) {
    my $self = shift;
    $self->show();
    Gtk2->main;
}

# ---------------------------------------------------------------------
# add signal to widget
# add_signal_handler(<name>, <signal>, <function>, <data>)
# ---------------------------------------------------------------------
sub add_signal_handler($@) {
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
        } else {
            $id = $object->{ref}->signal_connect($signal, $function, $data);
        }
        $object->{handler}->{$signal} = $id;
    }
}

# ---------------------------------------------------------------------
# remove signal handler from widget
# remove_signal_handler(<name>, <signal>)
# ---------------------------------------------------------------------
sub remove_signal_handler($@) {
    my $self = shift;
    my ($name, $signal) = @_;
    
    my $object = $self->get_object($name);
    my $id = $object->{handler}->{$signal};
    
    $object->{ref}->signal_handler_disconnect($id);
    delete $object->{handler}->{$signal};
}


# ---------------------------------------------------------------------
# get object hash from objects list
# get_object(<name_or_widget>)
# ---------------------------------------------------------------------
sub get_object($$) {
    my $self = shift;
    my $identifier = shift;
    my $object = undef;
    if (ref($identifier) =~ m/^Gtk2::/) {
        foreach (keys %{$self->{objects}}) {
            if ($self->{objects}->{$_}->{ref} == $identifier) {
                $object = $self->{objects}->{$_};
            }
        }
    } else {
        $object = $self->{objects}->{$identifier};
    }
    $self->show_error($identifier, "No object found!") unless defined($object);
    return $object;
}

# ---------------------------------------------------------------------
# check if object xyz exist. Return 1 if true else 0
# exist_object(<name_or_widget>)
# ---------------------------------------------------------------------
sub exist_object($$) {
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


# ---------------------------------------------------------------------
# get widget reference
# get_widget(<name>)    <= must be unique
# ---------------------------------------------------------------------
sub get_widget($$) {
    my $self = shift;
    my $name = shift;
    return $self->{objects}->{$name}->{ref};
}


# ---------------------------------------------------------------------
# hide a widget
# hide_widget(<name>)
# ---------------------------------------------------------------------
sub hide_widget($$) {
    my $self = shift;
    my $name = shift;

    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless($type =~ /^(MenuItem|Menu$|NotebookPage)/) {
        $object->{ref}->hide();
    } else {
        $self->show_error($object, "For \"$type\" use set_sensitive() instead.");
        return;
    }
}


# ---------------------------------------------------------------------
# show a widget
# show_widget(<name>)
# ---------------------------------------------------------------------
sub show_widget($$) {
    my $self = shift;
    my $name = shift;

    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless($type =~ /^(MenuItem|Menu$|NotebookPage)/) {
        $object->{ref}->show();
    } else {
        $self->show_error($object, "For \"$type\" use set_sensitive() instead.");
        return;
    }
}


# ---------------------------------------------------------------------
# get_container(<name_of_container>)
# ---------------------------------------------------------------------
sub get_container($@) {
    my $self = shift;
    my $name = shift;
    return $self->{containers}->{$name};
}


# ---------------------------------------------------------------------
# add widget to a fixed container
# add_to_container(<name>)
# ---------------------------------------------------------------------
sub add_to_container($@) {
    my $self = shift;
    my $name = shift;
    my $object = $self->get_object($name);
    
    if (defined($object->{container})) {
        my $container = $self->get_container($object->{container});
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
# add tooltip to widget
# add_tooltip(<name>)
# ---------------------------------------------------------------------
sub add_tooltip($@) {
    my $self = shift;
    my $name = shift;
    my $object = $self->get_object($name);

    # Check if tooltip should use
    if (defined($object->{tip})) {
        # remove all spaces/tabs if a backslash is found => wrap in script
        # in long text for better readability
        $object->{tip} =~ s/\R\h+//g;
        if ($object->{type} eq 'NotebookPage') {
            # add tooltip to label widget of the page if avaliable
            my $notebook = $self->get_widget($object->{notebook});
            my $page_label = $notebook->get_menu_label($object->{ref});
            $object->{pagelabel}->set_tooltip_text(_($object->{tip}));
        } else {
            $object->{ref}->set_tooltip_text(_($object->{tip}));
        }
        
        $self->add_signal_handler($object->{name}, "query_tooltip", \&_query_tooltip);
    }
}

######################################################################
# Widget create functions
######################################################################

# ---------------------------------------------------------------------
# add_button(   Name   => <name>,                  <= Name of the button. Must be unique
#               Pos    => [pos_x, pos_y], 
#               Title  => <title>,
#               Font   => [family, size, weight]   <= Optional. Sets a title font. to use the defaults set values with undef
#               Color  => [<color>, <state>]       <= Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                               State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (Gtk2::State)
#               Size   => [width, height],         <= Optional
#               Tip    => <tooltip-text>)          <= Optional
#               Frame  => <frame_name>             <= Name of the frame where widget is located. Must be unique
#               Func   => <function_click>         <= Optional. Can be set later with add_signal_handler
#               Sig    => <signal>                 <= Optional. Only in conjunction with Func
#               Sens   => <sensitive>              <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_button($@) {
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
    $self->add_to_container($object->{name});

    $button->show();
}


# ---------------------------------------------------------------------
# add_link_button(  Name    => <name>,                  <= Name of the button. Must be unique
#                   Pos     => [pos_x, pos_y], 
#                   Title   => <title>,
#                   Font    => [family, size, weight]   <= Optional. Sets a title font. to use the defaults set values with undef
#                   Color  => [<color>, <state>]        <= Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                                    State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (Gtk2::State)
#                   Size    => [width, height],         <= Optional
#                   Uri     => <Uri-text>)              <= A valid URI. It is the tooltip as well.
#                   Frame   => <frame_name>             <= Name of the frame where widget is located. Must be unique
#                   Func    => <function_click>         <= Optional. Can be set later with add_signal_handler
#                   Sig     => <signal>                 <= Optional. Only in conjunction with Func
#                   Sens    => <sensitive>              <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_link_button($@) {
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
        $self->internal_die($object, "No Uri defined! Exiting.");
    }

    # set relief to none
    $link_button->set_relief ('none');
    
    # add widget reference to widget object
    $object->{ref} = $link_button;
    
    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);

    # set font color if defined
    $self->set_font_color($object->{name}, $color, $cstate) if defined($color);

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the button
    $self->add_to_container($object->{name});

    $link_button->show();
}

# ---------------------------------------------------------------------
# add_filechooser_button(   Name    => <name>,              <= Name of the button. Must be unique
#                           Pos     => [pos_x, pos_y], 
#                           Title   => <title>,
#                           Size    => [width, height],     <= Optional
#                           Tip     => <tooltip-text>       <= Optional
#                           Action  => <open_mode>          <= The open modes are: 'open' and 'select-folder'.
#                           Frame   => <frame_name>         <= Name of the frame where widget is located. Must be unique
#                           File    => <file_path>          <= Optional. Set file for 'open' action
#                           Filter  => <pattern|mimetype> | [<name>, <pattern|mimetype>]  <= Optional. Sets the current file filter for 'open' action
#                           Folder  => <directory>          <= Optional. Set directory for 'select-folder' action or if no file path is set for 'open' action
#                           Func    => <function>           <= Optional. Can be set later with add_signal_handler
#                           Sig     => <signal>             <= Optional. Only in conjunction with Func
#                           Sens    => <sensitive>          <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_filechooser_button($@) {
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
        $self->internal_die($object, "No action defined! Exiting.");
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
    $self->add_to_container($object->{name});

    $filechooser_button->show();
}


# ---------------------------------------------------------------------
# add_font_button(  Name    => <name>,                  <= Name of the button. Must be unique
#                   Pos     => [pos_x, pos_y], 
#                   Title   => <title>,                 <= Optional. The title displayed in the font dialog
#                   Size    => [width, height],         <= Optional
#                   Tip     => <tooltip-text>           <= Optional
#                   Frame   => <frame_name>             <= Name of the frame where widget is located. Must be unique
#                   Font    => [family, size, weight]   <= Optional. Sets the initial font. Font family and size are requiered if set
#                   Func    => <function>               <= Optional. Can be set later with add_signal_handler
#                   Sig     => <signal>                 <= Optional. Only in conjunction with Func
#                   Sens    => <sensitive>              <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_font_button($@) {
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
    $self->add_to_container($object->{name});

    $font_button->show();
}


# ---------------------------------------------------------------------
# add_check_button( Name => <name>,                 <= Name of the button. Must be unique
#                   Pos => [pos_x, pos_y], 
#                   Title => <title>,
#                   Font => [family, size, weight]  <= Optional. Sets a button font. to use the defaults set values with undef
#                   Color  => [<color>, <state>]    <= Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                                State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (Gtk2::State)
#                   Active => 0/1                   <= Should be active? Default: 0 (not active)
#                   Tip => <tooltip-text>)          <= Optional
#                   Frame => <frame_name>           <= Name of the frame where widget is located. Must be unique
#                   Func => <function_click>        <= Optional. Can be set later with add_signal_handler
#                   Sig => <signal>                 <= Optional. Only in conjunction with Func
#                   Sens => <sensitive>             <= Optional. Default: 1
#                   )
# ---------------------------------------------------------------------
sub add_check_button($@) {
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'CheckButton';
    
    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;
    
    # create check button
    my $check_button = $self->create_check_widget($object->{name}, %params);

    # position the button
    $self->add_to_container($object->{name});
    
    $check_button->show();
}


# ---------------------------------------------------------------------
# create_check_widget(<name>, <params>)
# ---------------------------------------------------------------------
sub create_check_widget($@) {
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

# ---------------------------------------------------------------------
# add_radio_button( Name    => <name>,                  <= Name of the button. Must be unique
#                   Pos     => [pos_x, pos_y], 
#                   Title   => <title>,
#                   Font    => [family, size, weight]   <= Optional. Sets a button font. to use the defaults set values with undef
#                   Color   => [<color>, <state>]       <= Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                                    State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (Gtk2::State)
#                   Group   => <button_group>,          <= Name of the buttongroup. Must be unique
#                   Active  => 0/1                      <= Which is the active button. Default: 0 (not active)
#                   Tip     => <tooltip-text>)          <= Optional
#                   Frame   => <frame_name>             <= Name of the frame where widget is located. Must be unique
#                   Func    => <function_click>         <= Optional. Can be set later with add_signal_handler
#                   Sig     => <signal>                 <= Optional. Only in conjunction with Func
#                   Sens    => <sensitive>              <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_radio_button($@) {
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'RadioButton';

    # add widget object to window objects list
    $self->{objects}->{$object->{name}} = $object;
    
    # create radio button
    my $radio_button = $self->create_radio_widget($object->{name}, %params);
    
    # position the radio button
    $self->add_to_container($object->{name});
    
    $radio_button->show();
}

# ---------------------------------------------------------------------
# create_radio_widget(<name>, <params>)
# ---------------------------------------------------------------------
sub create_radio_widget($@) {
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
        $last = $self->get_widget($self->{groups}->{$object->{group}}[-1]);
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


# ---------------------------------------------------------------------
# add_label (   Name    => <name>,                  <= name of the label. Must be unique
#               Title   => <title>,
#               Font    => [family, size, weight]   <= Optional. Sets a label font. to use the defaults set values with undef
#               Color   => [<color>, <state>]       <= Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                                State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (Gtk2::State)
#               Pos     => [pos_x, pos_y], 
#               Widget  => <name_of_linked_widget>  <= Optional in conjunction with underlined
#               Justify => <justify>                <= Optional: left, right, center, fill
#               Wrap    => 0/1                      <= Optional. Only usable in a frame
#               Frame   => <frame_name>             <= Name of the frame where widget is located. Must be unique
#               Sens    => <sensitive>              <= Optional. Default: 1
#               Tip     => <tooltip-text>)          <= Optional
#)
# ---------------------------------------------------------------------
sub add_label($@) {
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
        my $obj_ref = $self->get_widget($object->{widget});
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
    $self->add_to_container($object->{name});
    
    $label->show();
}


# ---------------------------------------------------------------------
# add_frame (   Name    => <name>,                  <= widget name - must be unique
#               Title   => <title>,
#               Font    => [family, size, weight]   <= Optional. Sets a frame font. to use the defaults set values with undef
#               Color   => [<color>, <state>]       <= Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                                State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (Gtk2::State)
#               Pos     => [pos_x, pos_y], 
#               Size    => [width, height],
#               Tip     => <tooltip-text>)          <= Optional
#               Sens    => <sensitive>              <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_frame($@) {
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
        $self->add_to_container($object->{name});
    }
    
    $frame->show();
}


# ---------------------------------------------------------------------
# add_entry (   Name => <name>,                 <= object name - must be unique
#               Title => <title>,
#               Font => [family, size, weight]  <= Optional. Sets a text entry font. to use the defaults set values with undef
#               Pos => [pos_x, pos_y], 
#               Size => [width, height],
#               Align => <xalign>               <= Optional: left (default), right
#               Tip => <tooltip-text>)          <= Optional
#               Frame => <frame_name>           <= Name of the frame where widget is located. Must be unique
#               Func => <function_click>        <= Optional. Can be set later with add_signal_handler
#               Sig => <signal>                 <= Optional. Only in conjunction with Func
#               Sens => <sensitive>             <= Optional. Default: 1
#               )
# ---------------------------------------------------------------------
sub add_entry($@) {
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
    $self->add_to_container($object->{name});
    
    $entry->show();
}


# ---------------------------------------------------------------------
# add_spin_button(  Name    => <name>,              <= widget name - must be unique
#                   Pos     => [pos_x, pos_y], 
#                   Size    => [width, height],     <= Optional
#                   Start   => <start_value>,       <= Optional. Default: 0.0
#                   Min     => <min_value>,         <= Double
#                   Max     => <max_value>,         <= Double
#                   Step    => <step_in/decrease>   <= Double
#                   Snap    => <snap_to_tick>       <= Optional
#                   Align   => <align>              <= Optional (left, right)
#                   Rate    => <from 0.0 to 1.0>    <= Optional. Default: 0.0
#                   Digits  => <used_digits>        <= Optional. Default: 0 (1 digit)
#                   Tip     => <tooltip-text>       <= Optional
#                   Frame   => <frame_name>         <= Name of the frame where widget is located. Must be unique
#                   Func    => <function_click>     <= Optional. Can be set later with add_signal_handler
#                   Sig     => <signal>             <= Optional. Only in conjunction with Func
#                   Sens    => <sensitive>          <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_spin_button($@) {
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
                                            0.0,
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
    $self->add_to_container($object->{name});
    
    $spin_button->show();
}


# ---------------------------------------------------------------------
# add_combo_box(    Name => <name>,                     <= widget name - must be unique
#                   Pos => [pos_x, pos_y], 
#                   Size => [width, height],            <= Optional
#                   Data => [Array_of_values>],
#                   Start => <start_value>,
#                   Columns = <wrap_list_to_x_columns>  <= Optional
#                   Tip => <tooltip-text>)              <= Optional
#                   Frame => <frame_name>               <= Name of the frame where widget is located. Must be unique
#                   Func => <function_click>            <= Optional. Can be set later with add_signal_handler
#                   Sig => <signal>                     <= Optional. Only in conjunction with Func
#                   Sens => <sensitive>                 <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_combo_box($@) {
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
    $self->add_to_container($object->{name});
    
    $combo_box->show();
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
#                   Tip => <tooltip-text>)              <= Optional
#)
# ---------------------------------------------------------------------




#                   Step => <step_in/decrease>      
#                   Align => <align>                <= Optional (left, right)
#                   Climbrate => <from 0.0 to 1.0>  <= Optional (default: 0.0)
#                   Digits => <used_digits>         <= Optional (default: 0)

# ---------------------------------------------------------------------


# ---------------------------------------------------------------------
# add_slider(   Name        => <name>,              <= widget name - must be unique
#               Pos         => [pos_x, pos_y], 
#               Size        => [width, height],     <= Optional
#               Orient      => <orientation>        <= orientation of the slider (horizontal, vertical)
#               Start       => <start_value>,       <= Optional. Default: 0.0
#               Min         => <min_value>,         <= Double
#               Max         => <max_value>,         <= Double
#               Step        => <step_in/decrease>   <= Double
#               DrawValue   => <1/0>                <= Optional. Default: 1
#               ValuePos    => <value_position>     <= Optional. Default: top (left, right, bottom)
#               Digits      => <digits>             <= Optional. Default: 0 (1 digit)
#               Tip         => <tooltip-text>)      <= Optional
#               Frame       => <frame_name>         <= Name of the frame where widget is located. Must be unique
#               Func        => <function_click>     <= Optional. Can be set later with add_signal_handler
#               Sig         => <signal>             <= Optional. Only in conjunction with Func
#               Sens        => <sensitive>          <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
# TODO: If a draw value is active the slider is moved to another position.
#       Have to be fixed ?
# ---------------------------------------------------------------------
sub add_slider($@) {
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Slider';

    $self->create_range_widget($object, %params);
}


# ---------------------------------------------------------------------
# add_scrollbar(    Name    => <name>,              <= widget name - must be unique
#                   Pos     => [pos_x, pos_y], 
#                   Size    => [width, height],     <= Optional
#                   Orient  => <orientation>        <= orientation of the slider (horizontal, vertical)
#                   Start   => <start_value>,       <= Optional. Default: 0.0
#                   Min     => <min_value>,         <= Double
#                   Max     => <max_value>,         <= Double
#                   Step    => <step_in/decrease>   <= Double
#                   Digits  => <digits>             <= Optional. Default: 0 (1 digit)
#                   Tip     => <tooltip-text>)      <= Optional
#                   Frame   => <frame_name>         <= Name of the frame where widget is located. Must be unique
#                   Func    => <function_click>     <= Optional. Can be set later with add_signal_handler
#                   Sig     => <signal>             <= Optional. Only in conjunction with Func
#                   Sens    => <sensitive>          <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_scroll_bar($@) {
    my $self = shift;
    my %params = $self->_normalize(@_);
    my $object = _new_widget(%params);
    $object->{type} = 'Scrollbar';

    $self->create_range_widget($object, %params);
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
sub create_range_widget($@) {
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
    $self->add_to_container($object->{name});
    $range_widget->show();
}


# ---------------------------------------------------------------------
# add_image(    Name    => <name>,                      <= widget name - must be unique
#               Path    => <file_path>,
#               Pixbuf  => <pix_buffer_object>
#               Stock   => [<stock_name>,<stock_size>]  <= stock_size is per default 'dialog' because for scaling.
#                                                           So, if stock_size is given, Size is optional
#               Pos     => [pos_x, pos_y], 
#               Size    => [width, height],             <= if widget is bigger/smaller it will be scaled
#               Tip     => <tooltip-text>)              <= Optional
#               Frame   => <frame_name>                 <= Name of the frame where widget is located. Must be unique
#               Func    => <function_click>             <= Optional. Can be set later with add_signal_handler
#               Sig     => <signal>                     <= Optional. Only in conjunction with Func
#               Sens    => <sensitive>                  <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_image($@) {
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
    $object->{image} = undef;

    # first create an eventbox to handle signals
    my $eventbox = Gtk2::EventBox->new();
    # bind an action to it - we support clicks only (at first time ^^)
    $eventbox->set_events('button_press_mask');
    $eventbox->show();
    
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
    
    my $image = Gtk2::Image->new_from_pixbuf($scaled);
    
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
    $self->add_to_container($object->{name});
    
    $image->show();
}


# ---------------------------------------------------------------------
# add_text_view(    Name        => <name>,                  <= widget name - must be unique
#                   Pos         => [pos_x, pos_y],
#                   Size        => [width, height],
#                   Path        => <file_path>,
#                   Textbuf     => <text_buffer_object>
#                   Text        => <text_string>
#                   Font        => [family, size, weight]   <= Optional. Sets a textview font. to use the defaults set values with undef
#                   LeftMargin  => <in_pixel>               <= Optional. Default: 0
#                   RightMargin => <in_pixel>               <= Optional. Default: 0
#                   Wrapped     => <wrap_mode>              <= Optional. Default: none (char, word, word-char)
#                   Justify     => <justify>                <= Optional: Default: left (right, center, fill)
#                   Frame       => <frame_name>             <= Name of the frame where widget is located. Must be unique
#                   Tip         => <tooltip-text>)          <= Optional
#                   Func        => <function_click>         <= Optional. Can be set later with add_signal_handler
#                   Sig         => <signal>                 <= Optional. Only in conjunction with Func
#                   Sens        => <sensitive>              <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_text_view($@) {
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
            $content = `cat $object->{path}` || $self->show_error($object, "Can't find $object->{path}. Check path.");
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
       
     # for later manipulation we put the $textview reference to the $textview object
    $object->{textview} = $textview;
 
    # change font if set
    $self->set_font($object->{name}, $font) if defined($font);
    
    # add textview to scrolled window
    $scrolled_window->add_with_viewport($textview);
    
    # add scrolled window (parent) to window objects list
    $object->{ref} = $scrolled_window;

    # set some common functions: size, tooltip and sensitive state
    $self->_set_commons($object->{name}, %params);
    
    # position the image
    $self->add_to_container($object->{name});

    $scrolled_window->show();
}


# ---------------------------------------------------------------------
# add_menu_bar( Name    => <name>,                <= widget name - must be unique
#               Pos     => [pos_x, pos_y], 
#               Size    => [width, height],       <= Optional. Default is complete window width      
#)
# ---------------------------------------------------------------------
sub add_menu_bar($@) {
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
    $self->add_to_container($object->{name});

    $vbox->add($menu_bar);
    #$vbox->pack_start($menu_bar,1,1,0);
    
    # get size
    my $req = $vbox->size_request();
    $object->{width} = $req->width;
    $object->{height} = $req->height;
    
    # add menubar item to lates list => will show while show_all()
    push(@{$self->{lates}}, $object->{name});
}

# ---------------------------------------------------------------------
# add_menu( Name    => <name>,                  <= widget name - must be unique
#           Menubar => <menu_bar>
#           Title   => <title>,
#           Justify => <justify>                <= Optional: Default: left (right)
#           Sens    => <sensitive>              <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_menu($@) {
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


# ---------------------------------------------------------------------
# add_menu_item(    Type => <type>,             <= Optional. Item type. Default: Item (tearoff, radio, check, separator)
#                   Name => <name>,             <= widget name - must be unique 
#                   Title => <title>,           <= Optional. Not usuable for tearoff and separator
#                   Tip => 'Blafasel',          <= Optional. Not usuable for separator
#                   Icon => <path>,             <= Optional. Not usuable for tearoff and separator
#                   Menu => 'EditMenu', 
#                   Func => <function_click>    <= Optional. Not usuable for tearoff and separator
#                   Sig => <signal>             <= Optional. Only in conjunction with Func
#                   Sens => <sensitive>         <= Optional. Default: 1
#                   Group => <button_group>,    <= Name of the buttongroup. Must be unique
#                   Active => 0/1               <= Which is the active button. Default: 0 (not active)
#)
# ---------------------------------------------------------------------
sub add_menu_item($@) {
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
    my $menu = $self->get_widget($params{'menu'});
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
            $menu_item = $self->create_check_widget($object->{name}, %params);
        }
        elsif ($object->{type} eq 'RadioMenuItem') {
            $menu_item = $self->create_radio_widget($object->{name}, %params);
        }
    }
    
    # add menu item to menu
    $menu->append($menu_item);
}


# ---------------------------------------------------------------------
# add_notebook( Name => <name>,                     <= widget name - must be unique
#               Pos => [pos_x, pos_y],
#               Size => [width, height],
#               Tabs => <position>               	<= Optional. Default: top (left, right, bottom, none)
#               Scrollable => 1/0                   <= Optional. Default: 1
#               Popup => 0/1)                       <= Optional. Default: 0
#               Frame => <frame_name>               <= Name of the frame where widget is located. Must be unique
#               Sens => <sensitive>                 <= Optional. Default: 1
# ---------------------------------------------------------------------
sub add_notebook($@) {
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
    $self->add_to_container($object->{name});

    $notebook->show();
}


# ---------------------------------------------------------------------
# add_nb_page(  Name        => <name>,                  <= widget name - must be unique
#               Title       => <title>,
#               Font        => [family, size, weight]   <= Optional. Sets the title font. to use the defaults set values with undef
#               Color       => [<color>, <state>]       <= Optional. Sets a title color. Color can be a standard name e.g. 'red' or a hex value like '#rrggbb',
#                                                                    State can be 'normal', 'active', 'prelight', 'selected' or 'insensitive' (Gtk2::State)
#               Notebook    => <notebook_name>,         <= notebook name - must be unique
#               Pos_n       => <number>,                <= Optional. Starts with 0
#               Tip         => <tooltip-text>)          <= Optional
#               Sens        => <sensitive>              <= Optional. Default: 1
#)
# ---------------------------------------------------------------------
sub add_nb_page($@) {
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
    my $notebook = $self->get_widget($object->{notebook});
    
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
# add_msg_dialog(   Name => <name>,                 <= widget name - must be unique
#                   Modal => <0/1>,               	<= Optional. Default: modal (1)
#                   DType => "<dialog_type>",       <= default: 'none'. Else 'ok', 'close', 'cancel', 'yes-no' or 'ok-cancel'
#                   MTyp => "<message_type>",       <= 'info', 'warning', 'question', 'error' or 'other'
#                   Icon => <path|stock|name>       <= Optional. Icon instead of message type icon
#                   RFunc => <response_function>    <= Have to be set if nonmodal (Modal => 0) is chosen.
#                                                      Gets the response 'ok', 'close', 'cancel', 'yes' or 'no'
#)
# ---------------------------------------------------------------------
sub add_msg_dialog($@) {
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
# show_msg_dialog(<name>, "<message_text1>", "<message_text2>")
# or a simple one
# show_msg_dialog(<dialog_type>, "<message_type>", "<message_text>")
# returns the response ('ok', 'close', 'cancel', 'yes', 'no')
# ---------------------------------------------------------------------
sub show_msg_dialog($@) {
    my $self = shift;
    my ($name, $msg1, $msg2) = @_;
    
    my $object = undef;
    my $modal;
    my $flags;
    my $messagetype;
    my $dialogtype;
    my $color;
    
    # is it a simple message dialog?
    if (exists($self->{objects}->{$name})) {
        # get object
        $object = $self->get_object($name);
        
        $flags = $object->{modal} ? [qw/modal destroy-with-parent/] : 'destroy-with-parent';
        $modal = $object->{modal};
        $dialogtype = $object->{dialogtype};
        $messagetype = $object->{messagetype};
        
    } else {
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
    }
    
    # initialize message box
    my $msg_box = Gtk2::MessageDialog->new_with_markup($self->{ref},
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


# ---------------------------------------------------------------------
# add_filechooser_dialog(Name   => <name>,              <= widget name - must be unique
#                        Title  => <title>,             <= Optional. Title of the dialog
#                        Action => <open_mode>          <= The open modes are: 'open', 'save', 'select-folder' and 'create-folder'.
#                        FName  => <file_name>          <= Optional. Set default file name for 'open' or 'save' action
#                        Filter => <pattern|mimetype> | [<name>, <pattern|mimetype>]  <= Optional. 
#                                                          Sets the current file filter for 'open' action
#                        Folder => <directory>          <= Optional. Set the default directory for 'select-folder' action
#                                                          or if no file path in show_filechooser_dialog is set for 'open' or 'save' action.
#                                                          Default is $home
#                        RFunc  => <response_function>  <= Optional. If not set show_filechooser_dialog will return the response
#)                                                         (the path/folder or 0)
# ---------------------------------------------------------------------
sub add_filechooser_dialog($@) {
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
# show_filechooser_dialog(<name>, <filename|file|folder>)
# or a simple one
# show_filechooser_dialog(<action_type>, <filename|file|folder>, <pattern|mimetype> | [<name>, <pattern|mimetype>])
# returns the path/folder or 0
# ---------------------------------------------------------------------
sub show_filechooser_dialog($@) {
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


# ---------------------------------------------------------------------
# add_fontselection_dialog( Name    => <name>,                  <= widget name - must be unique
#                           Title   => <title>,                 <= The title displayed in the font dialog
#                           Font    => [family, size, weight]   <= Optional. Sets the initial font. Font family and size are requiered if set
#                           Preview => <preview text>           <= Optional. Sets the previewed text
#                           RFunc   => <response_function>      <= Optional. If not set show_font_dialog will return the response 
#                                                                           (the font string: "fontname weight size" or 0)
#)
# ---------------------------------------------------------------------
sub add_fontselection_dialog($@) {
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
# show_fontselection_dialog(<name>)
# or a simple one
# show_fontselection_dialog(family, size, weight)
# returns the font string: "family weight size" or 0
# ---------------------------------------------------------------------
sub show_fontselection_dialog($@) {
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


# ---------------------------------------------------------------------
# add_list(    Name => <name>,                     <= widget name - must be unique
#           Pos => [pos_x, pos_y], 
#           Size => [width, height],            <= Optional
#           Data => [Array_of_values>],
#)
# ---------------------------------------------------------------------


######################################################################
# Getter funtions
######################################################################

# ---------------------------------------------------------------------
# get sensitive state
# is_sensitive(<name>)
# ---------------------------------------------------------------------
sub is_sensitive($@) {
    my $self = shift;
    my $name = @_;
    
    # get widget
    my $widget = $self->get_widget($name);
    
    return $widget->is_sensitive();
}


# ---------------------------------------------------------------------
# get the title of a widget
# TODO: Perhaps it has to changed to widget specific get functions
# get_title(<name>)
# ---------------------------------------------------------------------
sub get_title($$) {
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
# get tooltip text from a widget
# get_tooltip(<name>)
# ---------------------------------------------------------------------
sub get_tooltip($@) {
    my $self = shift;
    my $name = @_;
    
    # get object and type
    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless($type =~ /^(Menubar|Notebook$|Menu$|LinkButton)/) {
        return $object->{tip};
    } else {
        $self->show_error($object, "\"$type\" hasn't a tooltip!");
        return;
    }
}


# ---------------------------------------------------------------------
# get size of a widget
# get_size(<name>)
# ---------------------------------------------------------------------
sub get_size($$) {
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
# get position of a widget
# get_pos(<name>)
# ---------------------------------------------------------------------
sub get_pos($$) {
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
# get active state of Check- and RadioButtons. Also from GtkSpinner
# is_active(<name>)
# get state whether a given value/string is current active in a combobox
# is_active(<name>, <value>)
# ---------------------------------------------------------------------
sub is_active($@) {
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
# has text an underline?
# is_underlined(<text>)
# ---------------------------------------------------------------------
sub is_underlined($@) {
    my $self = shift;
    my $text = shift;
    
    # remove double underlines
    $text =~ s/__//;
    
    my $underlined = $text =~ /_/ ? 1 : 0;
    return $underlined;
#   return ($text =~ /_/ ? 1 : 0); <= the same ^^
}

# ---------------------------------------------------------------------
# get_value(<name>, <keyname>)
# ---------------------------------------------------------------------
sub get_value($@) {
    my $self = shift;
    my $name = shift;
    my $key = _extend(lc(shift));
    my $value = 'Error';
    
    # get widget object
    my $object = $self->get_object($name);

    if ($object->{type} =~ /^(Check|Radio)/) {
        if    ($key eq 'active') {$value = $object->{ref}->is_active();}
    }
    
    elsif ($object->{type} eq 'LinkButton') {
        # get uri
        if    ($key eq 'uri') {$value = $object->{ref}->get_uri();}
    }
    
    elsif ($object->{type} eq 'Label') {
        # line wrap
        if    ($key eq 'wrapped') {$value = $object->{ref}->get_line_wrap();}
        # justification of label
        elsif ($key eq 'justify') {$value = $object->{ref}->get_justify();}
    }
    
    elsif ($object->{type} eq 'entry') {
        # alignment
        if    ($key eq 'align') {$value = $object->{ref}->get_alignment();}
    }
    
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
    
    elsif ($object->{type} eq 'ComboBox') {
        # index of active value, else -1
        if    ($key eq 'active') {$value = $object->{ref}->get_active();}
        # columns
        elsif ($key eq 'columns') {$value = $object->{ref}->get_wrap_width();}
        # data array
        elsif ($key eq 'data') {$value = $object->{data};}
    }

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
    
    elsif ($object->{type} eq 'Image') {
        # not supported
        $self->show_error($object, "'get_value' doesn't support \"$key\". Use 'get_image' instead.");
        $value = undef;
    }
    
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
            $self->show_error($object, "'get_value' doesn't support \"$key\". Use 'get_textview' instead.");
            $value = undef;
        }
    }
    
    elsif ($object->{type} eq 'Menu') {
        # get justification
        if ($key eq 'justify') {$value = $object->{title_item}->get_right_justified() == 1 ? 'right' : 'left';}
    }
    
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
    
    elsif ($object->{type} eq 'Notebook') {
        # get current page
        if ($key eq 'currentpage') {$value = $object->{ref}->get_current_page();}
        # get count of pages
        elsif ($key eq 'pages') {$value = $object->{ref}->get_n_pages();}
        # popup active?
        elsif ($key eq 'popup') {$value = $object->{popup};}
        # get page name with number
        elsif ($key eq 'number2name') {
            # get page widget
            my $page = $object->{ref}->get_nth_page();
            my $page_object = $self->get_object($page);
            $value = $page_object->{name};
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
            $self->show_error($object, "Parameter \"$key\" used with type 'NotebookPage' only.");
            $value = undef;
        }
    }
    
    elsif ($object->{type} eq 'NotebookPage') {
        # get number with page name
        if ($key eq 'pagenumber') {$value = $object->{notebook}->page_num($object->{ref});}
        # get allocated notebook name
        elsif ($key eq 'notebook') {
            my $nb_object = $self->get_object($object->{notebook});
            $value = $nb_object->{name};
        }
        elsif ($key =~ /^(scrollable|currentpage|pagination|no2name|tabs|popup)/) {
            $self->show_error($object, "Parameter \"$key\" used with type 'Notebook' only.");
            $value = undef;
        }
    }

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

    unless ($value eq 'Error') {
        return $value;
    } else {
        $self->show_error($object, "Unknown parameter \"$key\".");
        return undef;
    }
}

# ---------------------------------------------------------------------
# get font from object
# get_font_string(<name>)
# ---------------------------------------------------------------------
sub get_font_string($$) {
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
        $self->show_error($object, "\"$type\" hasn't a font!");
        return;
    }
}

# ---------------------------------------------------------------------
# get font as array - font string split into array format
# get_font_array(<name>)
# ---------------------------------------------------------------------
sub get_font_array($@) {
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
        $self->show_error($object, "\"$object->{type}\" hasn't a font!");
        return;
    }
}

# ---------------------------------------------------------------------
# font_array_to_string <= Build from a font array a font string. 
# Font family and size is requiered.
# Array: [family, size, weight]
# ---------------------------------------------------------------------
sub font_array_to_string(@) {
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
# font_string_to_array <= Build from a font string a font array. 
# Font family AND size is requiered.
# ---------------------------------------------------------------------
sub font_string_to_array {
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
# get image - as pixbuff or image object
# get_image(<name> [, <keyname>])
# ---------------------------------------------------------------------
sub get_image($@) {
    my $self = shift;
    my $name = shift;
    my $key = _extend(lc(shift)) || undef;
    my $image = 'Error';

    # get image object
    my $object = $self->get_object($name);

    # get image reference
    if ($key eq 'image' or $key == undef) {$image = $object->{image};}
    # get pixbuf
    elsif ($key eq 'pixbuffer') {$image = $object->{pixbuf};}
    # get path
    elsif ($key eq 'path') {$image = $object->{path};}

    unless ($image eq 'Error') {
        return $image;
    } else {
        $self->show_error($object, "Unknown parameter \"$key\".");
        return undef;
    }
}


# ---------------------------------------------------------------------
# get textview object
# get_textview(<name> [, <keyname>])
# ---------------------------------------------------------------------
sub get_textview($@) {
    my $self = shift;
    my $name = shift;
    my $key = _extend(lc(shift)) || undef;
    my $textview = 'Error';

    # get textview object
    my $object = $self->get_object($name);

    # get textview reference
    if ($key eq 'textview' or $key == undef) {$textview = $object->{textview};}
    # get text buffer
    elsif ($key eq 'textbuffer') {$textview = $object->{textbuf};}
    # get path
    elsif ($key eq 'path') {$textview = $object->{path};}
    # not supported
    elsif ($key =~ /margin$|wrapped|justify/) {
        $self->show_error($object, "'get_textview' returns textbuffer/textview reference only. Use 'get_value' for \"$key\" instead.");
        $textview = undef;
    }

    unless ($textview eq 'Error') {
        return $textview;
    } else {
        $self->show_error($object, "Unknown parameter \"$key\".");
        return undef;
    }
}


# ---------------------------------------------------------------------
# get group or group name from radio button/menu
# get_group(<name>, ["Name"])
# ---------------------------------------------------------------------
sub get_group($@) {
    my $self = shift;
    my ($name, $type) = @_;
    
    my $object = $self->get_object($name);
    
    if ($object->{type} =~ /^Radio/) {
        unless (defined($type)) {
            # get radio button/menu group object
            return $object->{ref}->get_group();
        } else {
            # get radio button/menu group name
            return $object->{group};
        }
    } else {
        $self->show_error($object, "Can't get group - wrong type \"$object->{type}\"!");
    }
}



######################################################################
# Setter functions
######################################################################

# ---------------------------------------------------------------------
# set sensitivity of a widget or a radio button group
# set_sensitive(<name/group>, <state>)
# ---------------------------------------------------------------------
sub set_sensitive($@) {
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
            $widget = $self->get_widget($self->{groups}->{$name}[0]);
            my $group = $widget->get_group();
            foreach (@$group) {
                $_->set_sensitive($state);
            }
        } else {
            $self->show_error("$name not found - neither in objects nor in groups list!");
        }
    }
}


# ---------------------------------------------------------------------
# set title of a widget
# set_title(<name>, <new_title>)
# ---------------------------------------------------------------------
sub set_title($@) {
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
# set tooltip of a widget. If no tooltip exist function will add it
# set_tooltip(<name>, <tooltip_text>)
# ---------------------------------------------------------------------
sub set_tooltip($@) {
    my $self = shift;
    my ($name, $text) = @_;
    
    my $object = $self->get_object($name);
    my $type = $object->{type};


    unless($type =~ /^(Menubar|Notebook$|TextView|Menu$)/) {
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


# ---------------------------------------------------------------------
# set size of a widget
# set_size(<name>, <new_width>, <new_height>)
# ---------------------------------------------------------------------
sub set_size($@) {
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
# set position of a widget
# set_pos(<name>, <new_x>, <new_y>)
# ---------------------------------------------------------------------
sub set_pos($@) {
    my $self = shift;
    my ($name, $pos_x, $pos_y) = @_;

    my $object = $self->get_object($name);
    my $type = $object->{type};
    
    unless($type =~ /^(MenuItem|Menu$|NotebookPage)/) {
        if (defined($object->{container})) {
            my $container = $self->get_container($object->{container});
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
# set_value(<name>, Value/MaxValue/MinValue => <new_value>)
# ---------------------------------------------------------------------
sub set_value($@) {
    my $self = shift;
    my $name = shift;
    my %params = @_;

    unless (scalar(keys %params) > 1) {
        $self->set_values($name, %params);
    } else {
        $self->show_error("Too much parameters! Use 'set_values' instead.");
    }
}


# ---------------------------------------------------------------------
# set_values(<name>, Value_x => <new_value>, Value_y => <new_value>, ...)
# ---------------------------------------------------------------------
sub set_values($@) {
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
            # set digits
            if (defined($params{'digits'}) and $reconfigure) {
                $digits = $params{'digits'};
            } else {
                $object->{ref}->set_digits($params{'digits'}) unless $reconfigure;
            }
            delete $params{'digits'} if defined($params{'digits'});
            # set climbrate
            if (defined($params{'climbrate'}) and $reconfigure) {
                $climbrate = $params{'climbrate'};
            } else {
                $reconfigure = 1 unless defined($params{'climbrate'});
            }
            delete $params{'climbrate'} if defined($params{'climbrate'});

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
                $self->show_error($object, "\"$object->{type}\" hasn't an icon!");
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
        }
        my @fontarray = $self->get_font_array($object->{font});
        # set only font family
        if (defined($params{'fontfamily'})) {
            $fontarray[0] = $params{'fontfamily'};
        }
        # set only font size
        if (defined($params{'fontsize'})) {
            $fontarray[1] = $params{'fontsize'};
        }
        # set only font weight
        if (defined($params{'fontweight'})) {
            $fontarray[2] = $params{'fontweight'};
        }
        # update object and reference
        $object->{font} = "$fontarray[0] $fontarray[2] $fontarray[1]";
        if ($object->{type} eq 'FontButton'){
            $object->{ref}->set_font_name ($object->{font});
        }
    }

    # if there remain(s) unknown parameter(s) 
    if (scalar keys %params > 0) {
        my $rest = join(", ", keys %params);
        $self->show_error($object, "Unknown parameter(s) \"$rest\".");
    }
}


# ---------------------------------------------------------------------
# set_image(Name    => <name>,                      <= widget name - must be unique
#           Path    => <file_path>,
#           Pixbuf  => <pix_buffer_object>
#           Image   => <image_object>
#           Stock   => [<stock_name>,<stock_size>]  <= stock_size is per default 'dialog' because for scaling.
#                                                           So, if stock_size is given, Size is optional
#)
# ---------------------------------------------------------------------
sub set_image($@) {
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
        $self->show_error($object, "Unknown parameter(s): \"$rest\".");
        return undef;
    }
    
    # remove old one from eventbox
    $object->{ref}->remove($object->{image});
    
    # put the new image reference to the image object
    $object->{image} = $image;

    # add image to eventbox
    $object->{ref}->add($image);
    
    # show new image
    $object->{ref}->show();
}

# ---------------------------------------------------------------------
# set_textview( Name => <name>,                     <= widget name - must be unique
#               Path => <file_path>,
#               Textbuf => <text_buffer_object>
#               Text => <string>
#)
# ---------------------------------------------------------------------
sub set_textview($@) {
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
        $self->show_error($object, "Unknown parameter(s): \"$rest\".");
        return undef;
    }
    
    # add  to textview buffer
    $object->{textview}->set_buffer($object->{textbuf});
    
    # show it
    $object->{textview}->show();
}


# ---------------------------------------------------------------------
# set_group(<name>, <group/group_name>)
# Sets a new group on the radio button _<name>_. 
# It can be used an existing group object or group name.
# ---------------------------------------------------------------------
# TODO: how to set group? a single widget, all of an old group or what?
sub set_group($@) {
    my $self = shift;
    my $hme = @_;
    print "set_group not implemented yet.\n";
}


# ---------------------------------------------------------------------
# set_font(<name>, <font_string> | [family, size, weight] | Family => family, Size => size, Weight => weight)
# ---------------------------------------------------------------------
sub set_font($@) {
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
            $self->show_error($object, "Can't set font \"$new_font_string\" - wrong type \"$type\"!");
        } else {
            $self->show_error($object, "Can't set font - wrong type \"$type\"!");
        }
        return;
    }
}


# ---------------------------------------------------------------------
# set_font_color(<name>, <color>, <state>)
# <state> is optional. Default is 'normal'
# ---------------------------------------------------------------------
sub set_font_color($@) {
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
        $self->show_error($object, "Can't set color \"$new_color\" - wrong type \"$type\"!");
        return;
    }
    $label->modify_fg($state, $gdk_color);
}




# ---------------------------------------------------------------------
# remove_nb_page(<nb_name>, <name/number>)
# ---------------------------------------------------------------------
sub remove_nb_page($@) {
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



1;
__END__
=head1 NAME

SimpleGtk2 - Rapid Application Development Library for Gtk+ version 2

=head1 SYNOPSIS

    use SimpleGtk2;
    
    # Toplevel window
    my $win = SimpleGtk2->new_window(Type => 'toplevel', Name => 'mainWindow', 
                                    Title => 'testem-all', Size => [400, 400]);
    
    # menu bar
    $win->add_menu_bar(Name => 'menubar1', Pos => [0,0]);
    
    # menu Edit
    $win->add_menu(Name => 'menu_edit', Title => '_Edit', Menubar => 'menubar1');
    
    # menu tearoff
    $win->add_menu_item(Name => 'menu_item_toff', Type => 'tearoff', 
                        Menu => 'menu_edit', Tip => 'This is a tearoff');
    # menu item Save
    $win->add_menu_item(Name => 'menu_item_save', Icon => 'gtk-save', 
                        Menu => 'menu_edit', Tip => 'This is the Save entry');
    # separator
    $win->add_menu_item(Name => 'menu_item_sep1', Type => 'separator', Menu => 'menu_edit');
    # icon
    $win->add_menu_item(Name => 'menu_item_icon', Title => 'Burger', 
                        Icon => './burger.png', Menu => 'menu_edit', Tip => 'This is the Burger');
    # check menu
    $win->add_menu_item(Name => 'menu_item_check', Type => 'check', 
                        Title => 'Check em', Menu => 'menu_edit', 
                        Tip => 'This is Check menu', Active => 1);
    # radio menu
    $win->add_menu_item(Name => 'menu_item_radio1', Type => 'radio', 
                        Title => 'First', Menu => 'menu_edit', 
                        Tip => 'First radio', Group => 'Yeah', Active => 1);
    $win->add_menu_item(Name => 'menu_item_radio2', Type => 'radio', 
                        Title => 'Second', Menu => 'menu_edit', 
                        Tip => 'Second radio', Group => 'Yeah');
    $win->add_menu_item(Name => 'menu_item_radio3', Type => 'radio', 
                        Title => '_Third', Menu => 'menu_edit', 
                        Tip => 'Third radio', Group => 'Yeah');
    
    
    # menu Help
    $win->add_menu(Name => 'menu_help', Title => '_Help', 
                   Justify => 'right', Menubar => 'menubar1');
    # menu item About
    $win->add_menu_item(Name => 'menu_item_about', Icon => 'gtk-help', 
                        Menu => 'menu_help', Tip => 'This is the About dialog', 
                        Sens => 0);
    
    $win->show_all();

=head1 DESCRIPTION

SimpleGtk2 is a wrapper.

=head1 GTK+ WIDGETS AND OBJECTS

In this seection all supported widgets and objects with their functions
are described.

=head1 B<Toplevel>

Window which can contain other widgets. It contains by default a fixed
container in a scrollable window widget. So whether it is resized
smaller than defined vertical and/or horizontal scrollbars appear.

=head2 B<new_window()>

Creates a new GtkWindow, which is a toplevel window that can contain
other widgets.

I<Parameters:>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the window. Must be a unique name.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    Title of the window (displayed in the title bar).

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    I<Optional>. Size of the window.

B<Fixed> B<=E<gt>> B<E<lt>0/1E<gt>>
    I<Optional>. Window has a fixed size (not resizable). Default: 0
(resizable).

B<Iconpath> B<=E<gt>> B<"E<lt>icon_pathE<gt>">
    I<Optional>. Path to an icon shown in title bar or on iconify
state.

B<ThemeIcon> B<=E<gt>> B<"E<lt>theme_icon_nameE<gt>">
    I<Optional>. Icon name from current theme shown in title bar or on
iconify state.

I<Returns:> A new GtkWindow object.

I<Example:>
    my $win = SimpleGtk2-E<gt>new_window(Name =E<gt> `mainWindow',
                                         Title =E<gt> `testem-all',
                                         Size =E<gt> [400, 400],
                                         ThemeIcon =E<gt> `emblem-dropbox-syncing');

=head1 B<Message> B<Dialog>

A dialog with an image representing the type of message (Error,
Question, etc.) alongside some message text.

=head2 B<add_msg_dialog()>

Creates a new GtkMessageDialog object.

I<Parameters:>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the message dialog. Must be a unique name.

B<Modal> B<=E<gt>> B<E<lt>0/1E<gt>>
    I<Optional>. Sets the dialog modal (default) or nonmodal (1).

B<DType|DialogType> B<=E<gt>> B<"E<lt>dialog_typeE<gt>">
    Prebuilt sets of buttons. Default: I<none>. Else I<okE<gt>, I<closeE<gt>,
I<cancelE<gt>, I<yes-no> or I<ok-cancel>.

B<MTyp|MessageType> B<=E<gt>> B<"E<lt>message_typeE<gt>">
    The type of message icon being displayed: I<infoE<gt>, I<warningE<gt>,
I<questionE<gt>, I<error> or I<other>.

B<Icon> B<=E<gt>> B<"E<lt>path|stock|nameE<gt>">
    I<Optional>. Path of an icon, stock id or icon name as message
icon being displayed.

B<RFunc|ResponseFunction> B<=E<gt>> B<"E<lt>response_functionE<gt>">
    Function being used for response evaluation. Have to be set if 
nonmodal (Modal => 0) is chosen.

I<Returns:> None.

=head2 B<show_msg_dialog()>

Shows a created GtkMessageDialog or a simple (modal) one.

B<Simple:>
    B<show_msg_dialog("E<lt>message_typeE<gt>",> B<"E<lt>dialog_typeE<gt>",> B<"E<lt>message_textE<gt>")>

I<Parameters:>

B<"E<lt>message_typeE<gt>">
    The type of message icon being displayed: I<info, warning, question, error.>

B<"E<lt>dialog_typeE<gt>">
    Prebuilt sets of buttons: I<ok, close, cancel, yes-no or ok-cancel.>

B<"E<lt>message_textE<gt>">
    Sets the dialog message. It can be normal text or Pango markup
string.

B<For> B<user> B<defined> B<dialog:>
    B<show_msg_dialog("E<lt>nameE<gt>",> B<"E<lt>message1E<gt>",> B<"E<lt>message2E<gt>")>

I<Parameters:>

B<"E<lt>nameE<gt>">
    Name of the message dialog. Must be a unique name.

B<"E<lt>message1E<gt>">
    Sets the first dialog message. It can be normal text or Pango
markup string.

B<"E<lt>message2E<gt>">
    I<Optional>. Sets the second dialog message. It can be normal text
or Pango markup string.

I<Returns:> ok, close, cancel, yes, no - depending on the pressed button.

I<Example:>
    use SimpleGtk2;

    sub nonModal{
        my $response = shift;
        if ($response eq `yes') {print "Yes\n";}
        else {print "No\n";}
    }
    
    sub Modal {
        my $window = shift;
        my $response = $window->show_msg_dialog('diag1', "Message Type", "Warning");
        if ($response eq `ok') {print "Ok\n";}
        else {print "Cancel\n";}
    }
    
    sub Simple {
        my $window = shift;
        my $response = $window->show_msg_dialog('warning', `yes-no', "This is a simple one");
        print ucfirst($response) . "\n";
    }

    # Toplevel window
    my $win = SimpleGtk2->new_window(Type => `toplevel', Name => `mainWindow', Title => `Message Test', Size => [200, 160]);
    
    # Button 1 for modal message dialog
    $win->add_button(Name => `Button1', Pos => [60, 10], Size => [80, 40], Title => "_Modal");
    $win->add_signal_handler('Button1', `clicked', sub{\&Modal($win);});
    
    # Modal message dialog
    $win->add_msg_dialog(Name => `diag1', DType => `ok-cancel', MType => `warning', Icon => `gtk-quit');
    
    # messages for non-modal message dialog
    my $FirstMsg = "E<lt>span foreground=\"blue\" size=\"x-large\">Message Type</span>";
    my $SecondMsg = "E<lt>span foreground='red' size=\"small\" style ='italic'>Info box.</span>";
    
    # Button 2 for non-modal message dialog
    $win->add_button(Name => `Button2', Pos => [60, 60], Size => [80, 40], Title => "_NonModal");
    $win->add_signal_handler('Button2', `clicked', sub{$win->show_msg_dialog('diag2', $FirstMsg, $SecondMsg);});
    
    # Non-modal message dialog
    $win->add_msg_dialog(Name => `diag2', DType => `yes-no', MType => `info', RFunc => \&nonModal, Modal => 0);
    
    # Button 3 for a simple but modal message dialog
    $win->add_button(Name => `Button3', Pos => [60, 110], Size => [80, 40], Title => "_Simple");
    $win->add_signal_handler('Button3', `clicked', sub{\&Simple($win);});
    
    $win->show_all();

=head1 GtkImage

A widget displaying an image. It is possible to bind a left click
action to the image. Also a tooltip is possible.

=head2 B<add_image()>

Creates a new GtkImage widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the image. Must be a unique name.

B<Path> B<=E<gt>> B<"E<lt>file_pathE<gt>">
    Path of an image to show.

B<Pixbuf|Pixbuffer> B<=E<gt>> B<E<lt>pix_buffer_objectE<gt>>
    Pixbuffer object of an image to show.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    Size of the image. It will be scaled if bigger/smaller.

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
image area.

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    # with pixbuf object
    my $pixbuf = Gtk2::Gdk::Pixbuf-E<gt>new_from_file("./myimage.png");
    $win-E<gt>add_image(Name =E<gt> `image2',
                        Pos =E<gt> [240, 100],
                        Size =E<gt> [50, 50],
                        Tip =E<gt> `A second picture',
                        Frame =E<gt> `frame1',
                        Pixbuf =E<gt> $pixbuf);
    $win-E<gt>add_signal_handler('image2', `button_press_event', \&Maximize);

=head2 B<get_image()>

object = B<get_image(E<lt>nameE<gt>,> B<[E<lt>keyE<gt>])>

Returns the current Gtk2::Image object if no key is given. Else an
object or path depending to the key.

I<Possible> I<keys:>

B<"Path">
    Current path of the image.

B<"Image">
    Current Gtk2::Image object of the image.

B<"Pixbuf"|"Pixbuffer">
    Current Gtk2::Gdk::Pixbuf object of the image.

=head2 B<set_image()>

B<set_image(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on the widget I<name> .

I<Possible> I<parameters:>

B<Path> B<=E<gt>> B<"E<lt>image_pathE<gt>">
    Path of the new image.

B<Pixbuf|Pixbuffer> B<=E<gt>> B<"E<lt>pix_buffer_objectE<gt>">
    A Gtk2::Gdk::Pixbuf object of a new image.

B<Image> B<=E<gt>> B<"E<lt>image_objectE<gt>">
    A Gtk2::Image object of a new image.

=head2 B<more_functions()>

Available for the image object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkLabel

A widget that displays a small to medium amount of text.

=head2 B<add_label()>

Creates a new GtkLabel widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the label. Must be a unique name.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    Title of the label.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Widget> B<=E<gt>> B<"E<lt>name_of_linked_widgetE<gt>">
    I<Optional>. If used underlined the refferenced widget name.

B<Justify> B<=E<gt>> B<"E<lt>justifyE<gt>">
    I<Optional>. Justification of the text: I<left,> I<right,> I<center,> I<fill>.

B<Wrap|Wrapped> B<=E<gt>> B<E<lt>0/1E<gt>>
    I<Optional>. Wrapping of the text. Only useful in a frame.

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    $win-E<gt>add_label(Name =E<gt> `label1',
                        Pos =E<gt> [10, 20],
                        Title =E<gt> "A Label.\n"."A new line",
                        Justify =E<gt> `left');

=head2 B<get_value()>

string/value = B<get_value(E<lt>nameE<gt>,> B<E<lt>keyE<gt>)>

Returns the current string/value of the label I<name> depending on the
given key or I<undef>.

I<Possible> I<keys:>

B<"Justify">
    Returns the justification of the label.

B<"Wrap"|"Wrapped">
    Returns whether lines in the label are automatically wrapped.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on the label I<name> depending on the given parameter.

I<Possible> I<parameters:>

B<Justify> B<=E<gt>> B<"E<lt>justifyE<gt>">
    Sets the justification of the text: I<left,> I<right,> I<center,> I<fill>.

B<Wrap|Wrapped> B<=E<gt>> B<E<lt>0/1E<gt>>
    Sets the wrapping of the text.

=head2 B<more_functions()>

Available for the label object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   string = B<get_title(E<lt>nameE<gt>)>

=item *   B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkButton

A widget that creates a signal when clicked on.

=head2 B<add_button()>

Creates a new GtkButton widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the button. Must be a unique name.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    Title of the button.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    I<Optional>. Size of the button. Default is 80x25.

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    $win-E<gt>add_button(Name =E<gt> `closeButton',
                         Pos =E<gt> [10, 45],
                         Title =E<gt> "_Close",
                         Tip =E<gt> `Closes the Application',
                         Frame =E<gt> `frame2');
    $win-E<gt>add_signal_handler('closeButton', `clicked', sub{Gtk2-E<gt>main_quit;});

=head2 B<more_functions()>

Available for the button object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

=item *   string = B<get_title(E<lt>nameE<gt>)>

=item *   B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.



=head1 GtkLinkButton

Create buttons bound to a URL.

=head2 B<add_button()>

Creates a new GtkLinkButton widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the link button. Must be a unique name.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    Title of the link button.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    I<Optional>. Size of the link button.

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Uri> B<=E<gt>> B<"E<lt>uri-textE<gt>">
    A valid URI. It is the tooltip as well and will be shown while 
hovering over the widget.

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    $win-E<gt>add_link_button(Name =E<gt> `linkButton',
                              Pos =E<gt> [10, 45],
                              Title =E<gt> "To SimpleGtk2 site",
                              Uri =E<gt> `https://github.com/ThomasFunk/SimpleGtk2',
                              Frame =E<gt> `frame2');
    $win-E<gt>add_signal_handler('closeButton', `clicked',
                                [\&openPage, $win-E<gt>get_value('linkButton', 'Uri')]);

=head2 B<get_value()>

state = B<get_value(E<lt>nameE<gt>,> B<"Uri")>

Returns the current uri of the link button I<name>.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<"Uri"> B<=E<gt>> B<"E<lt>uri-textE<gt>")>

Sets a new uri on the link button I<name>.

=head2 B<more_functions()>

Available for the link button object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

=item *   string = B<get_title(E<lt>nameE<gt>)>

=item *   B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.





=head1 GtkCheckButton

Create widgets with a discrete toggle button.

=head2 B<add_check_button()>

Creates a new GtkCheckButton widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the check button. Must be a unique name.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    Title of the check button.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Active> B<=E<gt>> B<E<lt>0/1E<gt>>
    Sets the status of the check button. 0 = False, 1 = True.
Default: 0

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    $win-E<gt>add_check_button(Name =E<gt> `checkButton1',
                               Pos =E<gt> [80, 20],
                               Title =E<gt> `Check button',
                               Tip =E<gt> `This is a checkbox',
                               Sig =E<gt> `toggled',
                               Func =E<gt> []\&DeleteFile, 'bla.txt']);

=head2 B<is_active()>

state = B<is_active(E<lt>nameE<gt>)>

Returns the current state of the check button I<name>.

=head2 B<get_value()>

state = B<get_value(E<lt>nameE<gt>,> B<"Active")>

Returns the current state of the check button I<name>.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Active> B<=E<gt>> B<E<lt>0/1E<gt>)>

Sets a new state on the check button I<name>.

=head2 B<more_functions()>

Available for the check button object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   string = B<get_title(E<lt>nameE<gt>)>

=item *   B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkRadioButton

A choice from multiple check buttons.

=head2 B<add_radio_button()>

Creates a new GtkRadioButton widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the radio button. Must be a unique name.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    Title of the radio button.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Group> B<=E<gt>> B<"E<lt>group_nameE<gt>">
    Name of the button group the widget is associated to. Must be
unique.

B<Active> B<=E<gt>> B<E<lt>0/1E<gt>>
    Sets the status of the radio button. Only one in the group can
be set to 1! Default: 0

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    # Group of 3 Radio Buttons
    $win-E<gt>add_radio_button(Name =E<gt> `radio1', Pos =E<gt> [10, 90],
                               Title =E<gt> "First", Group =E<gt> "lol",
                               Active =E<gt> 1, Tip =E<gt> "1st radio button",
                               Frame =E<gt> `frame1');
    $win-E<gt>add_radio_button(Name =E<gt> `radio2', Pos =E<gt> [10, 110],
                               Title =E<gt> "_Second", Group =E<gt> "lol",
                               Tip =E<gt> "2nd radio button", Frame =E<gt> `frame1');
    $win-E<gt>add_radio_button(Name =E<gt> `radio3', Pos =E<gt> [10, 130],
                               Title =E<gt> "Third", Group =E<gt> "lol",
                               Tip =E<gt> "3rd radio button", Frame =E<gt> `frame1');

=head2 B<get_group()>

group/group_name = B<get_group(E<lt>nameE<gt>,> B<["Name"])>

Returns the current group object or name of the group if "Name" is
given from the radio button I<name>.

=head2 B<set_group()>

B<set_group(E<lt>nameE<gt>,> B<E<lt>group/group_nameE<gt>)>

Sets a new group on the radio button I<name>. It can be used an existing
group object or group name.

=head2 B<is_active()>

state = B<is_active(E<lt>nameE<gt>)>

Returns the current state of the radio button I<name>.

=head2 B<get_value()>

state = B<get_value(E<lt>nameE<gt>,> B<"Active")>

Returns the current state of the radio button I<name>.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Active> B<=E<gt>> B<E<lt>0/1E<gt>)>

Sets a new state on the radio button I<name>.

=head2 B<more_functions()>

Available for the check button object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>name/groupE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   string = B<get_title(E<lt>nameE<gt>)>

=item *   B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkEntry

A single line text entry field.

=head2 B<add_entry()>

Creates a new GtkEntry widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the entry. Must be a unique name.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    I<Optional>. Text in the entry field.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    Size of the entry field.

B<Align> B<=E<gt>> B<"E<lt>xalignE<gt>">
    I<Optional>. Sets the alignment for the contents of the entry:
left (default), right.

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    $win-E<gt>add_entry(Name =E<gt> `entry1',
                        Pos =E<gt> [200, 20],
                        Size =E<gt> [100, 20],
                        Title =E<gt> `A text entry field',
                        Align =E<gt> `right');

=head2 B<get_value()>

string = B<get_value(E<lt>nameE<gt>,> B<"Align")>

Returns the current alignment string of the entry I<name>.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Align> B<=E<gt>> B<"E<lt>xalignE<gt>")>

Sets a new alignment on the entry I<name>.

=head2 B<more_functions()>

Available for the check button object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   string = B<get_title(E<lt>nameE<gt>)>

=item *   B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkSlider

A horizontal/vertical slider widget for selecting a value from a range
known as GtkHScale/GtkVScale.

=head2 B<add_slider()>

Creates a new GtkSlider widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the slider. Must be a unique name.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    I<Optional>. Size of the slider.

B<Orient|Orientation> B<=E<gt>> B<"E<lt>orientationE<gt>">
    The orientation of the slider (horizontal, vertical).

B<Start> B<=E<gt>> B<E<lt>start_valueE<gt>>
    I<Optional>. The initial start value. Default: 0.0 (double).

B<Min|Minimum> B<=E<gt>> B<E<lt>min_valueE<gt>>
    The minimum value (double).

B<Max|Maximum> B<=E<gt>> B<E<lt>max_valueE<gt>>
    The maximum value (double).

B<Step> B<=E<gt>> B<E<lt>step_in/decreaseE<gt>>
    The step increment (double).

B<DrawValue> B<=E<gt>> B<E<lt>1/0E<gt>>
    I<Optional>. Specifies whether the current value is displayed as a
    string next to the slider.

B<ValuePos|ValuePosition> B<=E<gt>> B<"E<lt>value_positionE<gt>">
    I<Optional>. Sets the position in which the current value is
displayed. Default: top. Others: left, right, bottom.

B<Digits> B<=E<gt>> B<E<lt>used_digitsE<gt>>
    I<Optional>. Number of decimal places the value will be displayed.
    Default: 0 (1 digit).

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

I<Returns:> None.

I<Example:>
    # Horizontal
    $win-E<gt>add_slider(Name =E<gt> `hslider',
                         Pos =E<gt> [10, 220],
                         Size =E<gt> [200, -1],
                         Orient =E<gt> `horizontal',
                         Start =E<gt> 5,
                         Min =E<gt> 0,
                         Max =E<gt> 100,
                         Step =E<gt> 0.1,
                         Digits =E<gt> 1,
                         Tip =E<gt> `Round and round we go',
                         Frame =E<gt> `frame2');

=head2 B<get_value()>

string/value = B<get_value(E<lt>nameE<gt>,> B<E<lt>keyE<gt>)>

Returns the current string/value of the slider I<name> depending on the
given key or I<undef>.

I<Possible> I<keys:>

B<"Active">
    Returns the current active value of the slider.

B<"Min"|"Minimum">
    Returns the minimum value of the slider.

B<"Max"|"Maximum">
    Returns the maximum value of the slider.

B<"Step">
    Returns the current step increment of the slider.

B<"DrawValue">
    Returns the current active value as a string of the slider.

B<"ValuePos"|"ValuePosition">
    Returns the position in which the current value is displayed.

B<"Digits">
    Number of decimal places the value is displayed.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on the slider I<name> depending on the given parameter.

I<Possible> I<parameters:>

B<Start> B<=E<gt>> B<E<lt>start_valueE<gt>>
    Sets a new start value.

B<Active> B<=E<gt>> B<E<lt>active_valueE<gt>>
    Sets a new active value.

B<Min|Minimum> B<=E<gt>> B<E<lt>min_valueE<gt>>
    Sets a new minimum value.

B<Max|Maximum> B<=E<gt>> B<E<lt>max_valueE<gt>>
    Sets a new maximum value.

B<Step> B<=E<gt>> B<E<lt>step_in/decreaseE<gt>>
    Sets a new step increment.

B<DrawValue> B<=E<gt>> B<E<lt>1/0E<gt>>
    Specifies whether the current value is displayed as a string
    next to the slider.

B<ValuePos|ValuePosition> B<=E<gt>> B<"E<lt>value_positionE<gt>">
    Sets a new position in which the current value is displayed.

B<Digits> B<=E<gt>> B<E<lt>used_digitsE<gt>>
    Sets a new number of decimal places the value will be
    displayed.

=head2 B<set_values()>

B<set_values(E<lt>nameE<gt>,> B<Param_x> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<Param_y> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<...)>

Sets a bunch of new values on the slider I<name> depending on the given
parameters.

This is useful to reinitialize the adjustment (Start, Minimum, Maximum,
Step and Digits).

I<Possible> I<parameters:>
See B<set_value> above.

=head2 B<more_functions()>

Available for the slider object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkSpinButton

Retrieve an integer or floating-point number from the user.

=head2 B<add_spin_button()>

Creates a new GtkSpinButton widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the spin button. Must be a unique name.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    I<Optional>. Size of the spin button.

B<Start> B<=E<gt>> B<E<lt>start_valueE<gt>>
    I<Optional>. The initial start value. Default: 0.0 (double).

B<Min|Minimum> B<=E<gt>> B<E<lt>min_valueE<gt>>
    The minimum value (double).

B<Max|Maximum> B<=E<gt>> B<E<lt>max_valueE<gt>>
    The maximum value (double).

B<Step> B<=E<gt>> B<E<lt>step_in/decreaseE<gt>>
    The step increment (double).

B<Snap> B<=E<gt>> B<E<lt>0/1E<gt>>
    I<Optional>. Sets the policy as to whether values are corrected to
the nearest step increment when an invalid value is provided.

B<Align> B<=E<gt>> B<"E<lt>alignE<gt>">
    I<Optional>. Sets the alignment for the contents of the spin
button: left (default), right.

B<Rate|Climbrate> B<=E<gt>> B<E<lt>climb_rateE<gt>>
    I<Optional>. Sets the amount of acceleration that the spin button
    has (0.0 to 1.0). Default: 0.0

B<Digits> B<=E<gt>> B<E<lt>used_digitsE<gt>>
    I<Optional>. Number of decimal places the value will be displayed.
    Default: 0 (1 digit).

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

Per default I<value-changed> is set to update value immediatelly.

I<Returns:> None.

I<Example:>
    $win-E<gt>add_spin_button(Name =E<gt> `spin1',
                              Pos =E<gt> [10, 60],
                              Start =E<gt> 5,
                              Min =E<gt> 0,
                              Max =E<gt> 10,
                              Step =E<gt> 1,
                              Tip =E<gt> `Thats a spin button',
                              Align =E<gt> `right',
                              Frame =E<gt> `frame1');

=head2 B<get_value()>

string/value = B<get_value(E<lt>nameE<gt>,> B<E<lt>keyE<gt>)>

Returns the current string/value of the spin button I<name> depending on
the given key or I<undef>.

I<Possible> I<keys:>

B<"Active">
    Returns the current active value of the spin button.

B<"Align">
    Returns the alignment for the contents of the spin button.

B<"Min"|"Minimum">
    Returns the minimum value of the spin button.

B<"Max"|"Maximum">
    Returns the maximum value of the spin button.

B<"Step">
    Returns the step increment of the spin button.

B<"Snap">
    Returns whether the values are corrected to the nearest step.

B<"Rate"|"Climbrate">
    Returns the amount of acceleration that the spin button
    actually has.

B<"Digits">
    Number of decimal places the value is displayed.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on the spin button I<name> depending on the given
parameter.

I<Possible> I<parameters:>

B<Start> B<=E<gt>> B<E<lt>start_valueE<gt>>
    Sets a new start value.

B<Active> B<=E<gt>> B<E<lt>active_valueE<gt>>
    Sets a new active value.

B<Min|Minimum> B<=E<gt>> B<E<lt>min_valueE<gt>>
    Sets a new minimum value.

B<Max|Maximum> B<=E<gt>> B<E<lt>max_valueE<gt>>
    Sets a new maximum value.

B<Step> B<=E<gt>> B<E<lt>step_in/decreaseE<gt>>
    Sets a new step increment.

B<Snap> B<=E<gt>> B<E<lt>1/0E<gt>>
    Sets the policy as to whether values are corrected to the
    nearest step increment when an invalid value is provided.

B<Rate|Climbrate> B<=E<gt>> B<E<lt>climb_rateE<gt>>
    Sets a new amount of acceleration that the spin button shall
    has.

B<Digits> B<=E<gt>> B<E<lt>used_digitsE<gt>>
    Sets a new number of decimal places the value will be
    displayed.

=head2 B<set_values()>

B<set_values(E<lt>nameE<gt>,> B<Param_x> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<Param_y> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<...)>

Sets a bunch of new values on the spin button I<name> depending on the
given parameters.

This is useful to reinitialize the adjustment (Start, Minimum, Maximum,
Step, Climbrate and Digits).

I<Possible> I<parameters:>
See B<set_value> above.

=head2 B<more_functions()>

Available for the spin button object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkTextView

Widget that displays a GtkTextBuffer.

=head2 B<add_text_view()>

Creates a new GtkTextView widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the text view. Must be a unique name.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    Size of the text view.

B<Path> B<=E<gt>> B<"E<lt>file_pathE<gt>">
    Path to the text file.

B<Textbuf|Textbuffer> B<=E<gt>> B<"E<lt>text_buffer_objectE<gt>">
    Sets the buffer being displayed by the text view.

B<LeftMargin> B<=E<gt>> B<E<lt>in_pixelE<gt>>
    I<Optional>. Sets the default left margin for text in the text
    view. Default: 0.

B<RightMargin> B<=E<gt>> B<E<lt>in_pixelE<gt>>
    I<Optional>. Sets the default right margin for text in the text
    view. Default: 0.

B<Wrap|Wrapped> B<=E<gt>> B<"E<lt>wrap_modeE<gt>">
    I<Optional>. Sets the line wrapping for the view. Default: left
(right, center, fill).

B<Justify> B<=E<gt>> B<"E<lt>justifyE<gt>">
    I<Optional>. Sets the default justification of text in text_view .
Default: none (char, word, word-char).

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    # with file
    $win-E<gt>add_text_view(Name =E<gt> `tview1',
                            Pos =E<gt> [40, 260],
                            Size =E<gt> [200, 120],
                            Tip =E<gt> `A text',
                            Frame =E<gt> `frame2',
                            Path =E<gt> `./testem.txt',
                            Wrapped =E<gt> `char',
                            LeftMargin =E<gt> 10,
                            RightMargin =E<gt> 10);

=head2 B<get_textview()>

object/path = B<get_textview(E<lt>nameE<gt>,> B<[E<lt>keyE<gt>])>

Returns the current text view object of the text view I<name> if no key is
given. Else an object/path depending on the given key or I<undef>.

I<Possible> I<keys:>

B<"Path">
    Returns the path of the text file.

B<"Textview">
    Returns the text view object.

B<"Textbuf"|"Textbuffer">
    Returns the text buffer object.

=head2 B<set_textview()>

B<set_textview(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on the text view I<name> depending on the given
parameter.

I<Possible> I<parameters:>

B<Path> B<=E<gt>> B<"E<lt>pathE<gt>">
    Sets a path to a new text file.

B<Textbuf|Textbuffer> B<=E<gt>> B<E<lt>text_buffer_objectE<gt>>
    Sets a new buffer with content being displayed by the text
    view.

=head2 B<get_value()>

string/value = B<get_value(E<lt>nameE<gt>,> B<E<lt>keyE<gt>)>

Returns the current string/value of the text view I<name> depending on the
given key or I<undef>.

I<Possible> I<keys:>

B<"LeftMargin">
    Returns the left margin size of paragraphs in the text view.

B<"RightMargin">
    Returns the right margin size of paragraphs in the text view.

B<"Wrap"|"Wrapped">
    Returns the current wrap mode.

B<"Justify">
    Returns the justification of the text view.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on the text view I<name> depending on the given
parameter.

I<Possible> I<parameters:>

B<LeftMargin> B<=E<gt>> B<E<lt>in_pixelE<gt>>
    Sets the default left margin for text in the text view.

B<RightMargin> B<=E<gt>> B<E<lt>in_pixelE<gt>>
    Sets the default right margin for text in the text view.

B<Wrap|Wrapped> B<=E<gt>> B<"E<lt>wrap_modeE<gt>">
    Sets the line wrapping for the view.

B<Justify> B<=E<gt>> B<"E<lt>justifyE<gt>">
    Sets the default justification of text in text_view.

=head2 B<set_values()>

B<set_values(E<lt>nameE<gt>,> B<Param_x> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<Param_y> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<...)>

Sets a bunch of new values on the text view I<name> depending on the given
parameters.

I<Possible> I<parameters:>
See B<set_value> above.

=head2 B<more_functions()>

Available for the text view object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 B<Tree> B<and> B<List> B<Widgets>

blaa balll

=head1 GtkComboBox

A widget used to choose from a list of items.

=head2 B<add_combo_box()>

Creates a new GtkComboBox widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the combo box. Must be a unique name.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    I<Optional>. Size of the combo box.

B<Data> B<=E<gt>> B<[E<lt>Array_of_valuesE<gt>]>
    Array of values/strings being displayed in the combo box.

B<Start> B<=E<gt>> B<"E<lt>start_at_indexE<gt>">
    I<Optional>. Sets the active item of the combo box to be the item
at index. Default: 0.

B<Columns> B<=E<gt>> B<E<lt>wrap_list_to_x_columnsE<gt>>
    I<Optional>. Sets the number of columns to display.

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    $win-E<gt>add_combo_box(Name =E<gt> `combo1',
                            Pos =E<gt> [100, 60],
                            Data =E<gt> ['one', `two', `three', `four'],
                            Start =E<gt> 1,
                            Tip =E<gt> `Jup',
                            Frame =E<gt> `frame1');

=head2 B<is_active()>

state = B<is_active(E<lt>nameE<gt>,> B<E<lt>value/string>)>

Returns the state whether a given value/string is current active in
combo box I<name>.

=head2 B<get_value()>

string/value = B<get_value(E<lt>nameE<gt>,> B<E<lt>keyE<gt>)>

Returns the current string/value of the combo box I<name> depending on the
given key or I<undef>.

I<Possible> I<keys:>

B<"Active">
    Returns the current index of active value.

B<"Data">
    Returns the data array of the combo box.

B<"Columns">
    Returns the current number of columns to display.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on the text view I<name> depending on the given
parameter.

I<Possible> I<parameters:>

B<Active> B<=E<gt>> B<"E<lt>active_indexE<gt>">
    Sets the active item of the combo box to be the item at index.

B<Data> B<=E<gt>> B<[E<lt>Array_of_valuesE<gt>]>
    Sets a new array of values/strings being displayed in the combo
box.

B<Columns> B<=E<gt>> B<E<lt>wrap_list_to_x_columnsE<gt>>
    Sets the number of columns to display.

=head2 B<set_values()>

B<set_values(E<lt>nameE<gt>,> B<Param_x> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<Param_y> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<...)>

Sets a bunch of new values on the combo box I<name> depending on the given
parameters.

I<Possible> I<parameters:>
See B<set_value> above.

=head2 B<get_title()>

string = B<get_title(E<lt>nameE<gt>)>

Returns the current active string of the combo box I<name>.

=head2 B<set_title()>

B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

Set the given text as current active item if available.

=head2 B<more_functions()>

Available for the combo box object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkMenuBar

A menu bar widget for holding menus.

=head2 B<add_menu_bar()>

Creates a new GtkMenuBar widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the menu bar. Must be a unique name.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    I<Optional>. Size of the menu bar. Default is complete window
width.

I<Returns:> None.

I<Example:>
    $win-E<gt>add_menu_bar(Name =E<gt> `menubar1', Pos =E<gt> [0,0]);

=head2 B<get_pos()>

(x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

Returns the current position (in pixel) of the menu bar I<name> in the
window/frame/page.

=head2 B<set_pos()>

B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

Sets a new position (in pixel) to the menu bar I<name> at I<new>B<_>I<x> and I<new>B<_>I<y>.

=head2 B<get_size()>

(width, height) = B<get_size(E<lt>nameE<gt>)>

Returns the current width and height (in pixel) of the menu bar I<name>.

=head2 B<set_size()>

B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

Sets the new width and height (in pixel) of the menu bar I<name> at
I<new>B<_>I<width> and I<new>B<_>I<height>.

=head2 B<more_functions()>

Available for the menu bar object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkMenu

A menu widget used for holding menu item widgets.

=head2 B<add_menu()>

Creates a new GtkMenu widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the menu. Must be a unique name.

B<Menubar> B<=E<gt>> B<"E<lt>menu_bar_nameE<gt>">
    Name of the menu bar which shall hold the menu.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    Title of the menu.

B<Justify> B<=E<gt>> B<"E<lt>justifyE<gt>">
    I<Optional>. Justification of the text: left (default), right.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    $win-E<gt>add_menu(Name =E<gt> `menu_help', Title =E<gt> `_Help', 
                       Justify =E<gt> `right', Menubar =E<gt> `menubar1');

=head2 B<get_value()>

string = B<get_value(E<lt>nameE<gt>,> B<"Justify")>

Returns the current justification of the menu I<name>.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Justify> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new justification on the menu I<name>.

=head2 B<more_functions()>

Available for the menu object:


=over 3

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   string = B<get_title(E<lt>nameE<gt>)>

=item *   B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkMenuItem

The widget used for item in menus.

=head2 B<add_menu_item()>

Creates a new GtkMenuItem widget.

I<Parameters>

B<Type> B<=E<gt>> B<"E<lt>typeE<gt>">
    I<Optional>. Menu item type. Default: Item. Others are: I<tearoff,>
I<radio,> I<check,> I<separator>.

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the menu item. Must be a unique name.

B<Menu> B<=E<gt>> B<"E<lt>menu_nameE<gt>">
    Name of the menu which shall hold the menu item.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    I<Optional>. Title of the menu item. Not usuable for tearoff and
separator.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget. Not available for separator.

B<Icon> B<=E<gt>> B<"E<lt>path|stock|nameE<gt>">
    I<Optional>. Path of an icon, stock id or icon name on a standard
menu item.

B<Group> B<=E<gt>> B<"E<lt>group_nameE<gt>">
    Name of the radio menu group the widget is associated to. Must
be unique.

B<Active> B<=E<gt>> B<E<lt>0/1E<gt>>
    Sets the status of the radio menu. Only one in the group can be
set to 1! Default: 0

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    # menu tearoff
    $win-E<gt>add_menu_item(Name =E<gt> `menu_item_toff', Type =E<gt> `tearoff',
                            Menu =E<gt> `menu_edit', Tip =E<gt> `This is a tearoff');
    # menu item Save
    $win-E<gt>add_menu_item(Name =E<gt> `menu_item_save', Icon =E<gt> `gtk-save',
                            Menu =E<gt> `menu_edit', Tip =E<gt> `This is the Save entry');
    # separator
    $win-E<gt>add_menu_item(Name =E<gt> `menu_item_sep1', 
                            Type =E<gt> `separator', Menu =E<gt> `menu_edit');
    # icon
    $win-E<gt>add_menu_item(Name =E<gt> `menu_item_icon', Title =E<gt> `Burger',
                            Icon =E<gt> `./1.png', Menu =E<gt> `menu_edit',
                            Tip =E<gt> `This is a Burger');
    # check menu
    $win-E<gt>add_menu_item(Name =E<gt> `menu_item_check', Type =E<gt> `check',
                            Title =E<gt> `Check em', Menu =E<gt> `menu_edit',
                            Tip =E<gt> `This is a Check menu', Active =E<gt> 1);
    # radio menu
    $win-E<gt>add_menu_item(Name =E<gt> `menu_item_radio1', Type =E<gt> `radio',
                            Title =E<gt> `First', Menu =E<gt> `menu_edit',
                            Tip =E<gt> `First radio', Group =E<gt> `Yeah', Active =E<gt> 1);
    $win-E<gt>add_menu_item(Name =E<gt> `menu_item_radio2', Type =E<gt> `radio',
                            Title =E<gt> `Second', Menu =E<gt> `menu_edit',
                            Tip =E<gt> `Second radio', Group =E<gt> `Yeah');
    $win-E<gt>add_menu_item(Name =E<gt> `menu_item_radio3', Type =E<gt> `radio',
                            Title =E<gt> `_Third', Menu =E<gt> `menu_edit',
                            Tip =E<gt> `Third radio', Group =E<gt> `Yeah');

=head2 B<get_group()>

group/group_name = B<get_group(E<lt>nameE<gt>,> B<["Name"])>

Returns the current group object or name of the group if "Name" is
given from a radio menu item I<name>.

=head2 B<set_group()>

B<set_group(E<lt>nameE<gt>,> B<E<lt>group/group_nameE<gt>)>

Sets a new group on a radio menu item I<name>. It can be used an existing
group object or group name.

=head2 B<get_value()>

string/state = B<get_value(E<lt>nameE<gt>,> B<E<lt>keyE<gt>)>

Returns the current string/state of a menu item I<name> depending on the
given key or I<undef>.

I<Possible> I<keys:>

B<"IconPath">
    Returns the path of the used icon on a standard menu item or
    undef.

B<"StockIcon">
    Returns the stock id of the used stock icon on a standard menu
    item or undef.

B<"IconName">
    Returns the name of the used theme icon on a standard menu item
    or undef.

B<"Icon">
    Returns the path/stock id/name of the used icon on a standard
    menu item or undef.

B<"Active">
    Returns the current state of a radio menu item.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on a menu item I<name> depending on the given parameter.

I<Possible> I<parameters:>

B<Icon> B<=E<gt>> B<"E<lt>path|stock|nameE<gt>">
    Sets path of an icon, stock id or icon name on a standard menu
item.

B<Active> B<=E<gt>> B<E<lt>0/1E<gt>>
    Sets a new state on a radio menu item.

=head2 B<more_functions()>

Available for the menu item object:


=over 3

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>name/groupE<gt>,> B<E<lt>stateE<gt>)>

=item *   string = B<get_title(E<lt>nameE<gt>)>

=item *   B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkNotebook

A tabbed notebook container.

=head2 B<add_notebook()>

Creates a new GtkNotebook container.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the notebook. Must be a unique name.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    I<Optional>. Size of the notebook.

B<Tabs> B<=E<gt>> B<"E<lt>positionE<gt>">
    I<Optional>. Sets the edge at which the tabs for switching pages
are drawn. Default: top (left, right, bottom, none)

B<Scroll|Scrollable> B<=E<gt>> B<E<lt>0/1E<gt>>
    I<Optional>. Sets whether the tab label area will have arrows for
scrolling. Default: 1.

B<Popup> B<=E<gt>> B<E<lt>0/1E<gt>>
    I<Optional>. Enables a popup menu: if the user clicks with right
mouse button on the tab labels, a menu with all the pages will
be popped up. Default: 0.

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    $win-E<gt>add_notebook(Name =E<gt> `NB1',
                           Pos =E<gt> [10, 10],
                           Size =E<gt> [200, 200],
                           Tabs =E<gt> `top',
                           Scroll =E<gt> 1,
                           Popup =E<gt> 1);

=head2 B<get_value()>

string/value = B<get_value(E<lt>nameE<gt>,> B<E<lt>keyE<gt>)>

Returns the current string/value of the notebook I<name> depending on the
given key or I<undef>.

I<Possible> I<keys:>

B<"Current"|"CurrentPage">
    Returns the page number of the current page.

B<"Pages">
    Returns the number of pages in the notebook.

B<"Popup">
    Returns 1 whether the popup is activated. Else 0.

B<"No2Name"|"Number2Name">
    get page name with the page number.

B<"Scroll"|"Scrollable">
    Returns whether the tab label area has arrows for scrolling.

B<"Tabs">
    Returns the edge at which the tabs are drawn or I<none>.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on the notebook I<name> depending on the given parameter.

I<Possible> I<parameters:>

B<Current|CurrentPage> B<=E<gt>> B<E<lt>page_number|next|prevE<gt>>
    Sets the current page.

B<Popup> B<=E<gt>> B<E<lt>0/1E<gt>>
    Enables the popup menu.

B<Scroll|Scrollable> B<=E<gt>> B<E<lt>0/1E<gt>>
    Sets whether the tab label area will have arrows for scrolling.

B<ShowTabs> B<=E<gt>> B<E<lt>0/1E<gt>>
    Sets whether to show the tabs for the notebook or not.

B<Tabs> B<=E<gt>> B<"E<lt>positionE<gt>">
    Sets the edge at which the tabs are drawn.

=head2 B<more_functions()>

Available for the notebook object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkNotebookPage

A notebook page container.

=head2 B<add_nb_page()>

Creates a new GtkNotebookPage container.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the notebook page. Must be a unique name.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    Title of the notebook page.

B<Notebook> B<=E<gt>> B<"E<lt>notebook_nameE<gt>">
    Name of the notebook where the page shall appear. Must be a
unique name.

B<Pos_n|PositionNumber> B<=E<gt>> B<E<lt>0/1E<gt>>
    I<Optional>. Insert a page into the notebook at the given
position.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    # append page
    $win-E<gt>add_nb_page(Name =E<gt> "NB_page3",
                          Title =E<gt> "Page 3",
                          Notebook =E<gt> `NB1',
                          Tip =E<gt> "This is page 3");
    # insert page
    $win-E<gt>add_nb_page(Name =E<gt> "NB_page2",
                          Pos_n =E<gt> 1,
                          Title =E<gt> "Page 2",
                          Notebook =E<gt> `NB1',
                          Tip =E<gt> "This is page 2");

=head2 B<remove_nb_page()>

B<remove_nb_page(E<lt>nb_nameE<gt>,> B<E<lt>title/numberE<gt>)>

Removes a notebook page from notebook I<nb>B<_>I<name> with its title or number.

=head2 B<get_value()>

string/value = B<get_value(E<lt>nameE<gt>,> B<E<lt>keyE<gt>)>

Returns the current string/value of the notebook page I<name> depending on
the given key or I<undef>.

I<Possible> I<keys:>

B<"PageNumber">
    Returns the page number of the notebook page.

B<"Notebook">
    Returns the name of the notebook.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<reorder> B<=E<gt>> B<E<lt>new_positionE<gt>)>

Sets a new value on the notebook page I<name> depending on the given
parameter.

=head2 B<more_functions()>

Available for the notebook page object:


=over 3

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   string = B<get_title(E<lt>nameE<gt>)>

=item *   B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkFrame

A decorative frame with an optional label.

=head2 B<add_frame()>

Creates a new GtkFrame widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the frame. Must be a unique name.

B<Title> B<=E<gt>> B<"E<lt>titleE<gt>">
    I<Optional>. Title of the frame.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    Size of the frame.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

I<Returns:> None.

I<Example:>
    $win-E<gt>add_frame(Name =E<gt> `frame1',
                        Pos =E<gt> [5, 5],
                        Size =E<gt> [390, 190],
                        Title =E<gt> ` A Frame around `);

=head2 B<more_functions()>

Available for the frame object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

=item *   string = B<get_title(E<lt>nameE<gt>)>

=item *   B<set_title(E<lt>nameE<gt>,> B<E<lt>text>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 GtkScrollbar

A horizontal/vertical scrollbar.

=head2 B<add_scrollbar()>

Creates a new GtkScrollbar widget.

I<Parameters>

B<Name> B<=E<gt>> B<"E<lt>nameE<gt>">
    Name of the scrollbar. Must be a unique name.

B<Pos|Position> B<=E<gt>> B<[E<lt>pos_xE<gt>,> B<E<lt>pos_yE<gt>]>
    x- and y-position in the window/frame/page.

B<Size> B<=E<gt>> B<[E<lt>widthE<gt>,> B<E<lt>heightE<gt>]>
    I<Optional>. Size of the slider.

B<Orient|Orientation> B<=E<gt>> B<"E<lt>orientationE<gt>">
    The orientation of the scrollbar (horizontal, vertical).

B<Start> B<=E<gt>> B<E<lt>start_valueE<gt>>
    I<Optional>. The initial start value. Default: 0.0 (double).

B<Min|Minimum> B<=E<gt>> B<E<lt>min_valueE<gt>>
    The minimum value (double).

B<Max|Maximum> B<=E<gt>> B<E<lt>max_valueE<gt>>
    The maximum value (double).

B<Step> B<=E<gt>> B<E<lt>step_in/decreaseE<gt>>
    The step increment (double).

B<Digits> B<=E<gt>> B<E<lt>used_digitsE<gt>>
    I<Optional>. Number of decimal places the value will be displayed.
    Default: 0 (1 digit).

B<Frame> B<=E<gt>> B<"E<lt>frame_nameE<gt>">
    Name of the frame/page where widget is located. Must be unique.

B<Tip|Tooltip> B<=E<gt>> B<"E<lt>tooltip-textE<gt>">
    I<Optional>. Text of the tooltip shown while hovering over the
widget.

B<Sens|Sensitive> B<=E<gt>> B<E<lt>sensitiveE<gt>>
    I<Optional>. Set widget active/inactive. Default: 1 (active).

B<Func|Function> B<=E<gt>> B<E<lt>functionE<gt>>
    I<Optional>. Function reference/sub. Can be set later with
    B<add_signal_handler>. If data is used it have to be set as an array.

B<Sig|Signal> B<=E<gt>> B<"E<lt>signalE<gt>">
    I<Optional>. Signal/event. Only in conjunction with I<Func>.

I<Returns:> None.

I<Example:>
    # Horizontal
    $win-E<gt>add_scroll_bar(Name =E<gt> `hscroll', Pos =E<gt> [10, 220],
                             Size =E<gt> [200, -1], Orient =E<gt> `horizontal',
                             Start =E<gt> 5, Min =E<gt> 0, Max =E<gt> 100, Step =E<gt> 1, Digits =E<gt> 1,
                             Tip =E<gt> `From left to right', Frame =E<gt> `frame2');
    # Vertical
    $win-E<gt>add_scroll_bar(Name =E<gt> `vscroll', Pos =E<gt> [320, 30],
                             Size =E<gt> [-1, 150], Orient =E<gt> `vertical',
                             Start =E<gt> 1.5, Min =E<gt> 0, Max =E<gt> 100, Step =E<gt> 1, Digits =E<gt> 1,
                             Tip =E<gt> `Up and down', Frame =E<gt> `frame1');

=head2 B<add_scrollbar()>

string/value = B<get_value(E<lt>nameE<gt>,> B<E<lt>keyE<gt>)>

Returns the current string/value of the scrollbar I<name> depending on the
given key or I<undef>.

I<Possible> I<keys:>

B<"Active">
    Returns the current active value of the scrollbar.

B<"Min"|"Minimum">
    Returns the minimum value of the scrollbar.

B<"Max"|"Maximum">
    Returns the maximum value of the scrollbar.

B<"Step">
    Returns the current step increment of the scrollbar.

B<"Digits">
    Number of decimal places the value is displayed.

=head2 B<add_scrollbar()>

B<set_value(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on the scrollbar I<name> depending on the given
parameter.

I<Possible> I<parameters:>

B<Start> B<=E<gt>> B<E<lt>start_valueE<gt>>
    Sets a new start value.

B<Active> B<=E<gt>> B<E<lt>active_valueE<gt>>
    Sets a new active value.

B<Min|Minimum> B<=E<gt>> B<E<lt>min_valueE<gt>>
    Sets a new minimum value.

B<Max|Maximum> B<=E<gt>> B<E<lt>max_valueE<gt>>
    Sets a new maximum value.

B<Step> B<=E<gt>> B<E<lt>step_in/decreaseE<gt>>
    Sets a new step increment.

B<Digits> B<=E<gt>> B<E<lt>used_digitsE<gt>>
    Sets a new number of decimal places the value will be
    displayed.

=head2 B<add_scrollbar()>

B<set_values(E<lt>nameE<gt>,> B<Param_x> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<Param_y> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<...)>

Sets a bunch of new values on the scrollbar I<name> depending on the given
parameters.

This is useful to reinitialize the adjustment (Start, Minimum, Maximum,
Step and Digits).

I<Possible> I<parameters:>
See B<set_value> above.

=head2 B<more_functions()>

Available for the scrollbar object:


=over 3

=item *   B<hide_widget(E<lt>nameE<gt>)>

=item *   B<show_widget(E<lt>nameE<gt>)>

=item *   (x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

=item *   B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

=item *   state = B<is_sensitive(E<lt>nameE<gt>)>

=item *   B<set_sensitive(E<lt>nameE<gt>,> B<E<lt>stateE<gt>)>

=item *   (width, height) = B<get_size(E<lt>nameE<gt>)>

=item *   B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

=item *   string = B<get_tooltip(E<lt>nameE<gt>)>

=item *   B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

=back

For more detailed information see section B<COMMON> B<FUNCTIONS>.

=head1 COMMON FUNCTIONS

=head2 B<hide_widget()>

B<hide_widget(E<lt>nameE<gt>)>

Hide the widget I<name>.

Not available for the following widgets: I<GtkMenu,> I<GtkMenuItem,>
I<GtkNotebookPage>

=head2 B<show_widget()>

B<show_widget(E<lt>nameE<gt>)>

Show the widget I<name>.

Not available for the following widgets: I<GtkMenu,> I<GtkMenuItem,>
I<GtkNotebookPage>

=head2 B<get_pos()>

(x_pos, y_pos) = B<get_pos(E<lt>nameE<gt>)>

Returns the current position (in pixel) of the widget I<name> in the
window/frame/page.

Not available for the following widgets: I<GtkMenu,> I<GtkMenuItem,>
I<GtkNotebookPage>

=head2 B<set_pos()>

B<set_pos(E<lt>nameE<gt>,> B<E<lt>new_xE<gt>,> B<E<lt>new_yE<gt>)>

Sets the new position (in pixel) of the widget I<name> at I<new>B<_>I<x> and I<new>B<_>I<y>.

Not available for the following widgets: I<GtkMenu,> I<GtkMenuItem,>
I<GtkNotebookPage>

=head2 B<get_size()>

(width, height) = B<get_size(E<lt>nameE<gt>)>

Returns the current width and height (in pixel) of the widget I<name>.

Not available for the following widgets: I<GtkMenu,> I<GtkMenuItem,>
I<GtkNotebookPage>

=head2 B<set_size()>

B<set_size(E<lt>nameE<gt>,> B<E<lt>new_widthE<gt>,> B<E<lt>new_height>)>

Sets the new width and height (in pixel) of the widget I<name> at
I<new>B<_>I<width> and I<new>B<_>I<height>.

Not available for the following widgets: I<GtkCheckButton,>
I<GtkRadioButton,> I<GtkLabel,> I<GtkMenu,> I<GtkMenuItem,> I<GtkNotebookPage>

=head2 B<get_title()>

string = B<get_title(E<lt>nameE<gt>)>

Returns the current title text of the widget I<name> or I<undef>.

Not available for the following widgets: I<GtkSlider,> I<GtkScrollBar,>
I<GtkImage,> I<GtkTextView,> I<GtkMenuBar,> I<GtkNotebook>

=head2 B<set_title()>

B<set_title(E<lt>nameE<gt>,> B<E<lt>new_titleE<gt>)>

Sets a new title to the widget I<name>.

Not available for the following widgets: I<GtkSlider,> I<GtkScrollBar,>
I<GtkImage,> I<GtkTextView,> I<GtkMenuBar,> I<GtkNotebook>

=head2 B<get_tooltip()>

string = B<get_tooltip(E<lt>nameE<gt>)>

Returns the current tooltip text of the widget I<name> or I<undef>.

Not available for the following widgets: I<GtkMenuBar,> I<GtkNotebook,>
I<GtkMenu>

=head2 B<set_tooltip()>

B<set_tooltip(E<lt>nameE<gt>,> B<E<lt>tooltip_text>)>

Sets a new tooltip text on the widget I<name> . If no tooltip exists
function will add it.

Not available for the following widgets: I<GtkMenuBar,> I<GtkNotebook,>
I<GtkMenu>

=head2 B<get_value()>

string/value = B<get_value(E<lt>nameE<gt>,> B<E<lt>keyE<gt>)>

Returns the current string/value of the widget I<name> depending on the
key or I<undef>.

For more information about the I<<key>> names see the respective widgets.

=head2 B<set_value()>

B<set_value(E<lt>nameE<gt>,> B<Parameter> B<=E<gt>> B<E<lt>new_valueE<gt>)>

Sets a new value on the widget I<name> depending on the given parameter.

For more information about the I<Parameter> names see the respective
widgets.

=head2 B<set_values()>

B<set_values(E<lt>nameE<gt>,> B<Param_x> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<Param_y> B<=E<gt>> B<E<lt>new_valueE<gt>,> B<...)>

Sets a bunch of new values on the widget I<name> depending on the given
parameter.

For more information about the I<Param> names see the respective widgets.

=head2 B<add_signal_handler()>

B<add_signal_handler(E<lt>nameE<gt>,> B<E<lt>signalE<gt>,> B<E<lt>functionE<gt>,> B<E<lt>dataE<gt>)>

This function connects a signal to a sub procedure related to the
widget I<name>.

I<Possible> I<parameters:>

B<E<lt>signalE<gt>>
    Signal which will be "emitted" by the widget I<name>. See Gtk+
    documentation for more info.

B<E<lt>functionE<gt>>
    Function to execute whether I<signal> appears.

B<E<lt>dataE<gt>>
    the data you wish to have passed to this function.

=head2 B<remove_signal_handler()>

B<remove_signal_handler(E<lt>nameE<gt>,> B<E<lt>signalE<gt>)>

This function removes an available signal_handler (a signal-function
pair) from the widget I<name>.

I<Possible> I<parameters:>

B<E<lt>signalE<gt>>
    Name of the signal used by the widget I<name>.

=head2 B<show_all()>

B<show_all()>

This function enters the main loop, which will cause the program to
wait for user input via the mouse or keyboard.

=head1 SPECIAL FUNCTIONS

These functions allow access to the internal parts like the Gtk objects
used inside the library.

If needed use them with care! They can confuse the internal structure
completelly with incorrect usage!

But on the other hand with these function it is possible to use those
Gtk+ function which aren't available in the library.

=head2 B<get_object()>

object = B<get_object(E<lt>name|widget>)>

Returns an object hash from the internal objects list. It can got with
the name or the reference object of a widget.

=head2 B<get_widget()>

reference = B<get_widget(E<lt>nameE<gt>)>

Returns the reference of the widget I<name>.

=head1 INTERNALS

In this section information for deeper usage of the library are
described.

The same as said in SPECIAL FUNCTIONS goes for the following, too:

Use this information with care!

=head2 B<An> B<internal> B<object>

All widget objects are stored as a hash in an internal object list hash
in the respective window created with B<add_window>.

Each object hash has the following base structure:
    object = (  type =E<gt> <string> || undef,
    name =E<gt> <string> || undef,
    title =E<gt> <string> || undef,
    pos_x =E<gt> <integer> || undef,
    pos_y =E<gt> <integer> || undef,
    width =E<gt> <integer> || undef,
    height =E<gt> <integer> || undef,
    container =E<gt> <string> || undef,
    tip =E<gt> <string> || undef,
    handler =E<gt> <hash> || {},
    ref =E<gt> <widget_reference> || undef
    )

Some widget objects have other entries, too. Below they're listed. Also
the internal used type (case sensitive).

I<GtkImage:>

B<path> B<=E<gt>> B<E<lt>string>> B<||> B<undef>
    Path of the image.

B<pixbuf> B<=E<gt>> B<E<lt>reference>> B<||> B<undef>
    Gtk2::Gdk::Pixbuf reference object.

B<image> B<=E<gt>> B<E<lt>reference>> B<||> B<undef>
    Gtk2::Image reference object.  B<Type:> "Image"

I<GtkLabel:>
B<Type:> "Label"

I<GtkButton:>
*Type: "Button"

I<GtkCheckButton:>
B<Type:> "CheckButton"

I<GtkRadioButton:>

B<group> B<=E<gt>> B<E<lt>string>> B<||> B<undef>
    Name of the button group.  B<Type:> "RadioButton"

I<GtkEntry:>

B<Type:>
"Entry"

I<GtkSlider:>

B<adjustment> B<=E<gt>> B<E<lt>reference>> B<||> B<undef>
    Gtk2::Adjustment reference object.  B<Type:> "Slider"

I<GtkSpinButton:>

B<adjustment> B<=E<gt>> B<E<lt>reference>> B<||> B<undef>
    Gtk2::Adjustment reference object.

B<climbrate> B<=E<gt>> B<E<lt>integer>> B<||> B<undef>
    Amount of acceleration that the spin button has.

B<value> B<=E<gt>> B<E<lt>integer>> B<||> B<undef>
    The initial start or current value.  B<Type:> "SpinButton"

I<GtkTextView:>

B<textview> B<=E<gt>> B<E<lt>reference>> B<||> B<undef>
    Gtk2::TextView reference object.

B<path> B<=E<gt>> B<E<lt>string>> B<||> B<undef>
    Path of the text file.

B<textbuf> B<=E<gt>> B<E<lt>reference>> B<||> B<undef>
    Gtk2::TextBuffer reference object.  B<Type:> "TextView"

I<GtkComboBox:>

B<data> B<=E<gt>> B<E<lt>array>> B<||> B<[]>
    The array of values/strings being displayed.  B<Type:> "ComboBox"

I<GtkMenuBar:>

B<menubar> B<=E<gt>> B<E<lt>reference>> B<||> B<undef>
    Gtk2::MenuBar reference object.  B<Type:> "MenuBar"

I<GtkMenu:>

B<title_item> B<=E<gt>> B<E<lt>reference>> B<||> B<undef>
    Gtk2::MenuItem reference object.  B<Type:> "Menu"

I<GtkMenuItem:>

B<icon> B<=E<gt>> B<E<lt>string>> B<||> B<undef>
    Path of an icon, stock id or icon name.  B<Type1:> "MenuItem"
(standard) B<Type2:> "TearOffMenuItem" B<Type3:> "SeparatorMenuItem"
B<Type4:> "RadioMenuItem" B<Type5:> "CheckMenuItem"

I<GtkNotebook:>

B<popup> B<=E<gt>> B<E<lt>integer>> B<||> B<0>
    value whether the popup is activated.  B<Type:> "Notebook"

I<GtkNotebookPage:>
B<Type:> "NotebookPage"

I<GtkFrame:>
B<Type:> "Frame"

I<GtkScrollbar:>
B<Type:> "Scrollbar"

=head1 CAVEATS

SimpleGtk2 is based on the GtkFixed container which can place child
widgets at fixed positions and with fixed sizes, given in pixels.
GtkFixed performs no automatic layout management.

As the Gtk+ documentation says it could result in truncated text,
overlapping widgets, and other display bugs.

=head1 BUGS

Bug reports can be sent to fvwmnightshade-workers mailing list at
https://groups.google.com/forum/?hl=en#!forum/fvwmnightshade-workers or
submit them under
https://github.com/Fvwm-Nightshade/Fvwm-Nightshade/issues.

=head1 LICENSE

This software stands under the GPL V2 or higher.

=head1 AUTHOR

(C) 2013 Thomas Funk <t.funk@web.de>

=head1 SEE ALSO

About the widgets in Gtk+ version 2 see the reference site [1] of the
GNOME project.

Also a good place is the Perl Gtk+ reference on [2].

[1] https://developer.gnome.org/gtk2/stable/index.html

[2] http://gtk2-perl.sourceforge.net/doc/Gtk2-Perl-PodProjDocs/

=cut
