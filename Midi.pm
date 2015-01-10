package Midi;

use strict;
use warnings;

use MIDI::ALSA(':CONSTS');

use Console;

sub init_alsa {
	&Console::out("init_alsa()", "Midi");
	MIDI::ALSA::client( 'KeyJam', 0, 1, 0 );
}

sub note_on {
	my ($channel, $note) = @_;
	my @alsaevent = MIDI::ALSA::noteevent(0,32,100,0,0.5);
	$alsaevent[0] = SND_SEQ_EVENT_NOTEON();
	$alsaevent[7][1] = $note;
	$alsaevent[7][0] = $channel;
	MIDI::ALSA::output( @alsaevent );
	MIDI::ALSA::syncoutput();
	&Console::out("note_on($channel $note)", "Midi");
}

sub note_off {
	my ($channel, $note) = @_;
	my @alsaevent = MIDI::ALSA::noteevent(0,32,100,0,0.5);
	$alsaevent[0] = SND_SEQ_EVENT_NOTEOFF();
	$alsaevent[7][1] = $note;
	$alsaevent[7][0] = $channel;
	MIDI::ALSA::output( @alsaevent );
	MIDI::ALSA::syncoutput();
	&Console::out("note_off($channel $note)", "Midi");
}

1;

