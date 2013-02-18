#! perl -w
package serialInputOutput ;

use strict;
use Win32::SerialPort;

my $serialPort ;

sub init {
	# set serial port config
	$serialPort = new Win32::SerialPort("COM1");
	$serialPort->databits(7);
	$serialPort->baudrate(4800);
	$serialPort->parity("even");
	$serialPort->stopbits(1);
	$serialPort->handshake("none");
	$serialPort->write_settings || undef $serialPort;

	# print the config
	my $baud = $serialPort->baudrate;
	my $parity = $serialPort->parity;
	my $data = $serialPort->databits;
	my $stop = $serialPort->stopbits;
	my $hshake = $serialPort->handshake;
	print "B = $baud, D = $data, S = $stop, P = $parity, 
            H = $hshake\n";
}

sub write {
	my $message = $_[0];
	
	# Write to serial port
	print $message;
	#$serialPort->write($message);
	sleep 1;
}