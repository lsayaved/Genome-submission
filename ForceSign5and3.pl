#!/usr/bin/perl -w
use strict;


##This script adds the > and < sign removed from some of the cds start and end positions
##Script written by Lizbeth Sayavedra on the 21st Nov 16
###perl ForceSign5and3.pl Validate_error_file failed_embl out_new_embl


my $usage = "scriptname.pl VALIDATE_ERROR_file failed_EMBL out_embl";

my $val = shift or die $usage;  ##validation error file
my $embl = shift or die $usage;   ##the embl file
my $out = shift or die $usage;


my $line;
my @errors_cds5; my @errors_cds3;

my $locus_tag;
my $coord1; my $coord2; my $sign_c1; my $sign_c2;
my $flag=0;
my %pos;
my @pos_arr;
my $error_cds5; my $error_cds3;


open (FILE, $val);
open (OUT, '>', $out) or die "Could not create file '$out' $!";
while ($line =<FILE>){
    chomp $line;
    #$flag=1;
    if ($line =~ /Consider 5' partial location. line:\s+(\d+)/){
        $error_cds5=$1;
        #print "$error_cds5\n";
        push @errors_cds5, $error_cds5;
    }
    if ($line =~ /Consider 3' partial location. line:\s+(\d+)/){
        $error_cds3=$1;
        push @errors_cds3, $error_cds3;
    }
}
close (FILE);

my $ref; my $codon_start;


my $count=0;
my $count_plusone =1;
$flag=1; ##print embl unless error!
my $line_gene; my $line_locus; my $line_cds; my $line_to_fix;
my $int_flag=0;
my $bad_translation =0;
my $text1; my $text2;
my $pos1; my $pos2;
my $sign1; my $sign2;

open (FILE2, $embl);
while ($line =<FILE2>){
    $count++;
    $count_plusone ++;
    chomp $line;
    $flag=1;
    if (grep (/^$count$/, @errors_cds3)){
        print "On error from side 3 line $count\n";
        $flag=0;
        $line_cds = $line;
        if ($line_cds=~/(.*(\(|\s+))(<|>{0,1})(\d+)\.\.(<|>{0,1})(\d+)(\)*)/){        
            $text1=$1;
            $pos1 = $4;
            $pos2 = $6;
            $text2=$7;
            $sign1= $3 ;
            $sign2= $5;
                if ($text1=~/complement/) {
                    $line_cds= $text1 ."<".$pos1."..". $sign2. $pos2.")" ;
                    }
                else {
                    $line_cds= $text1 .$sign1. $pos1."..>".$pos2 ;
                }
        }
        print $line_cds."\n";
        print OUT $line_cds."\n";
    }
    if (grep (/^$count$/, @errors_cds5)){
        print "On error from side 5 line $count\n";
        $flag=0;
        $line_cds = $line;
        if ($line_cds=~/(.*(\(|\s+))(<|>{0,1})(\d+)\.\.(<|>{0,1})(\d+)(\)*)/){        
            $text1=$1;
            $pos1 = $4;
            $pos2 = $6;
            $text2=$7;
            $sign1= $3 ;
            $sign2= $5;
                if ($text1=~/complement/) {
                   $line_cds= $text1 . $sign1. $pos1."..>".  $pos2.")" ;
                    }
                else {
                    $line_cds= $text1 ."<". $sign1. $pos1."..".$sign2. $pos2 ;
                }
        }
        print OUT $line_cds."\n";
        print $line_cds."\n";
    }
    if ($flag==1){
        print OUT "$line\n";
    }
}
close (FILE2);
close (OUT);
