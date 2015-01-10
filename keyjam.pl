#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: keyjam.pl
#
#        USAGE: ./keyjam.pl  
#
#  DESCRIPTION: Turns your PC keyboard into a MIDI sampler pad.
#
#      OPTIONS: ---
# REQUIREMENTS: MIDI::ALSA; perlqt4 
#         BUGS: yes.
#        NOTES: ---
#       AUTHOR: sola (ScandalousSola@gmail.com), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 01/07/2015 05:05:25 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use QtCore4;
use MainWindow;

sub main {
	my $app = Qt::Application( \@ARGV );
	my $window = MainWindow();
	$window->show();
	exit $app->exec();
}

main();

