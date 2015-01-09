#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: keyjam.pl
#
#        USAGE: ./keyjam.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
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
use QtGui4;
use MainWindow;

use MIDI::ALSA(':CONSTS');

sub main {
	my $app = Qt::Application( \@ARGV );
	my $window = MainWindow();
	$window->show();
	exit $app->exec();
}

main();

