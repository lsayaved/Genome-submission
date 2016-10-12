#!/usr/bin/perl -w
use strict;


##This script adds the > and < sign removed from some of the cds start and end positions
##the error displayed in the validation file is the following:
##No stop codon at the 3' end of the CDS feature translation. Consider 3' partial location.
##Protein coding feature length must be a multiple of 3. Consider 5' or 3' partial location.
##This script was written by Lizbeth Sayavedra 12.Oct.16


my $usage = "scriptname.pl VALIDATE_file failed_EMBL tbl_file out";

my $val = shift or die $usage;  ##validation error file
my $embl = shift or die $usage;   ##the embl file
my $tbl = shift or die $usage;  ##original file.tbl used for the embl file
my $out = shift or die $usage;
#my $out2 = shift or die $usage;

my $line;
my @errors_gene; my @errors_cds; my @errors_locus;

my $locus_tag;
my $coord1; my $coord2; my $sign_c1; my $sign_c2;
my $flag=0;
my %pos;
my @pos_arr;
my $error_gene; my $error_cds; my $error_locus;


open (FILE, $val);
open (OUT, '>', $out) or die "Could not create file '$out' $!";
#open (OUT2, '>', $out2) or die "Could not create file '$out2' $!";
while ($line =<FILE>){
    chomp $line;
    #$flag=1;
    if ($line =~ /line:\s+(\d+)/){
        $error_gene=$1-2;
        $error_locus= $1 -1;
        $error_cds=$1;
        #print "$1\n";
        push @errors_gene, $error_gene;
        push @errors_locus, $error_locus;
        push @errors_cds, $error_cds;
    }
}
close (FILE);


open (FILE3, $tbl) or die "Can't open '$tbl': $!";;
while ($line =<FILE3>){
    if ($line =~ /locus_tag\t(\S+)/){
        $locus_tag= $1;      
    }
    if ($line =~ /(<|>{0,1})(\d+)\t(<|>{0,1})(\d+)\tCDS/){
    $sign_c1=$1;
    $coord1 = $2;
    $sign_c2 = $3;
    $coord2= $4;
        if ($coord2>$coord1){
        @pos_arr = ($sign_c1, $coord1, $sign_c2, $coord2);
        $pos{$locus_tag} = [@pos_arr];
        }
    elsif ($coord1>$coord2){
        @pos_arr = ( $sign_c2, $coord2, $sign_c1, $coord1);
        $pos{$locus_tag} = [@pos_arr];
    }
    
    }

}
close (FILE3);
 
####Just for printing  the locus tag positions
my $locus;
my $out_pos =$out."locus_pos.txt";
open (OUT_LOCUS, '>', $out_pos) or die "Could not create file '$out_pos' $!";
for $locus (keys %pos){
    print OUT_LOCUS "$locus\t$pos{$locus}[0] $pos{$locus}[1]\t$pos{$locus}[2] $pos{$locus}[3]\n";
}
close (OUT_LOCUS);

my $count=0;
my $count_plusone =1;
$flag=1; ##print embl unless error!
my $line_gene; my $line_locus; my $line_cds; my $line_to_fix;
my $int_flag=0;
my $bad_translation =0;


open (FILE2, $embl);
while ($line =<FILE2>){
    $count++;
    $count_plusone ++;
    chomp $line;
    $flag=1;
    if (grep (/^$count$/, @errors_gene)){ ##script starts scanning section with error
        $flag=0;
        $line_gene =$line;
        $int_flag=0;
        #print "gene\t".$line_gene."\n";
    }
    if (grep (/^$count$/, @errors_locus)){ ##script starts scanning section with error
        $flag=0;
        $line_locus =$line;
        $int_flag=0;
        #print "locus\t".$line_locus."\n";
    }
    if (grep (/^$count$/, @errors_cds)){
        $flag=0;
        $line_cds = $line;
        $int_flag=1; ##rewrites the screwed section
        #print "cds\t".$line_cds."\n";
    }
    if ($int_flag==1){   
        $line_to_fix =$line_cds;
        if ($line_locus=~/(.*\/locus_tag=\")(\S+)\"/){        
        $locus =$2;
        #print "locuslocus$locus\n";
        }
        if ($line_gene=~/(.*(\(|\s+))(\d+)\.\.(\d+)(\)*)/){        
        $line_gene = $1. $pos{$locus}[0].$pos{$locus}[1]. ".." .$pos{$locus}[2] .$pos{$locus}[3].$5;
        }    
        if ($line_cds=~/(.*(\(|\s+))(\d+)\.\.(\d+)(\)*)/){        
        $line_cds = $1. $pos{$locus}[0].$pos{$locus}[1]. ".." .$pos{$locus}[2] .$pos{$locus}[3].$5;
        }
    print "FIXED line $count of $locus:\n$line_to_fix\n$line_cds\n";
    print OUT "$line_gene\n$line_locus\n$line_cds\n"; 
    $int_flag=0;
        if (index ($line_cds, $line_to_fix) != -1)   {  ##if the script didn't fix anything:
            print "NOT FIXED line $count of $locus:\n$line_to_fix\n$line_cds\n". $pos{$locus}[0]. $pos{$locus}[1]. ".." . $pos{$locus}[2] . $pos{$locus}[3] ."\n";
            $bad_translation=1; ### 
        }
    }
    if ($flag==1){
        print OUT "$line\n";
    }
}
close (FILE2);
close (OUT);
