#!/usr/bin/perl -w
use strict;
##This script fixes moves the locus tag before the translation

my $usage = "scriptname.pl original_EMBL >out_file";


my $embl = shift or die $usage;   ##the embl file
#my $tbl = shift or die $usage;  ##original file.tbl used for the embl file
#my $out = shift or die $usage;
#my $out2 = shift or die $usage;


my $line;

open (FILE, $embl);
#open (OUT, '>', $out) or die "Could not create file '$out' $!";
#open (OUT2, '>', $out2) or die "Could not create file '$out2' $!";
my $temp=""; my $flag=0; my $cds= ""; my $passed_trans=0; my $passed_locus=0; my $temp2=""; my $activate_fix=0;
while ($line =<FILE>){
    chomp $line;

    if ($line=~ /FT   CDS             /){
	$flag=0;
	$passed_trans=0;
	$passed_locus=0 ;
	$temp2="";
    }
    if ($flag==0){
	$cds =$cds . $line ;
	if ($line =~ /FT                   \/translation=.*/){
	 $passed_trans=1;
	}
	if ($line =~ /FT                   \/locus_tag=.*/){
	$passed_locus=1 ;
	}
	if (($passed_locus==1) && ($passed_trans==0)){ ##nothing to fix
	    $activate_fix =0;
	}
	
	if (($passed_locus==0) && ($passed_trans==1)){ ##needs to keep in a temporal variable the translation and all the rest until locus appears
	    $temp2 = $temp2. $line . "\n";
	    $activate_fix =1;
	}
	if ($activate_fix==0){
	    print $line."\n";
	}
	if (($passed_locus==1) && ($passed_trans==1) && ($activate_fix==1)){ ##needs to keep in a temporal variable the translation and all the rest until locus appears
	    print $line . "\n" . $temp2 ;
	    $activate_fix =0;
	}
    }
    if ($line =~/^XX/){$flag=1;}

    if ($flag==1) {
	print $line."\n";
    }

}
close (FILE);