package Midi;

use strict;
use warnings;

use MIDI::ALSA(':CONSTS');
use QtCore4;
use QtCore4::isa qw ( Qt::Object );
use QtCore4::slots
	run	=> [];

use Console;

our @messageQueue = ();

###
# constructor
###

sub NEW {
	my ($class, $parent) = @_;
	$class->SUPER::NEW( $parent );

	this->{ready} = 0;

	&Console::debug("NEW()", "Midi");
	&init_alsa();

	this->{timer} = Qt::Timer(this);
	this->{timer}->setInterval(1);
	this->connect(this->{timer}, SIGNAL 'timeout()', this, SLOT 'run()');
	this->{timer}->start();
}

###
# slots
###

sub run {
	if (this->{ready} == 1) {
		while (defined(my $alsaevent = shift @messageQueue)) {
			MIDI::ALSA::output( @$alsaevent );
		}
		MIDI::ALSA::syncoutput();
	}
		
}

###
# methods
###

sub init_alsa {
	&Console::out("init_alsa()", "Midi");
	MIDI::ALSA::client( 'KeyJam', 0, 1, 0 );
	this->{ready} = 1;
}

sub note_on {
	my ($channel, $note) = @_;
	my @alsaevent = MIDI::ALSA::noteevent(0,32,100,0,0.5);
	$alsaevent[0] = SND_SEQ_EVENT_NOTEON();
	$alsaevent[7][1] = $note;
	$alsaevent[7][0] = $channel;

	my $alsaref = \@alsaevent;
	push(@messageQueue, $alsaref);

	&Console::out("note_on($channel $note)", "Midi");
}

sub note_off {
	my ($channel, $note) = @_;
	my @alsaevent = MIDI::ALSA::noteevent(0,32,100,0,0.5);
	$alsaevent[0] = SND_SEQ_EVENT_NOTEOFF();
	$alsaevent[7][1] = $note;
	$alsaevent[7][0] = $channel;

	my $alsaref = \@alsaevent;
	push(@messageQueue, $alsaref);

	&Console::out("note_off($channel $note)", "Midi");
}

1;

