less ./iRIGs_t2d/output | perl -lane '$hash{$F[2]}++;if($hash{$F[2]}==1){print}' > hrg

##################################
#### check gene names of t2d_hrg
##################################
perl script/change-new-genename.pl -input hrg > hrg_2

# get the lines
LN=$(wc -l hrg_2)

less hrg_2  |grep -v fail |cut -f 2 |sort  |uniq > hrg.name.uniq


less hrg_2 database/GO/gene2GO.txt |perl -slane '$i++; if( $i<=$x){ $hash{$F[1]}++ }else{ if( exists $hash{$F[0]} ) {print} }' -- -x=$LN  > go.tmp.a

less hrg_2 database/Reactome/gene2Reactome |perl -slane '$i++; if( $i<=$x ){ $hash{$F[1]}++ }else{ if( exists $hash{$F[0]} ){print} }' -- -x=$LN > reactome.tmp.a


##2.## 

less /data1/weiq1/databases20210723/GO/GO.term.num go.tmp.a |perl -lane '$i++;if($i<=18581){$hash{$F[0]}=$F[1]}else{ if(exists $hash{$F[1]}){print join("\t",@F,$hash{$F[1]})}}' | perl -lane 'if(exis

less ./database/GO/GO.term.num go.tmp.a |perl -lane '$i++;if($i<=18581){$hash{$F[0]}=$F[1]}

else{ if(exists $hash{$F[1]}){print join("\t",@F,$hash{$F[1]})}}'

| perl -lane 'if(exists $hash{$F[1]}){ $hash{$F[1]}+=1/$F[2]}else{$hash{$F[1]}=1/$F[2]; $hash2{$F[1]} = $F[2] } 

 if(eof()){foreach $key  (keys %hash) {print join("\t", $key,$hash{$key},$hash2{$key} )} }' |sort -k1,1 > go.score


##3.## 

less go.score ./database/GO/gene2GO | perl -lane '$i++; 
if( $i<=3500 ) { $hash{$F[0]} = $F[1] } else{ $score=0; if( exists $hash{$F[1]} ) { $score = $hash{$F[1]} } print join("\t",@F,$score) }' \ 
|perl -lane ' if(exists $hash{$F[0]}){$hash{$F[0]} += $F[2] }else{ $hash{$F[0]} = $F[2]} \

if(eof()){foreach $key (keys %hash){print join("\t",$key, $hash{$key})} }' |sort -k2,2nr > GIS


