use strict;
use warnings;
use Data::Monad::AECV;
use AnyEvent::HTTP;
use AnyEvent::Util;

print Data::Monad::AECV->unit("http://www.google.com")->bind(sub {
	my $url = shift;
	my $ret_cv = AE::cv;
	http_get $url, sub {
		$ret_cv->send($_[0]);
	};
	return Data::Monad::AECV->new(cv => $ret_cv);
})->bind(sub {
	my $html = shift;

	my $ret;
	Data::Monad::AECV->new(cv => AnyEvent::Util::run_cmd(
		[qw/wc /], '<' => \$html, '>' => \$ret,
	))->bind(sub { Data::Monad::AECV->unit($ret) });
})->recv, "\n";
