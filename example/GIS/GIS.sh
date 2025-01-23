#############################################
### importance score of genes
##############################################

##1. read in the output from iRIGS, pick the "rank1 gene" (hrg) from each locus/region, and update gene names if necessary  

file1="$1"

less  $file1 | perl -lane '$hash{$F[2]}++;if($hash{$F[2]}==1){print}' > hrg

perl script/change-new-genename.pl -input hrg > hrg_2

##2. numerate hrgs per GO term   
 
LN=$(wc -l hrg_2|perl -lane 'print $F[0]')

less hrg_2 database/GO/gene2GO |perl -slane '$i++; if( $i<=$x){ $hash{$F[1]}++ }else{ if( exists $hash{$F[0]} ) {print} }' -- -x=$LN  > go.tmp.a


##3.## calculate scores for GO terms

LN=$(wc -l database/GO/GO.term.num |perl -lane 'print $F[0]')

less database/GO/GO.term.num go.tmp.a |perl -slane '$i++; if( $i<=$x ){ $hash{$F[0]}=$F[1] } else{ if(exists $hash{$F[1]} ){ print join("\t",@F,$hash{$F[1]})}}' -- -x=$LN | perl -lane 'if( exists $hash{$F[1]} ){ $hash{$F[1]}+=1/$F[2] } else{ $hash{$F[1]}=1/$F[2]; $hash2{$F[1]} = $F[2] }if( eof() ){ foreach $key (keys %hash) { print join("\t", $key,$hash{$key},$hash2{$key} ) } }'|sort -k1,1 > go.score
  

##4.## calculate GIS based on go term scores

LN=$(wc -l go.score |perl -lane 'print $F[0]')

less go.score database/GO/gene2GO | perl -slane '$i++; if( $i<=$x ) { $hash{$F[0]} = $F[1] } else{ $score=0; if( exists $hash{$F[1]} ) { $score = $hash{$F[1]} } print join("\t",@F,$score) }'  -- -x=$LN | perl -lane ' if( exists $hash{$F[0]} ) { $hash{$F[0]} += $F[2] } else{ $hash{$F[0]} = $F[2] } if(eof()){foreach $key (keys %hash){print join("\t",$key, $hash{$key})} }' |sort -k2,2nr > output_gis

### move files into a temporary folder ##

if [ ! -d "myrun" ]; then
	mkdidr myrun 
fi

mv output_gis myrun/
mv hrg hrg_2 go.tmp.a go.score myrun/
