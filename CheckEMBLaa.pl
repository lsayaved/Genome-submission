#!/usr/bin/env perl -w
use strict;
use Bio::SeqIO;
use Bio::SeqFeature::Generic;
no warnings;


##This script checks which proteins were predicted wrong by Sequin using the faa file produced by gendb

#perl CheckEMBLaa.pl validation_report corrupted.embl ../21Oct/LSA_bathym.faa out.embl

my $usage = "scriptname.pl validation embl IN_FAA out";

my $val = shift or die $usage; 
my $embl = shift or die $usage;  
my $faa = shift or die $usage;
my $out= shift or die $usage; 

my $line; my $flag_corrupted =0; my @locus_corrupted;
open (FILE, $val);
while ($line =<FILE>){
    chomp $line;
    #$flag=1;

    if ($line =~ /^ERROR: ^[The protein translation of the protein coding feature contains internal sto]/){ $flag_corrupted=0;} 
    if ($line =~ /The protein translation of the protein coding feature contains internal stop codons/){ $flag_corrupted=1; }
    #print "$flag_corrupted $line\n";
    if ($flag_corrupted==1) {
      if ($line =~ /Curator message\:\s+locus tag = (\S+)/){
       #print "CORRUPTED $1 \n\n\n";
       push @locus_corrupted, $1;
      }
    }
    
}
close (FILE);

foreach my $val (@locus_corrupted){ print "CORRUPTED $val \n\n\n";}


my $in; my $in_embl;
    $in  = Bio::SeqIO->new(-file => $faa ,
                           -format => 'fasta');

    $in_embl  = Bio::SeqIO->new(-file => $embl ,
                           -format => 'embl');


##Creates has with locus tag as key to the hash, sequence is the value of the hash
   my %seqs;
     while( my $seq = $in->next_seq() ) {
        $seqs{$seq-> id} = $seq->seq;
   }

   my %seqs_embl;
   my $loc; my $loc_temp; my $product;
   while( my $seq = $in_embl->next_seq() ) {

      for my $feat_object ($seq->get_SeqFeatures) {
             if ($feat_object->has_tag("translation")){
               for $loc ( $feat_object->get_tag_values("locus_tag")){
               $loc_temp =$loc;
               }#print $loc_temp, "\n";
               for my $value ( $feat_object->get_tag_values("translation")){
               $seqs_embl{$loc_temp}= $value;
               #print "    value: ", $value, "\n";
               }
               
            }
      }
   }

foreach my $loc (keys %seqs_embl) {
   if ($seqs_embl{$loc} !~ $seqs{$loc}){
      print $loc."\n". $seqs_embl{$loc}. "\n". $seqs{$loc}. "\n"
      }
}

print "************************\n\n";


##I won't use bioperl to read the embl file because it changes the format back to a version that is not accepted by EMBL

#my $line;
my $locus; my $flag_trans=0; my $force_cont; my $flag=1;
open (OUT, '>', $out) or die "Could not create file '$out' $!";
open (FILE2, $embl);
while ($line =<FILE2>){
   chomp $line;
   #$flag=1;
   if ($line=~/(.*\/locus_tag=\")(\S+)\"/){        
      $locus =$2;
      #print "locuslocus$locus\n";
      if (($seqs_embl{$locus} !~ $seqs{$locus}) && (grep (/^$locus$/, @locus_corrupted))){
         $flag_trans=1;
         print "$locus has in embl the sequence  $seqs_embl{$locus} and in faa $seqs{$locus}\n\n";
      }
      if ($seqs_embl{$locus} =~ $seqs{$locus}){$flag_trans=0;}
   }

   if ($flag_trans==1){
      if ($line =~/FT.*\/.*/){ $flag=1}
      if ($line=~/^XX/){ $flag=1 }
      if ($line=~/^FT\s+(gene|tRNA|rRNA)\s+\S+/){ $flag=1}
      if ($line=~/(.*codon_start=)2/){$line = $1."1"; }  ##only for complement
      if ($line=~/(.*\/translation=\")(\S+)\"*/){        
         $flag=0; ##don't print
         $flag_trans=1;
         #print "output in file". $1."$seqs{$locus}\"\n";
         print OUT $1."$seqs{$locus}\"\n";
         
      }
   }
   
   if ($flag==1){
        print OUT "$line\n";
    }
}

close (FILE2);
close (OUT);
