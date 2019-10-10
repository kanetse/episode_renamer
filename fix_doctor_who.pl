#!/usr/bin/perl

use strict;
use File::Copy;

my $basepath = "/mediastore/plex/TV/Doctor Who (1963)";

my @episodeskiplist = (
	'Doctor Who - S01E04 (004) - Marco Polo (0) - Intro.avi',
	'Doctor Who - S01E08 (008) - The Reign of Terror (7) - Outro.avi',
	'Doctor Who - S02E06 (014) - The Crusade (0a) - Intro by Julian Glover.avi',
	'Doctor Who - S02E06 (014) - The Crusade (0b) - Intro by William Russell.avi',
	'Doctor Who - S02E06 (014) - The Crusade (1a) - Summary of E1 by Julian Glover.avi',
	'Doctor Who - S02E06 (014) - The Crusade (2a) - Summary of E2 by William Russell.avi',
	'Doctor Who - S02E06 (014) - The Crusade (3a) - Summary of E3 by Julian Glover.avi',
	'Doctor Who - S02E06 (014) - The Crusade (4a) - Summary of William Russell.avi',
	'Doctor Who - S02E06 (014) - The Crusade (5a) - Outro by Julian Glover.avi',
	'Doctor Who - S05E03 (039) - The Ice Warriors (2) (Fan made animation).avi',
	'Doctor Who - S05E03 (039) - The Ice Warriors (2+3) (BBC Recon).avi',
	'Doctor Who - S05E03 (039) - The Ice Warriors (3) (Fan made animation).avi',
	'Doctor Who - S09E01 (060) - Day of the Daleks (1) (Special Edition).avi',
	'Doctor Who - S09E01 (060) - Day of the Daleks (2) (Special Edition).avi',
	'Doctor Who - S09E01 (060) - Day of the Daleks (3) (Special Edition).avi',
	'Doctor Who - S09E01 (060) - Day of the Daleks (4) (Special Edition).avi',
	'Doctor Who - S11E02 (071) - Invasion of the Dinosaurs (1) (BW).avi',
	'Doctor Who - S20E05 (127) - Enlightenment (Special Edition).avi',
	'Doctor Who - S20E07 (129) - The Five Doctors (1) (Special Edition).avi',
	'Doctor Who - S20E07 (129) - The Five Doctors (1) (Transmission Version).avi'
	);

{
	opendir(BASEPATH, $basepath) || die "Unable to open path: [$basepath]: $!\n";
	my @basepath_filelist = readdir(BASEPATH);
	foreach my $curr_basepath_filename (sort @basepath_filelist) {
		print "Found file: [" . $curr_basepath_filename . "]";

		my $basepathfile_fullpath = "$basepath/$curr_basepath_filename";

		if (-f $basepathfile_fullpath) {
			print "... is a file.";
		} elsif (-d $basepathfile_fullpath) {
			if ($basepathfile_fullpath =~ m/^\./) { next; }
			
			print "... is a directory.";
			if ($basepathfile_fullpath =~ m/^Doctor Who - (S\d\d)/) {
				# This is an episode directory
				my $season = $1;
				print ".. from season $season.";

				my $seasondir_fullpath = "$basepath/$season";

				if (!-e $seasondir_fullpath) {
					# The season directory does not already exist, create it
					mkdir($seasondir_fullpath);
					print "... creating $seasondir_fullpath";
				}
				
				move($basepathfile_fullpath, "$seasondir_fullpath/$curr_basepath_filename");
			} elsif ($curr_basepath_filename =~ m/^S(\d\d)$/) {
				# This is a season folder
				
				my $seasonnum = $1;
				
				print " " . $curr_basepath_filename . " is a season folder.\n";
				my $seasondir_fullpath = "$basepath/$curr_basepath_filename";
				my $episodenum = 1;
				
				opendir(SEASONPATH, $seasondir_fullpath) || die "Unable to open season path: [$seasondir_fullpath]: $!\n";
				my @episodedir_filelist = readdir(SEASONPATH);
				foreach my $curr_seasondir_filename (@episodedir_filelist) {
					if ($curr_seasondir_filename =~ m/^\./) { next; }
					my $episodedir_fullpath = "$seasondir_fullpath/$curr_seasondir_filename";
					
					if (!-d $episodedir_fullpath) {
						if ($episodedir_fullpath !~ m/.pdf/) {
							move($episodedir_fullpath, $episodedir_fullpath . ".avi");
						}
						next;
					}
					opendir(EPISODEPATH, $episodedir_fullpath) || die "Unable to open episode path: $episodedir_fullpath]: $!\n";
					my @episodedir_filelist = readdir(EPISODEPATH);
					foreach my $curr_episodedir_filename (sort @episodedir_filelist) {
						if ($curr_episodedir_filename =~ m/^\./) { next; }
						my $episodefile_fullpath = "$episodedir_fullpath/$curr_episodedir_filename";
						
						if ($curr_episodedir_filename =~ m/ Bonus/) { 
							# skip bonus episodes don't increment episode number
							next; 
						}
						
						if ($curr_episodedir_filename !~ m/\.avi/) { 
							# skip non-avi files
							print "Skipped: $curr_episodedir_filename.\n";
							next; 
						}
						
						if ( grep { $_ eq $curr_episodedir_filename} @episodeskiplist ) {
							print "Skipped: $curr_episodedir_filename.\n";
							next; 
						}
						
						if ($curr_episodedir_filename =~ m/ Intro/) {
							print "Skipped: $curr_episodedir_filename.\n";
							next;
						}
						if ($curr_episodedir_filename =~ m/Outro/) {
							print "Skipped: $curr_episodedir_filename.\n";
							next;
						}

						my $episodenewfile_fullpath = $episodedir_fullpath;
						my $newcode = "S" . $seasonnum . "E" . sprintf "%02d", $episodenum;
						$episodenewfile_fullpath =~ s/S\d\dE\d\d/$newcode/;
						print "Video file [$episodefile_fullpath] => [$episodenewfile_fullpath]\n";
						#move($episodefile_fullpath, $episodenewfile_fullpath);
						$episodenum++;
						#print "\n";
					}
					
					closedir(EPISODEPATH);
				}
				closedir(SEASONPATH);
				
				print "Season [$seasonnum] : Episode count [" . ($episodenum-1) ."]\n";
				if ($curr_basepath_filename =~ m/S99/) { last; }
				
			} else {
				print ".. Not a match.";
			}
		}
		
		print "\n";
	}
	closedir (BASEPATH);
}