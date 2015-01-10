package MainWindow;

use strict;

use File::Basename;

use QtCore4;
use QtCore4::debug qw(ambiguous);
use QtGui4;
use QtCore4::isa qw( Qt::MainWindow );
use QtCore4::slots
		newFile		=> [],
		openFile	=> [],
		save		=> [],
		saveAs		=> [],
		modified	=> [],
		onButtonClicked	=> ['int', 'int'];

use Button;
use Midi;
use Console;

###
# constructor
###

sub NEW {
	shift->SUPER::NEW(@_);

	&Console::out("NEW()", "MainWindow");
	createActions();
	createMenus();
	createStatusBar();

	this->{bindings} = {
		49	=> { row => 1, step => 1, down => 0, note => 60, channel => 0, }, # 1
		50	=> { row => 1, step => 2, down => 0, note => 62, channel => 0, }, # 2
		51	=> { row => 1, step => 3, down => 0, note => 63, channel => 0, }, # 3
		52	=> { row => 1, step => 4, down => 0, note => 65, channel => 0, }, # 4
		53	=> { row => 1, step => 5, down => 0, note => 67, channel => 0, }, # 5
		54	=> { row => 1, step => 6, down => 0, note => 68, channel => 0, }, # 6
		55	=> { row => 1, step => 7, down => 0, note => 70, channel => 0, }, # 7
		56	=> { row => 1, step => 8, down => 0, note => 72, channel => 0, }, # 8
		81	=> { row => 2, step => 1, down => 0, note => 48, channel => 1, }, # q
		87	=> { row => 2, step => 2, down => 0, note => 50, channel => 1, }, # w
		69	=> { row => 2, step => 3, down => 0, note => 51, channel => 1, }, # e
		82	=> { row => 2, step => 4, down => 0, note => 53, channel => 1, }, # r
		84	=> { row => 2, step => 5, down => 0, note => 55, channel => 1, }, # t
		90	=> { row => 2, step => 6, down => 0, note => 56, channel => 1, }, # z
		85	=> { row => 2, step => 7, down => 0, note => 57, channel => 1, }, # u
		73	=> { row => 2, step => 8, down => 0, note => 60, channel => 1, }, # i
		65	=> { row => 3, step => 1, down => 0, note => 36, channel => 2, }, # a
		83	=> { row => 3, step => 2, down => 0, note => 38, channel => 2, }, # s
		68	=> { row => 3, step => 3, down => 0, note => 39, channel => 2, }, # d
		70	=> { row => 3, step => 4, down => 0, note => 41, channel => 2, }, # f
		71	=> { row => 3, step => 5, down => 0, note => 43, channel => 2, }, # g
		72	=> { row => 3, step => 6, down => 0, note => 44, channel => 2, }, # h
		74	=> { row => 3, step => 7, down => 0, note => 46, channel => 2, }, # j
		75	=> { row => 3, step => 8, down => 0, note => 48, channel => 2, }, # k
		89	=> { row => 4, step => 1, down => 0, note => 36, channel => 3, }, # y
		88	=> { row => 4, step => 2, down => 0, note => 42, channel => 3, }, # x
		67	=> { row => 4, step => 3, down => 0, note => 46, channel => 3, }, # c
		86	=> { row => 4, step => 4, down => 0, note => 38, channel => 3, }, # v
		66	=> { row => 4, step => 5, down => 0, note => 49, channel => 3, }, # b
		78	=> { row => 4, step => 6, down => 0, note => 51, channel => 3, }, # n
		77	=> { row => 4, step => 7, down => 0, note => 41, channel => 3, }, # m
		44	=> { row => 4, step => 8, down => 0, note => 47, channel => 3, }, # ,
	};

	this->setCurrentFile("");

	this->resize(600, 200);

	this->createButtons();
	this->setCentralWidget(this->{gridGroupBox});

	&Midi::init_alsa();
}

###
# reimplemented protected methods 
###

sub keyPressEvent {
	my ($event) = @_;
	if ($event->isAutoRepeat()) {
		$event->ignore();
		return;
	}

	my $kc = $event->key();
	if (this->{bindings}->{$kc}) {
		my $down = this->{bindings}->{$kc}{down};
		if ($down == 0) {
			this->{bindings}->{$kc}{down} = 1;
			my $row = this->{bindings}->{$kc}{row};
			my $step = this->{bindings}->{$kc}{step};
			my $button = this->{buttons}->[$row]{$step};
			my $note = $button->note();
			my $channel = $button->channel();
			&Midi::note_on($channel, $note);
			$event->accept();
		} else {
			$event->ignore();
		}
	} else {
		$event->accept();
	}
}

sub keyReleaseEvent {
	my ($event) = @_;
	if ($event->isAutoRepeat()) {
		$event->ignore();
		return;
	}

	my $kc = $event->key();
	if (this->{bindings}->{$kc}) {
		my $down = this->{bindings}->{$kc}{down};
		if ($down == 1) { 
			this->{bindings}->{$kc}{down} = 0;
			my $row = this->{bindings}->{$kc}{row};
			my $step = this->{bindings}->{$kc}{step};
			my $button = this->{buttons}->[$row]{$step};
			my $note = $button->note();
			my $channel = $button->channel();
			&Midi::note_off($channel, $note);
			$event->accept();
		} else {
			$event->ignore();
		}
	} else {
		$event->accept();
	}
}

###
# methods
###

sub maybeSave {
	return 1;
}

sub createActions {
	my $newAct = Qt::Action("&New", this);
	$newAct->setStatusTip("Create a new program");
	this->connect($newAct, SIGNAL 'triggered()', this, SLOT 'newFile()');
	this->{newAct} = $newAct;

	my $openAct = Qt::Action("&Open...", this);
	$openAct->setStatusTip("Open an existing file");
	this->connect($openAct, SIGNAL 'triggered()', this, SLOT 'openFile()');
	this->{openAct} = $openAct;

	my $saveAct = Qt::Action("&Save", this);
	$saveAct->setStatusTip("Save the program to disk");
	this->connect($saveAct, SIGNAL 'triggered()', this, SLOT 'save()');
	this->{saveAct} = $saveAct;

	my $saveAsAct = Qt::Action("Save &As...", this);
	$saveAsAct->setStatusTip("Save the program under a new name");
	this->connect($saveAsAct, SIGNAL 'triggered()', this, SLOT 'saveAs()');
	this->{saveAsAct} = $saveAsAct;

	my $exitAct = Qt::Action("E&xit", this);
	$exitAct->setStatusTip("Exit the application");
	this->connect($exitAct, SIGNAL 'triggered()', this, SLOT 'close()');
	this->{exitAct} = $exitAct;
}

sub createMenus {
	my $fileMenu = this->menuBar()->addMenu("&File");
	$fileMenu->addAction(this->{newAct});
	$fileMenu->addAction(this->{openAct});
	$fileMenu->addAction(this->{saveAct});
	$fileMenu->addAction(this->{saveAsAct});
	$fileMenu->addSeparator();
	$fileMenu->addAction(this->{exitAct});
}

sub createStatusBar {
	this->statusBar()->showMessage("Ready");
}

sub createButtons {
	this->{gridGroupBox} = Qt::GroupBox('Buttons!');

	my $layout = Qt::GridLayout();

	this->{spinBoxes} = [];
	this->{buttons} = [];

	my $channelLabel = Qt::Label("Channels");
	$layout->addWidget($channelLabel, 0, 0);
	for (my $i = 1; $i < 5; ++$i) {
		for (my $j = 1; $j < 9; ++$j) {
			my $note = 60;
			my $channel = $i - 1;
			foreach my $kc (keys this->{bindings}) {
				&Console::out($kc, "MainWindow");
				if (this->{bindings}->{$kc}{row} == $i and this->{bindings}->{$kc}{step} == $j) {
					$note = this->{bindings}->{$kc}{note};
					$channel = this->{bindings}->{$kc}{channel};
				}
			}
			my $buttonName = "$i"."_"."$j";
			this->buttons->[$i]{$j} = Button($buttonName, $i, $j, $note, $channel);
			this->connect(this->buttons->[$i]{$j}, SIGNAL 'buttonClicked(int,int)', this, SLOT 'onButtonClicked(int,int)');
			$layout->addWidget(this->buttons->[$i]{$j}, $i, $j);
		}
	}

	this->gridGroupBox->setLayout($layout);
}

sub gridGroupBox() {
	return this->{gridGroupBox};
}

sub spinBoxes() {
	return this->{spinBoxes};
}

sub buttons() {
	return this->{buttons};
}

sub setCurrentFile {
	my ( $fileName ) = @_;
	this->{curFile} = $fileName;

	my $shownName;
	if (!defined this->{curFile} || !(this->{curFile})) {
		$shownName = "untitled.txt";
	} else {
		$shownName = strippedName(this->{curFile});
	}

	this->setWindowTitle(sprintf("%s - %s\[*]", "KeyJam", $shownName));
}

sub strippedName {
	my ( $fullFileName ) = @_;
	return basename ( $fullFileName );
}

sub loadFile {
	my ( $fileName ) = @_;
	if (!(open( FH, "< $fileName"))) {
		Qt::MessageBox::warning(this, "KeyJam",
					sprintf("Cannot read file %s:\n%s.",
					$fileName,
					$!));
		return 0;
	}

	Qt::Application::setOverrideCursor(Qt::Cursor(Qt::WaitCursor()));
	# TODO do something with file contents
	Qt::Application::restoreOverrideCursor();
	close FH;

	setCurrentFile($fileName);
	this->statusBar()->showMessage("File loaded", 2000);
}

sub saveFile {
	my ($fileName) = @_;
	if (!(open( FH, "> $fileName"))) {
		Qt::MessageBox::warning(this, "KeyJam",
					sprintf("Cannot write file %s:\n%s.",
					$fileName,
					$!));
		return 0;
	}

	Qt::Application::setOverrideCursor(Qt::Cursor(Qt::WaitCursor()));
	# TODO write something to file handle
	Qt::Application::restoreOverrideCursor();
	close FH;

	setCurrentFile($fileName);
	this->statusBar()->showMessage("File saved", 2000);
	return 1;
}

###
# slots
###

sub newFile {
	if (maybeSave()) {
		setCurrentFile("");
	}
}

sub openFile {
	if (maybeSave()) {
		my $fileName = Qt::FileDialog::getOpenFileName(this);
		if ($fileName) {
			loadFile($fileName);
		}
	}
}

sub save {
	if (!defined this->{curFile} || !this->{curFile}) {
		return saveAs();
	} else {
		return saveFile(this->{curFile});
	}
}

sub saveAs {
	my $fileName = Qt::FileDialog::getSaveFileName(this);
	if (!defined $fileName) {
		return 0;
	}

	return saveFile($fileName);
}

sub onButtonClicked {
	my ($row, $step) = @_;
	print "CLICKED $row, $step\n";
}

1;
