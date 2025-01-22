#bash GIS.sh ../example/iRIGS/output/T2D

file1="$1"

less  $file1 | perl -lane '$hash{$F[2]}++;if($hash{$F[2]}==1){print}' > hrg

perl script/change-new-genename.pl -input hrg > hrg_2

##less hrg_2  |grep -v fail |cut -f 2 |sort  |uniq > hrg.name.uniq


# get the lines
LN=$(wc -l hrg_2|perl -lane 'print $F[0]')

less hrg_2 database/GO/gene2GO |perl -slane '$i++; if( $i<=$x){ $hash{$F[1]}++ }else{ if( exists $hash{$F[0]} ) {print} }' -- -x=$LN  > go.tmp.a

less hrg_2 database/Reactome/gene2Reactome |perl -slane '$i++; if( $i<=$x ){ $hash{$F[1]}++ }else{ if( exists $hash{$F[0]} ){print} }' -- -x=$LN > reactome.tmp.a


##2.## 

LN=$(wc -l database/GO/GO.term.num |perl -lane 'print $F[0]')

less database/GO/GO.term.num go.tmp.a |perl -slane '$i++; if( $i<=$x ){ $hash{$F[0]}=$F[1] } else{ if(exists $hash{$F[1]} ){ print join("\t",@F,$hash{$F[1]})}}' -- -x=$LN | perl -lane 'if( exists $hash{$F[1]} ){ $hash{$F[1]}+=1/$F[2] } else{ $hash{$F[1]}=1/$F[2]; $hash2{$F[1]} = $F[2] }if( eof() ){ foreach $key (keys %hash) { print join("\t", $key,$hash{$key},$hash2{$key} ) } }'|sort -k1,1 > go.score
  

##3.## calculate GIS and rank the score from the largest to the smallest

LN=$(wc -l go.score |perl -lane 'print $F[0]')

less go.score database/GO/gene2GO | perl -slane '$i++; if( $i<=$x ) { $hash{$F[0]} = $F[1] } else{ $score=0; if( exists $hash{$F[1]} ) { $score = $hash{$F[1]} } print join("\t",@F,$score) }'  -- -x=$LN | perl -lane ' if( exists $hash{$F[0]} ) { $hash{$F[0]} += $F[2] } else{ $hash{$F[0]} = $F[2] } if(eof()){foreach $key (keys %hash){print join("\t",$key, $hash{$key})} }' |sort -k2,2nr > output_gis

