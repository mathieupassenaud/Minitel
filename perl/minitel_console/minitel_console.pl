#! perl -w
# Minitel Console
# M. Passenaud
#
use strict;
use Device::SerialPort;

# set serial port config
my $serialPort = new Device::SerialPort("/dev/ttyS0");
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

# Write to serial port
$serialPort->write("coucou\n");
sleep 1;

# Read
$serialPort->read_const_time(100);
while(1) {
	my ($count, $result) = $serialPort->read(20);
	if(!$result eq ''){
		print "count = $count, result = $result\n";
	}
	
}

undef $serialPort; 