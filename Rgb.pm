package Color::Rgb;

require 5.003;
use strict;
use Carp;
use Fcntl;
use vars qw($RGB_TXT $VERSION);

$RGB_TXT = '/usr/X11R6/lib/X11/rgb.txt';
$VERSION = '1.1';

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        rgb_txt => $RGB_TXT,
        _rgb_map => {},
        @_,
    };

    sysopen (RGB, $self->{rgb_txt}, O_RDONLY) or carp "Color::Rgb->new(): $self->{rgb_txt} couldn't be read, $!";
    while ( <RGB> ) {
        /^\D/   and next;
        my ($r, $g, $b, $alias) = split /\s+/;
        $self->{_rgb_map}->{ lc($alias) } = [$r, $g, $b];
    }
    close RGB or carp "Color::Rgb::new(): $self->{rgb_txt} couldn't be closed, $!";

    return bless $self, $class;
}



sub rgb {
    my ($self, $alias, $delim) = @_;

    unless ( $alias ) {
        croak "Color::Rgb->rgb(): usage: rgb(\$alias [,\$delim]";
    }

    my @rgb = @{$self->{_rgb_map}->{$alias}};
    unless ( @rgb ) {   return undef    }
    if ( defined $delim ) { return join $delim, @rgb    }
    return @rgb;
}





sub hex {
    my ($self, $alias, $pound) = @_;
    unless ( $alias ) {
        croak "Color::Rgb->hex(): usage: hex(\$alias [,\$prefix]";
    }

    my ($r, $g, $b) = $self->rgb($alias);
    unless ( $r ) { return undef    }
    return sprintf("$pound%lx%lx%lx", $r, $g, $b);
}


sub hex2rgb {
    my ($self, $hex, $delim) = @_;

    unless ( $hex ) {
        croak "Color::Rgb->hex2rgb(): Usage: hex2rgb(\$hex [,\$delim]";
    }
    $hex =~ s/^(\#|Ox)//;
    $_ = $hex;
    my ($r, $g, $b) = m/(\w{2})(\w{2})(\w{2})/;
    my @rgb = ();
    $rgb[0] = hex($r);
    $rgb[1] = hex($g);
    $rgb[2] = hex($b);

    if ( $delim ) {return join $delim, @rgb}
    return @rgb;
}


sub rgb2hex {
    my ($self, $r, $g, $b, $pound) = @_;
    unless ( $b ) { croak "Color::Rgb->rgb2hex(): Usage: rgb2hex(\$red, \$green, \$blue [,\$prefix]"}
    return sprintf("$pound%lx%lx%lx", $r, $g, $b);
}




sub names {
    my ($self, $pat) = @_;

    my @names = ();
    while ( my ($name, $rgb) = each %{$self->{_rgb_map}} ) {
        $name =~ m/$pat/    and push @names, $name;
    }

    return @names;
}







1;

=pod

=head1 NAME

Color::Rgb - Perl extension for parsing your system's rgb.txt file.
If it doesn't exist, you  are still not out of luck, since it comes with an rgb.txt file itself that you can use

=head1 SYNOPSIS

    use Color::Rgb;
    $rgb = new Color::Rgb(rgb_txt=>'/usr/X11R6/lib/X11/rgb.txt');

    @rgb = $rgb->rgb('red');            # returns 255, 0, 0
    $red = $rgb->rgb('red', ',');       # returns the above rgb list as
                                        # comma separated string
    $red_hex=$rgb->hex('red');          # returns 'FF0000'
    $red_hex=$rgb->hex('red', '#');     # returns '#FF0000'

    $my_hex = $rgb->rgb2hex(255,0,0);   # returns 'FF0000'
    $my_rgb = $rgb->hex2rgb('#FF0000'); # returns list of 255,0,0

=head1 DESCRIPTION

Color::Rgb - simple rgb.txt parsing class. It will also help you to convert
rgb color values to hex and vice-versa.

=head1 METHODS

=over 4

=item *

C<new([rgb_txt=>$rgb_file])> - constructor method. Returns a Color::Rgb object. Optionally accepts
a path to the rgb.txt file. If you ommit the file, it will use the path
in the $Color::Rgb::RGB_TXT variable, which defaults to C<'/usr/X11R6/lib/X11/rgb.txt'>.
It means, instead of using rgb_txt=>'' option, you could also set the value of
the $Color::Rgb::RGB_TXT variable to the correct path before you call the L<new()> constructor
(but definitely after you load the Color::Rgb class with C<use> or C<require>).

Note: If your system does not provide with any rgb.txt file, Color::Rgb distribution
includes an rgb.txt file that you can use instead.


=item *

C<rgb($alias [,$delimiter])> - returns list of numeric Red, Green and Blue values for an $alias
delimited (optionally) by a $delimiter . Alias is represantation of the color in the
english language (Ex., 'black', 'red', 'purple' etc.,).

Examples,

    my ($r, $g, $b) = $rgb->rgb('blue'); # returns list: 00, 00, 255
    my $string      = $rgb->rgb('blue', ','); # returns string: '00,00,255'

But make sure that alias exists in the rgb.txt file, otherwise the method returns undef.

=item *

C<hex($alias [,$prefix])> - similar to L<rgb($alias)> method, but returns hexedecimal
string representing red, green and blue colors, prefixed (optionally) by $prefix.
Make sure that $alias exists in the rgb.txt file.

=item *

C<rgb2hex($r, $g, $b [,$prefix])> - converts rgb value to hexidecimal string. This method
has nothing to do with the rgb.txt file, so none of the arguments need to exist in the rgb.txt.

Examples,

    @rgb = (128, 128, 128);     # RGB represantation of grey
    $hex_grey = $rgb->rgb2hex(@rgb); # returns string 'C0C0C0'
    $hex_grey = $rgb->rgb2hex(@rgb, '#'); # returns string '#C0C0C0'

=item *

C<hex2rgb('hex' [,$delim])> - It's the oposite of L<rgb2hex()>: takes a hexidecimal represantation
of a color and returns a numeric list of Red, Green and Blue. If optional $delim delimiter is present,
it returns the string of RGB colors delimited by the $delimiter. Characters likst '#' and 'Ox' in the
begining of the hexidecimal value will be ignored. Examples:

    $hex = '#00FF00';   # represents blue

    @rgb = $rgb->hex2rgb($hex);  #returns list of 0, 255, 0
    $rgb_string = $rgb->hex2rgb($hex,','); #returns string '0,255,0'


Note: L<hex2rgb()> expects valid hexidecimal represantation of a color in 6 character long string.
If not, it might not work properly.

=item *

C<names([$pattern]> - returns a list of all the aliases in the rgb.txt file. If $pattern
is givven as the first argument, it will return only the names matching the pattern.
Example:

    @grey_colors = $rgb->names;         # returns all the names

    @grey_colors = $rgb->names('grey'); # returns list of all the names
                                            # matching the word 'grey'

=back

=head1 AUTHOR

Sherzod B. Ruzmetov <sherzodr@cpan.org>

=head1 SEE ALSO

L<Color::Object>

=cut
