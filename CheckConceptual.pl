#!/usr/bin/perl -w
use strict;
##This script fixes the error "ERROR: Expected and conceptual translations are different"
## It uses the error report output from the embl validator version 
##perl ../../CheckConceptual.pl Part2_fix6.val.reports.txt  LSA_bathym_step7_pat2_fix6.embl  LSA_bathym_step7_pat2_fix7.embl

my $usage = "scriptname.pl VALIDATE_reports.txt failed_EMBL";

my $val = shift or die $usage;  ##validation error file
my $embl = shift or die $usage;   ##the embl file
#my $tbl = shift or die $usage;  ##original file.tbl used for the embl file
my $out = shift or die $usage;
#my $out2 = shift or die $usage;

my $line;
my @errors_gene; my @errors_cds; my @errors_locus; my @errors_codon;

my $locus_tag;
my $coord1; my $coord2; my $sign_c1; my $sign_c2;
my $flag=0;
my %seqs_val;
my @pos_arr;
my $error_gene; my $error_cds; my $error_locus; my $error_codon;
my $flag_corrupted=0; my @locus_corrupted;
my $count=0;
my $locus;
my $modify_seq;

open (FILE, $val);
#open (OUT, '>', $out) or die "Could not create file '$out' $!";
#open (OUT2, '>', $out2) or die "Could not create file '$out2' $!";
while ($line =<FILE>){
    chomp $line;
    #print $count . $line . "\n";

    if ($line =~ /^ERROR: ^[Expected and conceptual translations are different]/){ $flag_corrupted=0; $count = -10000;   }
    if ($line =~ /END message report/){ $flag_corrupted=0; }
    if ($line =~ /ERROR: Expected and conceptual translations are different/){ $flag_corrupted=1; $count = -10000;  }
    #print "$flag_corrupted $line\n";
    if ($flag_corrupted==1) {
      if ($line =~ /Curator message\:\s+locus tag = (\S+)/){
       #print "CONCEPTUAL TRANSLATION $1 \n";
       #push @locus_corrupted, $1;
        $locus = $1;
        $count = -100;
      }
    }
    if ($line =~  /The amino acid codes immediately below the dna triplets/){
        $count =0;
    }
    $count++;
    #print $count . $line . "\n";
    if (($count == 5) & ($flag_corrupted==1)) {
        $line =~ s/\s+//g ;
        #print $locus ."\t". $line . "\n";
        $seqs_val{$locus}= $line;
        }
}
close (FILE);

my $flag_trans=0; my $force_cont; $flag=1; my $temp_seq;
open (OUT, '>', $out) or die "Could not create file '$out' $!";
open (FILE2, $embl);
while ($line =<FILE2>){
   chomp $line;
   $flag=1;
   if ($line=~/(.*\/locus_tag=\")(\S+)\"/){        
      $locus =$2;
        ##add if the locus tag is in the list of sequences that were interpreted wrong 
        if (exists $seqs_val {$locus}){
            $flag_trans=1;
        }
        else {$flag_trans=0;}
   }

   if ($flag_trans==1){
      if ($line=~/(.*\/translation=\")(\S+)\"*/){        
         $flag=0; ##don't print
         $modify_seq =$2; ##sequence to modify
         print "$line" ."\n";
         $temp_seq = $seqs_val{$locus};
         my $z = substr ($modify_seq, 0, 1);
         my $aa = substr ($temp_seq, 0, 1);
         print "First aa is $z and should be $aa \n";
         for (substr $modify_seq, 0, 1) { $_ = $aa;} ##substitutes the first aa that was predicted wrong to the aa that is now correct
         $line =$1.$modify_seq;
         $flag_trans=1;
         print "$line" ."\n\n";
         print OUT $line."\n";
      }
   }
   
   if ($flag==1){
        print OUT "$line\n";
    }
}

close (FILE2);
close (OUT);