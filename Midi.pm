package Midi;

use strict;
use warnings;

use MIDI::ALSA(':CONSTS');

use Console;

sub init_alsa {
	&Console::out("init_alsa()", "Midi");
	MIDI::ALSA::client( 'KeyJam', 1, 1, 0 );
	MIDI::ALSA::connectfrom( 0, 14, 0 );  # input port is lower (0)
	MIDI::ALSA::connectto( 1, 20, 0 );   # output port is higher (1)
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

		#my @alsaevent = MIDI::ALSA::input();
		#if ($alsaevent[0] == SND_SEQ_EVENT_PORT_UNSUBSCRIBED()) { last; }
		#if ($alsaevent[0] == SND_SEQ_EVENT_NOTEON()) {
		#    my $channel  = $alsaevent[7][0];
		#    my $pitch    = $alsaevent[7][1];
		#    my $velocity = $alsaevent[7][2];
		#    print "NOTEON: $channel $pitch $velocity\n";
		#} elsif ($alsaevent[0] == SND_SEQ_EVENT_CONTROLLER()) {
		#    my $channel    = $alsaevent[7][0];
		#    my $controller = $alsaevent[7][4];
		#    my $value      = $alsaevent[7][5];
		#    print "CONTROLLER: $channel $controller $value\n";
		#}
		#MIDI::ALSA::output( @alsaevent );

