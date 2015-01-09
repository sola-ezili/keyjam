package Button;

use strict;
use warnings;

use QtCore4;
use QtGui4;

use QtCore4::isa qw( Qt::PushButton );
use QtCore4::slots
	setNote		=> ['int'],
	setChannel	=> ['int'],
	onClick		=> [];
use QtCore4::signals
	buttonClicked	=> ['int', 'int'];

use NoteDialog;
use Console;

###
# constructor
###

sub NEW {
	my ($class, $parent, $row, $step, $note, $channel) = @_;
	$class->SUPER::NEW( $parent );
	&Console::out("NEW($row, $step, $note, $channel)", "Button");
	this->{row} = $row;
	this->{step} = $step;
	this->{note} = $note;
	this->{channel} = $channel;
	this->connect(this, SIGNAL 'clicked()', this, SLOT 'onClick()');
}

###
# methods
###

sub row() {
	return this->{row};
}

sub step() {
	return this->{step};
}

sub note() {
	return this->{note};
}

sub channel() {
	return this->{channel};
}

###
# slots
###

sub onClick {
	emit buttonClicked(this->{row}, this->{step});
	if (!defined(this->{dialog}) || !this->{dialog}) {
		this->{dialog} = NoteDialog(this, this->{note}, this->{channel});

		this->connect(this->{dialog}, SIGNAL 'noteChanged(int)', this, SLOT 'setNote(int)');
		this->connect(this->{dialog}, SIGNAL 'channelChanged(int)', this, SLOT 'setChannel(int)');
	}

	this->{dialog}->show();
}

sub setNote {
	my ($note) = @_;
	this->{note} = $note;
	&Console::out("setNote($note)", "Button");
}

sub setChannel {
	my ($channel) = @_;
	this->{channel} = $channel;
	&Console::out("setChannel($channel)", "Button");
}

1;
