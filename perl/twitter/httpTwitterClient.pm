#! perl -w
package httpTwitterClient;

use strict;
use WWW::Mechanize;

sub getTweets {
	$json_url = "https://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=mathieupassenau&count=20&callback=?"
	my $browser = WWW::Mechanize->new();
	eval{
		# download the json page:
		print "Getting json $json_url\n";
		$browser->get( $json_url );
		my $content = $browser->content();
		my $json = new JSON;
	}
}