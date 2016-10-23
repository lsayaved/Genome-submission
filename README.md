# Compendium of my bioinformatic scripts
This repository contains bioinformatic scripts without any warranty!

## Genome submission to EMBL
- Use [Sequin](https://www.ncbi.nlm.nih.gov/Sequin/) to produce an EMBL file for genome submission. As input files for Sequin, I used the tbl and the fasta file produced by [GenDB](https://www.uni-giessen.de/fbz/fb08/Inst/bioinformatik/software/gendb)

  
###### Errors during the genome submission 
The EMBL validator somehow missed some of the following errors
```
Wed Oct 12 09:48:17 BST 2016   USER  ERROR: No stop codon at the 3' end of the CDS feature translation. Consider 3' partial location.
```
To fix it, I used the script [AddSign.pl](https://github.com/lsayaved/Hello-World/blob/master/AddSign_1.pl)

Sequin translated some of the first amino acid with an M, EMBL requires the real translation. The error is the following:
```
ERROR: Expected and conceptual translations are different. line: 2068 of
```
The script [CheckConceptual.pl](https://github.com/lsayaved/Hello-World/blob/master/CheckConceptual.pl) should do the trick

Some of the translations were predicted wrong because the tbl file had the wrong codon start. The error is the following

```
ERROR: The protein translation of the protein coding feature contains internal stop codons
```
The script [CheckEMBLaa.pl](https://github.com/lsayaved/Hello-World/blob/master/CheckEMBLaa.pl) should do the trick
