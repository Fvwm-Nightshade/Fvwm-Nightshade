#
#
#

package Gtk2::Ex::Simple::TiedCommon;

our %column_types = (
  'hidden' => {type=>'Glib::String',                                        attr=>'hidden'},
  'text'   => {type=>'Glib::String',  renderer=>'Gtk2::CellRendererText',   attr=>'text'},
  'markup' => {type=>'Glib::String',  renderer=>'Gtk2::CellRendererText',   attr=>'markup'},
  'int'    => {type=>'Glib::Int',     renderer=>'Gtk2::CellRendererText',   attr=>'text'},
  'double' => {type=>'Glib::Double',  renderer=>'Gtk2::CellRendererText',   attr=>'text'},
  'bool'   => {type=>'Glib::Boolean', renderer=>'Gtk2::CellRendererToggle', attr=>'active'},
  'scalar' => {type=>'Glib::Scalar',  renderer=>'Gtk2::CellRendererText',   
	  attr=> sub { 
  		my ($tree_column, $cell, $model, $iter, $i) = @_;
  		my ($info) = $model->get ($iter, $i);
  		$cell->set (text => $info || '' );
	  } },
  'pixbuf' => {type=>'Gtk2::Gdk::Pixbuf', renderer=>'Gtk2::CellRendererPixbuf', attr=>'pixbuf'},
);

# this is some cool shit
sub add_column_type
{
	shift;	# don't want/need classname
	my $name = shift;
	$column_types{$name} = { @_ };
}

package Gtk2::Ex::Simple::TiedRow;

use strict;
use Gtk2;
use Carp;

our $VERSION = '0.1';

=for nothing

TiedRow is the lowest-level tie, allowing you to treat a row as an array
of column data.

=cut

sub TIEARRAY {
	my $class = shift;
	my $model = shift;
	my $iter = shift;

	croak "usage tie (\@ary, 'class', model, iter)"
		unless $model && UNIVERSAL::isa ($model, 'Gtk2::TreeModel');

	return bless {
		model => $model,
		iter => $iter,
	}, $class;
}

sub FETCH { # this, index
	return $_[0]->{model}->get ($_[0]->{iter}, $_[1]);
}

sub STORE { # this, index, value
	return $_[0]->{model}->set ($_[0]->{iter}, $_[1], $_[2])
		if defined $_[2]; # allow 0, but not undef
}

sub FETCHSIZE { # this
	return $_[0]{model}->get_n_columns;
}

sub EXISTS { 
	return( $_[1] < $_[0]{model}->get_n_columns );
}

sub EXTEND { } # can't change the length, ignore
sub CLEAR { } # can't change the length, ignore

sub new {
	my ($class, $model, $iter) = @_;
	my @a;
	tie @a, __PACKAGE__, $model, $iter;
	return \@a;
}

sub POP { croak "pop called on a TiedRow, but you can't change its size"; }
sub PUSH { croak "push called on a TiedRow, but you can't change its size"; }
sub SHIFT { croak "shift called on a TiedRow, but you can't change its size"; }
sub UNSHIFT { croak "unshift called on a TiedRow, but you can't change its size"; }
sub SPLICE { croak "splice called on a TiedRow, but you can't change its size"; }
#sub DELETE { croak "delete called on a TiedRow, but you can't change its size"; }
sub STORESIZE { carp "STORESIZE operation not supported"; }

1;
__END__

Copyright (C) 2004 by the gtk2-perl team (see the file AUTHORS for the
full list).  See LICENSE for more information.
