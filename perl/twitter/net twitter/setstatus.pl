#! perl -w
# Minitel Console
# M. Passenaud
#
use Net::Twitter;

my $tweet = 'I\'m tweeting from an OAuth PERL app everybody!';

my $twitterconsumer = 'WhAr0gS0jiwHdHkmL7YAQ';
my $twitterconsumersecret = 'PCQ5TsVh8Iamo4bQdgpfG9ZJ07iI0qL6CZ692kNeim4';
my $twitteraccesstoken = 'mathieupassenau';
my $twitteraccesstokensecret = 'pavillonDV5162';

my $nt = Net::Twitter->new(
	traits          => ['API::REST', 'OAuth'],
	consumer_key    => $twitterconsumer,
	consumer_secret => $twitterconsumersecret,
);

if ($twitteraccesstoken && $twitteraccesstokensecret) {
	$nt->access_token($twitteraccesstoken);
	$nt->access_token_secret($twitteraccesstokensecret);
}

unless ( $nt->authorized ) {
	print "Authorize this app at ", $nt->get_authorization_url, " and enter the PIN#\n";
	
	my $pin = ''; # wait for input
	chomp $pin;
	
	my($access_token, $access_token_secret, $user_id, $screen_name) = $nt->request_access_token(verifier => $pin);
	print 'Access token: '.$access_token."\r\n".'Access Token Secret: '.$access_token_secret."\r\n";

	exit();

}

$nt->update({ status => $tweet });