#
#
#

package Gtk2::Ex::Simple::TiedList;

use strict;
use Gtk2;
use Carp;

use Gtk2::Ex::Simple::TiedCommon;

our $VERSION = '0.1';

=for nothing

TiedList is an array in which each element is a row in the liststore.

=cut

sub TIEARRAY {
	my $class = shift;
	my $model = shift;

	croak "usage tie (\@ary, 'class', model)"
		unless $model && UNIVERSAL::isa ($model, 'Gtk2::TreeModel');

	return bless {
		model => $model,
	}, $class;
}

sub FETCH { # this, index
	my $iter = $_[0]->{model}->iter_nth_child (undef, $_[1]);
	return undef unless defined $iter;
	my @row;
	tie @row, 'Gtk2::Ex::Simple::TiedRow', $_[0]->{model}, $iter;
	return \@row;
}

sub STORE { # this, index, value
	my $iter = $_[0]->{model}->iter_nth_child (undef, $_[1]);
	$iter = $_[0]->{model}->insert ($_[1])
		if not defined $iter;
	my @row;
	tie @row, 'Gtk2::Ex::Simple::TiedRow', $_[0]->{model}, $iter;
	if ('ARRAY' eq ref $_[2]) {
		@row = @{$_[2]};
	} else {
		$row[0] = $_[2];
	}
	return 1;
}

sub FETCHSIZE { # this
	return $_[0]->{model}->iter_n_children (undef);
}

sub PUSH { # this, list
	my $model = shift()->{model};
	my $iter;
	foreach (@_)
	{
		$iter = $model->append;
		my @row;
		tie @row, 'Gtk2::Ex::Simple::TiedRow', $model, $iter;
		if ('ARRAY' eq ref $_) {
			@row = @$_;
		} else {
			$row[0] = $_;
		}
	}
	return $model->iter_n_children (undef);
}

sub POP { # this
	my $model = $_[0]->{model};
	my $index = $model->iter_n_children-1;
	my $iter = $model->iter_nth_child(undef, $index);
	return undef unless ($iter);
	my $ret = [ $model->get ($iter) ];
	$model->remove($iter) if( $index >= 0 );
	return $ret;
}

sub SHIFT { # this
	my $model = $_[0]->{model};
	my $iter = $model->iter_nth_child(undef, 0);
	return undef unless ($iter);
	my $ret = [ $model->get ($iter) ];
	$model->remove($iter) if( $model->iter_n_children );
	return $ret;
}

sub UNSHIFT { # this, list
	my $model = shift()->{model};
	my $iter;
	foreach (@_)
	{
		$iter = $model->prepend;
		my @row;
		tie @row, 'Gtk2::Ex::Simple::TiedRow', $model, $iter;
		if ('ARRAY' eq ref $_) {
			@row = @$_;
		} else {
			$row[0] = $_;
		}
	}
	return $model->iter_n_children (undef);
}

# note: really, arrays aren't supposed to support the delete operator this
#       way, but we don't want to break existing code.
sub DELETE { # this, key
	my $model = $_[0]->{model};
	my $ret;
	if ($_[1] < $model->iter_n_children (undef)) {
		my $iter = $model->iter_nth_child (undef, $_[1]);
		return undef unless ($iter);
		$ret = [ $model->get ($iter) ];
		$model->remove ($iter);
	}
	return $ret;
}

sub CLEAR { # this
	$_[0]->{model}->clear;
}

# note: arrays aren't supposed to support exists, either.
sub EXISTS { # this, key
	return( $_[1] < $_[0]->{model}->iter_n_children );
}

# we can't really, reasonably, extend the tree store in one go, it will be 
# extend as items are added
sub EXTEND {}

sub get_model {
	return $_[0]{model};
}

sub STORESIZE { carp "STORESIZE: operation not supported"; }

sub SPLICE { # this, offset, length, list
	my $self = shift;
	# get the model and the number of rows	
	my $model = $self->{model};
	# get the offset
	my $offset = shift || 0;
	# if offset is neg, invert it
	$offset = $model->iter_n_children (undef) + $offset if ($offset < 0);
	# get the number of elements to remove
	my $length = shift;
	# if len was undef, not just false, calculate it
	$length = $self->FETCHSIZE() - $offset unless (defined ($length));
	# get any elements we need to insert into their place
	my @list = @_;
	
	# place to store any returns
	my @ret = ();

	# remove the desired elements
	my $ret;
	for (my $i = $offset; $i < $offset+$length; $i++)
	{
		# things will be shifting forward, so always delete at offset
		$ret = $self->DELETE ($offset);
		push @ret, $ret if defined $ret;
	}

	# insert the passed list at offset in reverse order, so the will
	# be in the correct order
	foreach (reverse @list)
	{
		# insert a new row
		$model->insert ($offset);
		# and put the data in it
		$self->STORE ($offset, $_);
	}
	
	# return deleted rows in array context, the last row otherwise
	# if nothing deleted return empty
	return (@ret ? (wantarray ? @ret : $ret[-1]) : ());
}

1;
__END__

Copyright (C) 2004 by the gtk2-perl team (see the file AUTHORS for the
full list).  See LICENSE for more information.
