#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;
use File::Find;
use File::Spec;

# Options
my $_verbose;
my $_help;
my $_size;
my $_hash;
my $_dots = 50;
GetOptions(
    "verbose" => \$_verbose,
    "help" => \$_help,
    "size" => \$_size,
    "dots=i" => \$_dots,
) or die "Error in command line arguments\n";

# Help
if ($_help) {

    print "Usage: $0 [OPTIONS] DIR1 DIR2\n";
    print "\n";
    print "Options:\n";
    print "  --help                print this help\n";
    print "  --verbose             verbose output\n";
    print "  --size                compare files by size\n";
    print "\n";
    print "Example:\n";
    print "  \$ $0 -s tmpdir1/ snapshots/hourly.0/\n";
    print "  < IMG_2780.JPG\n";
    print "  M food/es\n";
    print "  > IMG_2755.JPG\n";
    print "\n";

    exit;
}

# Directories to be compared
if (@ARGV < 2) {
    die "Not enough arguments: Need two directories\n";
}
elsif (@ARGV > 2) {
    die "Too many arguments: Need two directories\n";
}
my ($dir1, $dir2) = @ARGV;
if (! -d $dir1) {
    die "No such directory: $dir1\n";
}
if (! -d $dir2) {
    die "No such directory: $dir2\n";
}

# Cut off trailing slash
my $dir1_name = File::Spec->catdir($dir1);
my $dir2_name = File::Spec->catdir($dir2);

# File maps and scan routine
my ($map1, $map2, $diff_list) = ({}, {}, []);
my $scanner = sub {
    my ($in, $file) = @_;
    my ($dir, $other_dir, $map, $other_map) = $in == 1 ?
        ($dir1_name, $dir2_name, $map1, $map2) :
        ($dir2_name, $dir1_name, $map2, $map1);

    # Skip search directory
    if (File::Spec->catdir($file) eq $dir) {
        if ($_verbose) {
            warn "Scanning directory: $file\n";
        }
        return;
    }

    # Fix relative file path (remove search dir)
    if (substr($file, 0, length($dir)) eq $dir) {
        $file = substr($file, length($dir) + 1);
    }

    # Stat this file
    my $path = File::Spec->catfile($dir, $file);
    my $other_path = File::Spec->catfile($other_dir, $file);
    my @stat = stat($path);
    if (!@stat) {
        warn "Failed to stat $path\n";
        return;
    }

    # Stat other file
    $map->{$file} = \@stat;
    my @other_stat = exists($other_map->{$file}) ?
        @{$other_map->{$file}} : stat($other_path);
    if ($_verbose) {
        warn "Checking file $file: $path / $other_path\n";
    }

    # Look for file in other dir
    my $found = -e $other_path;
    my ($size, $other_size) = ($stat[7] // 0, $other_stat[7] // 0);
    my $match = $found;
    if ($_size) {
        # Compare the size
        $match = $match && $size == $other_size;
    }
    if (!$found) {
        my $pre = $in == 1 ? '< ' : '> ';
        print "$pre$file\n";
    }
    elsif ($found && !$match) {
        if (!grep({$_ eq $file} @$diff_list)) {
            push @$diff_list, $file;
            my $pre = 'M ';
            print "$pre$file\n";
        }
    }
};

# Scan directories
find({ wanted => sub { $scanner->(1, $_); }, no_chdir => 1}, $dir1);
find({ wanted => sub { $scanner->(2, $_); }, no_chdir => 1}, $dir2);

