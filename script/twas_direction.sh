################################################
#### TWAS for the direction of gene
#############################################

less ../database/HGNC/hgnc_complete_set.txt  250.2.meta.ukb.biovu.gtexv8_unmapped_all_genes.txt 

| perl -F"\t" -lane '$i++;if($i<=42676){@name=split("\\.",$F[19]);$hash{$name[0]}=$F[1]}else{if(exists $hash{$F[0]}) 

{ print join("\t",$F[0],$hash{$F[0]},@F[1..@F-1])} }' >250.2.txt


5. less 250.2.txt|egrep 'Muscle_Skeletal|Adipose_Subcutaneous|Adipose_Visceral_Omentum|Liver|Pancreas' |perl -lane '  if ($F[4]<0.05){ $hash{$F[1]}+=$F[2]/$F[3]; $hash2{$F[1]}++ ;}else{  $hash3{$F[1]}+=$F[2]/$F[3];

6. less genes.go.score.genescore 250.2.txt2 |perl -lane '$i++; if($i<=19449){$hash{$F[0]}=$F[1]}else{if(exists $hash{$F[0]}){print join("\t",$F[0],$hash{$F[0]},@F[1..@F-1]) }}' |sort -k2,2nr >250.2.txt3
   less genes.go.score.genescore 250.2.txt2 |perl -lane '$i++; if($i<=19449){if($F[1]>6){$F[1]=6} $hash{$F[0]}=$F[1]}else{if(exists $hash{$F[0]}){print join("\t",$F[0],$hash{$F[0]},@F[1..@F-1]) }}' |sort -k2,2nr >2




#4. 

less /data1/weiq1/databases20210723/HGNC/hgnc_complete_set.txt  /data1/zhongx/t2d-predixcan/250.2.meta.ukb.biovu.gtexv8_unmapped_all_genes.txt \

|perl -F"\t" -lane '$i++;if($i<=42676){@name=split("\\.",$F[19]);$hash{$name[0]}=$F[1]}else{if(exists $hash{$F[0]}) \
{print join("\t",$F[0],$hash{$F[0]},@F[1..@F-1])}}' >250.2.txt

#5. 

less 250.2.txt|egrep 'Muscle_Skeletal|Adipose_Subcutaneous|Adipose_Visceral_Omentum|Liver|Pancreas' \

|perl -lane 'if ($F[4]<0.05){ $hash{$F[1]}+=$F[2]/$F[3]; $hash2{$F[1]}++ ;} \

else{  $hash3{$F[1]}+=$F[2]/$F[3]; $hash4{$F[1]}++ ; }  \ 

if(eof()){ foreach my $key (keys %hash) {$flag=1; if($hash{$key}<0){$flag =-1} print join("\t",$key,$flag,$hash{$key},\

$hash2{$key},level1)}  foreach my $key (keys %hash3) {$flag=1; if($hash3{$key}<0){$flag =-1} \

if(!exists $hash{$key}){ print join("\t",$key,$flag,$hash3{$key},$hash4{$key},level2)}} }' >250.2.txt2 

#6. 
less genes.go.score.genescore 250.2.txt2 |perl -lane '$i++; if($i<=19449){$hash{$F[0]}=$F[1]}else{if(exists $hash{$F[0]}){print join("\t",$F[0],$hash{$F[0]},@F[1..@F-1]) }}' |sort -k2,2nr >250.2.txt3   

less genes.go.score.genescore 250.2.txt2 |perl -lane '$i++; if($i<=19449){if($F[1]>6){$F[1]=6} $hash{$F[0]}=$F[1]}else{if(exists $hash{$F[0]}){print join("\t",$F[0],$hash{$F[0]},@F[1..@F-1]) }}' \

|sort -k2,2nr >250.2.txt4
