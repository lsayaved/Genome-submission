# Compendium of my bioinformatic scripts
This repository contains bioinformatic scripts without any warranty!

## Genome submission to EMBL
- Use of [Sequin](https://www.ncbi.nlm.nih.gov/Sequin/) to produce an EMBL file for genome submission. The input files are the result of GenDB
  *.tbl file
  *fasta file
  
###### Errors during the genome submission 
The EMBL validator somehow missed some of the following errors
```
Wed Oct 12 09:48:17 BST 2016   USER  ERROR: No stop codon at the 3' end of the CDS feature translation. Consider 3' partial location.
```
To fix it, I used the script [AddSign.pl](https://github.com/lsayaved/Hello-World/blob/master/AddSign.pl)
