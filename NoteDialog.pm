package NoteDialog;

use strict;
use warnings;

use QtCore4;
use QtGui4;
use QtCore4::isa qw( Qt::Dialog );
use QtCore4::signals
	noteChanged	=> ['int'],
	channelChanged	=> ['int'];

use Console;

###
# constructor
###

sub NEW {
	my ($class, $parent, $note, $channel) = @_;
	$class->SUPER::NEW( $parent );
	&Console::out("NEW($note, $channel)", "NoteDialog");

	this->setModal(1);
	$note = 64 unless (defined($note));
	$channel = 0 unless (defined($channel));

	this->{gridGroupBox} = Qt::GroupBox('Edit', this);
	my $layout = Qt::GridLayout();
	this->{gridGroupBox}->setLayout($layout);
	this->{gridGroupBox}->setMinimumSize(144, 96);

	my $noteLabel = Qt::Label("Note");
	$layout->addWidget($noteLabel, 0, 0);

	this->{noteSpinBox} = Qt::SpinBox(undef);
	this->{noteSpinBox}->setMinimum(0);
	this->{noteSpinBox}->setMaximum(127);
	this->{noteSpinBox}->setValue($note);
	$layout->addWidget(this->{noteSpinBox}, 0, 1);


	my $channelLabel = Qt::Label("Channel");
	$layout->addWidget($channelLabel, 1, 0);

	this->{channelSpinBox} = Qt::SpinBox(undef);
	this->{channelSpinBox}->setMinimum(0);
	this->{channelSpinBox}->setMaximum(15);
	this->{channelSpinBox}->setValue($channel);
	$layout->addWidget(this->{channelSpinBox}, 1, 1);

	this->connect(this->{noteSpinBox}, SIGNAL 'valueChanged(int)', this, SIGNAL 'noteChanged(int)');
	this->connect(this->{channelSpinBox}, SIGNAL 'valueChanged(int)', this, SIGNAL 'channelChanged(int)');

}

###
# reimplemented protected methods
###

sub closeEvent {
	my ($event) = @_;
	$event->ignore();
	this->hide();
}

1;
