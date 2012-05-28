#!perl

use utf8;
use strict;
use warnings 'FATAL';

use IO::File;
use IO::String;
use Test::More tests => 8;

use Config::INI::Reader;


# Check the structure of the config
my $expected = {
  '_' => {
    'écrivain' => 'Olivier Mengué',
  },
  'Section n°1' => {
    1 => 'déchaînées',
    2 => 'déchaînèrent',
    3 => 'à-côté',
    4 => 'cœur',
  },
};

{
  # Try to read in a config
  my $hashref = Config::INI::Reader->read_file( 'corpus/utf8.ini', 'utf-8' );
  isa_ok($hashref, 'HASH', "return of Config::INI::Reader->read_file");
  is_deeply($hashref, $expected, 'utf8');
}

{
  my $hashref = Config::INI::Reader->read_file( 'corpus/utf16-bom.ini', 'utf-16' );
  isa_ok($hashref, 'HASH', "return of Config::INI::Reader->read_file");
  is_deeply($hashref, $expected, 'utf16 with bom');
}

# Add some stuff to the trivial config and check write_string() for it
my $expected2 = {
    _ => {
	'écrivain' => 'Olivier Mengué',
    },
    'Cœur' => {
	'Clé' => 'κλειδί',
    },
};

my $string = <<END;
écrivain=Olivier Mengué

[ Cœur ]
Clé = κλειδί

END

{ # Test read_string
  my $hashref = Config::INI::Reader->read_string( $string );
  isa_ok($hashref, 'HASH', "return of Config::INI::Reader->read_string");

  is_deeply( $hashref, $expected2, '->read_string returns expected value' );
}

{ # Test read_handle
  my $fh = IO::File->new('corpus/utf8.ini', 'r');
  $fh->binmode(':utf8');
  my $data = do { local $/ = undef; <$fh> };

  is_deeply(
    Config::INI::Reader->new->read_handle( IO::String->new($data) ),
    $expected,
    '->read_handle returns expected value'
  );
}

{ # Test read_handle
  my $fh = IO::File->new('corpus/utf16-bom.ini', 'r');
  $fh->binmode(':encoding(utf-16)');
  my $data = do { local $/ = undef; <$fh> };

  is_deeply(
    Config::INI::Reader->new->read_handle( IO::String->new($data) ),
    $expected,
    '->read_handle returns expected value'
  );
}


