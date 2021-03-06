#!/usr/bin/perl

use strict;
use warnings;

use XML::Writer;

die "Usage: create_profile_from_metainfo.pl directory_with_tests [specified_test_name]\n" if $#ARGV < 0;

# Read directory contents
opendir DIR, $ARGV[0] or die "Can not open directory with tests\n";
my @files = grep { $_ = "$ARGV[0]/$_"; $_ if -f } readdir DIR;
closedir DIR;

# Begin XML
my $x = new XML::Writer(DATA_MODE => 1, DATA_INDENT => 1);
$x->startTag("tests");

foreach my $file (@files){
	my $type = +(split '/', $file)[-1];

	# Check for variables existence in metainformation
	open FD, "< $file";
	my $exist = grep { /^# VAR=/ } <FD>;
	close FD;
	next unless $exist;

	# Insert them into XML
	next if defined $ARGV[1] and $type ne $ARGV[1];
	$x->startTag("test", "id" => $type, "type" => $type);
	open FD, "< $file";
	map { $x->dataElement("var", "$2", "name" => $1) if /^# VAR=(.*):\w+:(.*):/ } <FD>;
	close FD;
	$x->endTag("test");
};
$x->endTag("tests");
print "\n";
