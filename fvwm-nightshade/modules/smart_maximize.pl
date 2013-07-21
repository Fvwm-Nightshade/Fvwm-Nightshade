#!/usr/bin/perl
# Time-stamp: "2013-06-29 11:13:03 ah"

# implement "smart maximize" as described in:
# http://www.mail-archive.com/fvwm@lists.math.uh.edu/msg16809.html

use warnings;
use strict;

use List::Util qw(min);

use lib `fvwm-perllib dir`;
use FVWM::Module;

my $module = new FVWM::Module(Mask => M_STRING);
my $pageTrackerWL = $module->track('WindowList');
my $vp_width = $pageTrackerWL->pageInfo->{vp_width};
my $vp_height = $pageTrackerWL->pageInfo->{vp_height};

$module->add_handler(M_STRING, \&smartMaximize);
$module->event_loop;

# main function smartMaximize gets called when issuing an FVWM command like:
# SendToModule smart_maximize.pl dummy
sub smartMaximize
{
    my ($module, $event) = @_;

    # the window to be maximized
    my $own = $pageTrackerWL->data(${$event->args}{win_id});

    # we want the window to actually grow
    my $minArea =
        $own->{width} * $own->{height} + min($own->{width}, $own->{height});

    # Find all free rectangles in the current page where the window could be
    # displayed. This works as follows:
    # The list of display rectangles starts with one preliminary display
    # rectangle: the whole page.
    # Then one after another all windows are applied to the list of the
    # preliminary display rectangles.
    # If a window overlaps with a rectangle, it splits the rectangle into at
    # most four smaller rectangles: the one above the window, the one below it,
    # the one left of it, the one right of it.
    # Any rectangle not bigger than the window to be maximized gets discarded
    # at once.
    # After all windows have been applied to the rectangle list, the display
    # rectangles are not preliminary any longer, as they won't be split into
    # smaller rectangles any longer.
    # The biggest display rectangle will be used as the new window location.
    my @rectangles = (&createRectangle($own->{page_nx} * $vp_width,
                                       ($own->{page_nx} + 1) * $vp_width,
                                       $own->{page_ny} * $vp_height,
                                       ($own->{page_ny} + 1) * $vp_height));

    # apply all windows to the display rectangle list
    foreach my $other ($pageTrackerWL->windows)
    {
        unless ($other->{win_id} == $own->{win_id}
                or $other->{desk} != $own->{desk})
        {
            @rectangles = &applyWindow($other, $minArea, @rectangles);
        }
    }

    # take the rectangle with the largest area as destination
    my $dest;
    foreach my $rect (@rectangles)
    {
        if ($dest)
        {
            # first level criterion: bigger
            if ($rect->{area} > $dest->{area}
                # second level criterion: just as big, but more left
                or ($rect->{area} == $dest->{area}
                    and ($rect->{x_min} < $dest->{x_min}
                         # third level criterion:
                         # just as big, just as left, but more up
                         or ($rect->{x_min} == $dest->{x_min}
                             and $rect->{y_min} < $dest->{y_min}))))
            {
                $dest = $rect;
            }
        }
        else
        {
            $dest = $rect;
        }
    }

    if ($dest)
    {
        # move the window to the display rectangle and let it fill it
        my $x = $dest->{x_min} - $own->{page_nx} * $vp_width;
        my $y = $dest->{y_min} - $own->{page_ny} * $vp_height;
        $module->send("WindowId $own->{win_id} Move ${x}p ${y}p Warp");
        $module->send("WindowId $own->{win_id} Maximize grow grow");
    }
}

# Apply a window to the current display rectangle list.
# This may change the rectangle list.
sub applyWindow
{
    my ($other, $minArea, @oldRectangles) = @_;

    my $splitter =
    {x_min => $other->{page_nx} * $vp_width + $other->{x},
     x_max => $other->{page_nx} * $vp_width + $other->{x} + $other->{width},
     y_min => $other->{page_ny} * $vp_height + $other->{y},
     y_max => $other->{page_ny} * $vp_height + $other->{y} + $other->{height}};
    my @newRectangles;

    # apply the window to all display rectangles
    foreach my $rect (@oldRectangles)
    {
        if (&doRectanglesOverlap($rect, $splitter))
        {
            # the window splits the rectangle into 0-4 new, smaller rectangles
            if ($rect->{x_min} < $splitter->{x_min})
            {
                # new rectangle left of splitter window
                my $r = &createRectangle($rect->{x_min},
                                         $splitter->{x_min} - 1,
                                         $rect->{y_min},
                                         $rect->{y_max});
                push @newRectangles, $r if $r->{area} >= $minArea;
            }
            if ($rect->{x_max} > $splitter->{x_max})
            {
                # new rectangle right of splitter window
                my $r = &createRectangle($splitter->{x_max} + 1,
                                         $rect->{x_max},
                                         $rect->{y_min},
                                         $rect->{y_max});
                push @newRectangles, $r if $r->{area} >= $minArea;
            }
            if ($rect->{y_min} < $splitter->{y_min})
            {
                # new rectangle above splitter window
                my $r = &createRectangle($rect->{x_min},
                                         $rect->{x_max},
                                         $rect->{y_min},
                                         $splitter->{y_min} - 1);
                push @newRectangles, $r if $r->{area} >= $minArea;
            }
            if ($rect->{y_max} > $splitter->{y_max})
            {
                # new rectangle below splitter window
                my $r = &createRectangle($rect->{x_min},
                                         $rect->{x_max},
                                         $splitter->{y_max} + 1,
                                         $rect->{y_max});
                push @newRectangles, $r if $r->{area} >= $minArea;
            }
        }
        else
        {
            # As window and display rectangle do not overlap,
            # the display rectangle is not affected by the window.
            push @newRectangles, $rect;
        }
    }

    return @newRectangles;
}

sub createRectangle
{
    my ($x_min, $x_max, $y_min, $y_max) = @_;

    return {x_min => $x_min,
            x_max => $x_max,
            y_min => $y_min,
            y_max => $y_max,
            area  => ($x_max - $x_min) * ($y_max - $y_min)};
}

sub doRectanglesOverlap
{
    my ($r1, $r2) = @_;

    return not ($r1->{x_max} < $r2->{x_min}
                or $r1->{x_min} > $r2->{x_max}
                or $r1->{y_max} < $r2->{y_min}
                or $r1->{y_min} > $r2->{y_max});
}
