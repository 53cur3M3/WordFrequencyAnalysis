#!/usr/bin/perl
use strict;
use warnings;

# Perform a word-frequency analysis on one or more texts
# Author: Paul Beckett
# Source: https://github.com/53cur3M3/WordFrequencyAnalysis
# 
# Syntax: ./WordFreqAnalysis.pl <text-1> .. <text-n>

# Supported sort types:
#   ALPHA : Alphabetical sort by word
#   FREQ  : Sort by word frequency
my $SORT = 'ALPHA';
my $STRIP_PATTERN='[\s,\.:;_()[\]?\'"`’!]+';
# Supported LOWERCASE values:
#   1 : convert all words to lowercase: Away => away
#   0 : Case sensitive: Away != away
my $LOWERCASE=1;
# Supported IGNORE_NUMBERS_INPUT values:
#   0 : Include numeric values in word frequency statistics
#   1 : Exclude numeric values in word frequency statictics
my $IGNORE_NUMBERS_INPUT=1;
# Supported IGNORE_NUMBERS_OUTPUT values:
#   0 : Include numeric values in output
#   1 : Exclude numeric values from output
my $IGNORE_NUMBERS_OUTPUT=1;

my $DEBUG = 80;

my @files;
my %textsByFile;
my %textsByWord;
my %wordCount;

my %merge = ( 'children' => '__child',
	      'child' => '__child',
	      'accident' => '__accident',
              'accidental' => '__accident',
              'accidentally' => '__accident',
              'accidents' => '__accident',
      );


foreach my $file ( @ARGV ) {
	if ( ! -e $file ) {
		die "$file does not exist\n";
	}
	if ( ! -f $file ) {
		die "$file is not a file\n";
	}
	push @files, $file;
	print "Loading.... $file";
	open (INFILE, "<$file") or die "Unable to open $file\n$!\n";

	while ( my $line = <INFILE> ) {
		# Remove new-lines
		chomp $line;

		# Remove hypens surrounded by whitespace
		$line =~ s/ -+ / /g;

		# Remove punctuation
		#$line =~ s/[\s,\.:;_()[\]?'"`’!]+/ /g;
		$line =~ s/$STRIP_PATTERN/ /g;

		# Skip blank lines
		next if $line =~ /^\s*$/;

		# Check for non-alphanumerics
		if ( $line !~/^[A-Za-z0-9- ]*$/ ) {
			warn "Stripping additional non-alphanumerics [$line]\n" if $DEBUG > 99;
			$line =~ s/[^A-Za-z0-9- ]+//g;
		}

		# Remove leading spaces:
		$line =~ s/^\s*//g;
		# Remove leading hyphens:
		$line =~ s/^-+//g;
		# Remove trailing spaces:
		$line =~ s/\s*$//g;

		# Check for non-alphanumerics 2
		#if ( $line !~/^[A-Za-z0-9- ]*$/ ) {
		#	warn "SECOND Stripping additional non-alphanumerics [$line]\n";
		#	$line =~ s/[^A-Za-z0-9- ]+//g;
		#}

		# Split line into words:
		foreach my $word ( split /\s+/, $line ) {
			next if $word =~ /^\s*$/;
			next if $word =~ /^\d+$/ && $IGNORE_NUMBERS_INPUT > 0;
			$word = lc($word) if $LOWERCASE > 0;
			warn "WORD: [$word]\n" if $DEBUG > 9999;
			$textsByFile{$file}{$word}++;
			$textsByWord{$word}{$file}++;
			if (defined($merge{$word})) {
				warn "Merging $word : $merge{$word}\n" if $DEBUG > 80;
				$textsByFile{$file}{$merge{$word}}++;
				$textsByWord{$merge{$word}}{$file}++;
			}
			$wordCount{$file}++;
		}
		warn "[$line]\n" if $DEBUG > 999;
	}
	close (INFILE);
	print "... Done\n";
}


if ( $SORT eq 'ALPHA' ) {
	warn "Alpha Sort\n" if $DEBUG > 10;

	# print Header
	print "Word\t" . (join "\t", @files) . "\n";

	foreach my $word ( sort keys %textsByWord ) {
		next if $word =~ /^\d+$/ && $IGNORE_NUMBERS_OUTPUT > 0;
		print "$word\t";
		#print ">$word<\t";
		foreach my $file ( @files ) {
			print defined($textsByWord{$word}{$file}) ? "$textsByWord{$word}{$file}\t" : "-\t";
		}
		print "\n";
		#print "x";
		#foreach my $word ( sort keys %texts{$col} )
	}

	# print Totals
	print "\nTOTAL\t";
	foreach my $file (@files) {
		print "$wordCount{$file}\t";
	}
}
if ( $SORT eq 'FREQ' ) {
	warn "Word Frequency Sort\n" if $DEBUG > 10;

	# print Header
	print "Word\t" . (join "\t", @files) . "\n";

}
