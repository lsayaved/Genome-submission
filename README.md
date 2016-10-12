# Compendium of my bioinformatic scripts
This repository contains bioinformatic scripts mainly written in Perl without any warranty!

## Genome submission to EMBL
-Use of Sequin to produce an EMBL file for genome submission (the input files are the result of GenDB: a .tbl file and a fasta file) The EMBL validator somehow missed some of the following errors
```
Wed Oct 12 09:48:17 BST 2016   USER  ERROR: No stop codon at the 3' end of the CDS feature translation. Consider 3' partial location.
```
To fix it, I used the script [AddSign.pl](https://github.com/lsayaved/Hello-World/blob/master/AddSign.pl)
