package Vss2Svn::SvnRevHandler;

use warnings;
use strict;

our(%gCfg);

$gCfg{revtimerange} = 3600;

###############################################################################
#  new
###############################################################################
sub new {
    my($class) = @_;

    my $svncache = Vss2Svn::DataCache->new('SvnRevision', 1);

    if (!defined($svncache)) {
        print "\nERROR: Could not create cache 'SvnRevision'\n";
        return undef;
    }

    my $self =
        {
         svncache => $svncache,
         revnum => undef,
        };

    $self = bless($self, $class);

    $self->_init();
    return $self;

}  #  End new

###############################################################################
#  _init
###############################################################################
sub _init {
    my($self) = @_;

    $self->{timestamp} = undef;
    $self->{author} = undef;
    $self->{comment} = undef;
    $self->{seen} = {};

}  #  End _init

###############################################################################
#  check
###############################################################################
sub check {
    my($self, $data) = @_;

    my($physname, $timestamp, $author, $comment) =
        @{ $data }{qw( physname timestamp author comment )};
    my($prevtimestamp, $prevauthor, $prevcomment) =
        @{ $self }{qw( timestamp author comment )};

    no warnings 'uninitialized';
    if(($author ne $prevauthor) || ($comment ne $prevcomment) ||
       $self->{seen}->{$physname}++ ||
       ($timestamp - $prevtimestamp > $gCfg{revtimerange})) {

        @{ $self }{qw( timestamp author comment)} =
            ($timestamp, $author, $comment);
        $self->new_revision();

        if ($self->{verbose}) {
            print "\n**** NEW SVN REVISION ($self->{revnum}): ",
                join(',', $physname, $timestamp, $author, $comment), "\n";
        }

    }

}  #  End check

###############################################################################
#  new_revision
###############################################################################
sub new_revision {
    my($self) = @_;

    $self->{svncache}->add( @{ $self }{qw(timestamp author comment)} );
    $self->{revnum} = $self->{svncache}->{pkey};

}  #  End new_revision

###############################################################################
#  commit
###############################################################################
sub commit {
    my($self) = @_;

    $self->{svncache}->commit();
}  #  End commit

###############################################################################
#  SetRevTimeRange
###############################################################################
sub SetRevTimeRange {
    my($class, $range) = @_;

    $gCfg{revtimerange} = $range;
}  #  End SetRevTimeRange


1;