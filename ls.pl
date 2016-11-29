##################################################################################
# The MIT License (MIT)                                                          #
#                                                                                #
# Copyright (c) 2016 Chris 'CJ' Jones                                            #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal  #
# in the Software without restriction, including without limitation the rights   #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
# copies of the Software, and to permit persons to whom the Software is          #
# furnished to do so, subject to the following conditions:                       #
#                                                                                #
# The above copyright notice and this permission notice shall be included in all #
# copies or substantial portions of the Software.                                #
#                                                                                #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #
# SOFTWARE.                                                                      #
##################################################################################
package ls;

use Getopt::Std;
use Cwd;
use Win32::File qw(GetAttributes ARCHIVE COMPRESSED DIRECTORY HIDDEN NORMAL OFFLINE READONLY SYSTEM TEMPORARY);
use File::stat;
use Time::localtime;
my @months = qw("Jan", "Feb", "May", "Mar", "Apr", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");

use warnings;

use Data::Dumper;

my $dir = getcwd;
my @file_list;
my %opts;

getopts("aAbBcCdDfFgGhHiIklLopQrRsStTuUvwxXZ1", \%opts);

sub scan {
	@out = ();
	
	opendir(my $dh, $dir);
	
	$i = 0;
	while (readdir $dh) {
	    @out[$i++] = $_;
	}

	closedir $dh;
	
	return @out;
}

sub option_l {
	my ($filename, $attributes) = @_;
	my $is_dir = 0;
	
	$out = "";
	
	if ($file_attributes & DIRECTORY) {
		$is_dir = 1;
		$out .= "d";
	} else {
		$out .= "-";
	}
	
	$out .= "r";
	
	if ($file_attributes & READONLY) {
		$out .= "-";
	} else {
		$out .= "w";
	}
	
	if (-x $dir . "/" . $filename) {
		$out .= "x";
	} else {
		$out .= "-";
	}
	
	# ToDo
	# my @timestamp;
	# if ($is_dir) {
	# 	my $win_dir = $dir;
	# 	$win_dir =~ s/\//\\/g;
	# 	my @stats = stat $win_dir;
	# 	@timestamp = localtime($stats[9]);
	# } else {
	# 	my $epoc_time = (stat($dir . "/" . $filename))[9];
	# 	@timestamp = localtime($epoc_time);
	# }
	# my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = @timestamp;
	# $out .= " " . $mon . " " . $mday . " " . $hour . ":" . $min;
	
	print "\n";
	$out .= " $filename\n";
	
	return $out;
}

sub render {
	my (@files) = @_;
	foreach $filename (@files) {
		GetAttributes($filename, $file_attributes);
		
		if ((substr($filename, 0, 1) eq ".") || ($file_attributes & HIDDEN)) {
			if ($opts{'a'}) {
				# Do nothing.
			} else {
				next;
			}
		}
		
		if ($opts{'l'}) {
			$filename = option_l($filename, $file_attributes);
		}
		
		if ($filename) {
			print "$filename ";
		}
	}
}

@file_list = scan();

render(@file_list);
