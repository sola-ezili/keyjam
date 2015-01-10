package Console;

use strict;
use warnings;
use utf8;

use Data::Dumper;

our $debug = 0;

###
# methods
###

sub out {
	my ($msg, $sender) = @_;
	return unless defined($msg);
	
	print $sender."::" if (defined($sender));

	if (ref($msg) eq "ARRAY") {
		print "ARRAY: " . Dumper($msg) . "\n";
	} elsif (ref($msg) eq "HASH") {
		print "HASH: " . Dumper($msg) . "\n";
	} else {
		print "$msg\n";
	}
}

sub debug {
	return unless (defined($debug) and $debug == 1);
	my ($msg, $sender) = @_;
	
	return unless defined($msg);

	if (defined($sender)) {
		$sender = "[debug] $sender";
	} else {
		$sender = "[debug]";
	}

	&out($msg, $sender);
}

1;

