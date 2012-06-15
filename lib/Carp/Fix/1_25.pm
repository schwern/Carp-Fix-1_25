package Carp::Fix::1_25;

# Smooth over the formatting change to Carp messages in Carp 1.25.

use strict;
use warnings;

our $VERSION = '1.000000';

require Carp;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(confess carp croak);
our @EXPORT_OK = qw(cluck verbose longmess shortmess);
our @EXPORT_FAIL = qw(verbose);

*verbose = \&Carp::verbose;

# Pass through to Carp 1.25 or higher, it works
if( $Carp::VERSION && $Carp::VERSION >= 1.25 ) {
    *carp       = \&Carp::carp;
    *croak      = \&Carp::croak;
    *cluck      = \&Carp::cluck;
    *confess    = \&Carp::confess;

    *longmess   = \&Carp::longmess;
    *shortmess  = \&Carp::shortmess;
}
# Bypass to our fixes.
else {
    *carp       = \&Carp::Fix::1_25::Fixed::carp;
    *croak      = \&Carp::Fix::1_25::Fixed::croak;
    *cluck      = \&Carp::Fix::1_25::Fixed::cluck;
    *confess    = \&Carp::Fix::1_25::Fixed::confess;

    *longmess   = \&Carp::Fix::1_25::Fixed::longmess;
    *shortmess  = \&Carp::Fix::1_25::Fixed::shortmess;
}


package Carp::Fix::1_25::Fixed;

# Tell Carp not to report our wrappers.
$Carp::Internal{"Carp::Fix::1_25::Fixed"}++;

# Put in the dot
sub _fix_carp_msg {
    ${$_[0]} =~ s{at (.*?) line (\d+)\n}{at $1 line $2.\n}g;
    return;
}


sub shortmess {
    my $msg = Carp::shortmess(@_);

    _fix_carp_msg(\$msg);

    return $msg;
}

sub longmess {
    my $msg = Carp::longmess(@_);

    _fix_carp_msg(\$msg);

    return $msg;    
}


sub carp {
    return warn shortmess(@_);
}

sub croak {
    return die shortmess(@_);
}

sub cluck {
    return warn longmess(@_);
}

sub confess {
    return die longmess(@_);
}

1;

__END__

=head1 NAME

Carp::Fix::1_25 - Smooth over incompatible changes in Carp 1.25

=head1 SYNOPSIS

    use Carp::Fix::1_25;

    carp  "This will have a period at the end, like die";
    croak "No matter what version of Carp you have installed";

=head1 DESCRIPTION

Carp 1.25 made a change to its formatting, adding a period at the end
of the message.  This can mess up tests and code that are looking for
error messages.  Carp::Fix::1_25 exports its own carp functions which
change the Carp message to match the 1.25 version regardless of what
version of Carp you're using.

Carp::Fix::1_25 otherwise acts exactly like Carp and it will honor
L<Carp global variables|Carp/GLOBAL VARIABLES> such as C<@CARP_NOT>
and C<%Carp::Internal>.

Why do this instead of just upgrading Carp?  Upgrading Carp would
affect all installed code all at once.  You might not be ready for
that, or you might not want your module to foist that on its users.
This lets you fix things one namespace at a time.

=head1 SEE ALSO

L<Carp>