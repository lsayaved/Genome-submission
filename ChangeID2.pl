#!/usr/bin/perl -w
use strict;


#!/usr/bin/perl -w
#use strict;
##This script was created to change the ID part of the EMBL file as requested by datasub (email from 6.Jun16)
##Example perl CombineEMBL.pl  BazSymA.embl BazSymA_LSA_bazNoriR.embl BAZScaffoldsToINCLUDE.csv BaySzmA_missing.embl BazSymA_NM1.embl BazSymA_NM2.embl BazSymA_SUB.embl
my $usage = "scriptname.pl EMBL out locus_tag genome_name \nlists need o have the same idenitifers\n";
my $EMBL = shift or die $usage;
my $out = shift or die $usage;
my $locus_tag = shift or die $usage;
my $genome= shift or die $usage;;

my $flag=0;
my $scaff;

open (FILE, $EMBL);
open (OUT, '>', $out) or die "Could not create file '$out' $!";

while (my $line =<FILE>){
    chomp $line;
    ###standard gbk to embl file produced from RAST download, for Geneious export, use non-stricit format
    if (($line =~ /ID   (\S+)\|\S+\;.*/) || ($line=~ /ID\s+(NODE_\S+).*/ ) ){
    $scaff = $1;
    $flag=0;
    print OUT "ID   XXX; XXX; linear; XXX; XXX; XXX; XXX.\n";
    print OUT "XX\nAC   \;\nXX\nAC \* _". $scaff . "\n" . "PR   Project:PRJEB17996;\nXX\nDE   c\.\nXX\n"; #####Change the project
    }

    
    if ($line =~/.*Contig.*B.*/){ ####Change the Genome
        $flag=1;
        #$line= "OS   SOX symbiont of B. puteoserpentis.\n" .
        $line= "OS   SOX symbiont of B. $genome.\n" .
        "OC   Unclassified.\nXX\nRN   \[1\]\nRA   Sayavedra L., Ansorge R., Dubilier N., Petersen J.M.;\nRT   \"Comparative genomic insights into the roles of toxin-related genes in beneficial bacteria and their acquisition by horizontal gene transfer\"\;\n" .
"RL   Unpublished\.\n" .
"XX\nRN   \[2\]\nRA   Sayavedra L., Ansorge R., Dubilier N., Petersen J.M.;\nRT   ;\nRL   Submitted \(22-NOV-2016\) to the EMBL/GenBank/DDBJ databases\.\nRL   MPI Bremen\n".
"XX\nCC   ##Assembly-Data-START##\nCC   Assembly Method       :: SPades\nCC   Sequencing Technology :: Illumina HiSeq\nCC   ##Assembly-Data-END##";
    }
      
    if ($line=~/(.*)db_xref\=\"SEED\:fig\|6666666\.\S+\.peg\.(\S+)\"/){
        $line = $1. "locus_tag\=\"" . $locus_tag . "_". $2 . "\"\nFT                   \/transl_table=11"; }
        if ($line=~/(.*)db_xref\=\"SEED\:fig\|6666666\.\S+\.rna\.(\S+)\"/){
        $line = $1. "locus_tag\=\"" . $locus_tag . "_". $2 . "\""; }
    if (($line=~/FT                   \/db_xref="taxon: 6666666"/) || ($line=~/roject="\S+_6666666"/) || ($line=~/\/genome_id="6666666/)|| ($line=~ /genome_md5/) || ($line=~/DE   Ass5Gapfilled800/)){
        next;
    }
    if ($line =~/(.*\s+  )RNA (.*)/){$line=$1."rRNA".$2; }
    
    if ($line=~/>\/\//){
        print OUT "$line\n";
        $flag=0;
    }
    if ($flag==1){
        print OUT "$line\n";
    }
    
}


close (OUT);
close (FILE);

