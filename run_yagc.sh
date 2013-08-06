#!/bin/bash

# verbosity, this writes extra logging to STDERR, increment as '-v' or '-v -v'
VERBOSE=

# gff3 directory, must NOT exist if the intention is to re-explode the GFF3
GFF3DIR=gff3

# directory for tbl and fasta files
TBLDIR=tblfasta
if [ ! -d $TBLDIR ]; then
	mkdir -p $TBLDIR
fi

# validation directory, contains val reports, ASN.1 output (and genbank files)
ASN1DIR=asn1val
if [ ! -d $ASN1DIR ]; then
	mkdir -p $ASN1DIR
fi

# the source of the annotations we include in the output, optional, this
# corresponds with column 2 in the GFF3
SOURCE=maker

# prefix below which to generate locus tags, should be registered as bioproject
PREFIX=L345_

# input genome
FASTA=king_cobra_scaffolds_spring_2011.fasta

# input annotation file
GFF3=cobra.functional.gff

# extra metadata to include in the fasta header lines
INFO=info.ini

# namespace below which to scope protein and transcript IDs
AUTHORITY='gnl|NaturalisBC|'

# limit number of written scaffolds, for testing
LIMIT=

# discrepancy report file, compare with https://www.ncbi.nlm.nih.gov/genbank/asndisc
DISCREP=discrep.txt

# the submission template as produced by http://www.ncbi.nlm.nih.gov/WebSub/template.cgi
TEMPLATE=template.sbt

# explode the annotations into files 
if [ ! -d $GFF3DIR ]; then	
	mkdir -p $GFF3DIR
	perl explode_gff3.pl -gff3 $GFF3 -source $SOURCE -f CDS -f gene -f five_prime_UTR \
		-f three_prime_UTR -d $GFF3DIR
fi

# create the table and fasta files
perl yagc.pl -d $TBLDIR -s $SOURCE -p $PREFIX -f $FASTA -g $GFF3DIR \
 	-i $INFO -a $AUTHORITY -l $LIMIT $VERBOSE 

# create the genbank and validation files
tbl2asn -p $TBLDIR -t $TEMPLATE -M n -a r10k -l paired-ends -r $ASN1DIR -Z $DISCREP -V b