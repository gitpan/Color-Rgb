use Test;

use Color::Rgb;
ok(1);

my $rgb = new Color::Rgb(rgb_txt=>'rgb.txt');


ok($rgb->rgb('red', ','), '255,0,0');
ok($rgb->rgb2hex(255,255,255, '#'), '#ffffff');
ok($rgb->hex2rgb('#cccccc', ','), '204,204,204');
ok(scalar ($rgb->rgb('grey') ), 3);


my @names = $rgb->names('grey');

ok(@names);

BEGIN { plan tests => 6 };	
