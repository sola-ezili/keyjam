package Console;

use strict;
use warnings;
use utf8;

use Data::Dumper;

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

1;

