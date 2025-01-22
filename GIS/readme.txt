##################
##final summary 12-03-2021
################
pwd : /data1/weiq1/result/T2D/rawdata/GWAS/Mahajan.NatGenet2018b/iRIGS_result.08102021

#############################################
### 1. the importance of genes
##############################################

Rscript ~/script/drug/iRiGs.new/Gibbs.R --SNP_file iRiGs.input.243.loci --flank 1000000 --res_path iRIGS_result.08102021 --res_pref T2D.genes20 --max_gene 20 --subRate 1 --seed 1500 --weightFile gtex.t2d.weights4

less T2D.genes20|perl -lane '$hash{$F[2]}++;if($hash{$F[2]}==1){print}' > T2D.genes20.first
perl /home/weiq1/script/databases/change-new-genename.pl -input T2D.genes20.first >T2D.genes20.first2
less T2D.genes20.first2 |grep failed

less T2D.genes20.first2 |grep -v fail |cut -f 2 |sort  |uniq >T2D.genes20.first2.uniq


1. less T2D.genes20.first2 /data1/weiq1/databases20210723/GO/gene2GO |perl -lane '$i++; if($i<=242){$hash{$F[1]}++}else{ if(exists $hash{$F[0]}){print}}' >go.tmp.a

   less T2D.genes20.first2 /data1/weiq1/databases20210723/Reactome/gene2Reactome |perl -lane '$i++; if($i<=242){$hash{$F[1]}++}else{ if(exists $hash{$F[0]}){print}}' >reactome.tmp.a

2. less /data1/weiq1/databases20210723/GO/GO.term.num go.tmp.a |perl -lane '$i++;if($i<=18581){$hash{$F[0]}=$F[1]}else{ if(exists $hash{$F[1]}){print join("\t",@F,$hash{$F[1]})}}' | perl -lane 'if(exists $hash{$F[1]}){ $hash{$F[1]}+=1/$F[2]}else{$hash{$F[1]}=1/$F[2]; $hash2{$F[1]} = $F[2] }  if(eof()){foreach $key  (keys %hash) {print join("\t", $key,$hash{$key},$hash2{$key} )} }' |sort -k1,1 > genes.go.score

3. less genes.go.score  /data1/weiq1/databases20210723/GO/gene2GO |perl -lane '$i++; if($i<=3500){$hash{$F[0]} = $F[1] }else{ $score=0; if(exists $hash{$F[1]}){ $score = $hash{$F[1]}} print join("\t",@F,$score) }' |perl -lane ' if(exists $hash{$F[0]}){$hash{$F[0]} += $F[2] }else{ $hash{$F[0]} = $F[2]} if(eof()){foreach $key (keys %hash){print join("\t",$key, $hash{$key})} }' |sort -k2,2nr > genes.go.score.genescore

################################################
#### 2. TWAS for the direction of gene
#############################################

4. less /data1/weiq1/databases20210723/HGNC/hgnc_complete_set.txt  /data1/zhongx/t2d-predixcan/250.2.meta.ukb.biovu.gtexv8_unmapped_all_genes.txt |perl -F"\t" -lane '$i++;if($i<=42676){@name=split("\\.",$F[19]);$hash{$name[0]}=$F[1]}else{if(exists $hash{$F[0]}){print join("\t",$F[0],$hash{$F[0]},@F[1..@F-1])}}' >250.2.txt

5. less 250.2.txt|egrep 'Muscle_Skeletal|Adipose_Subcutaneous|Adipose_Visceral_Omentum|Liver|Pancreas' |perl -lane '  if ($F[4]<0.05){ $hash{$F[1]}+=$F[2]/$F[3]; $hash2{$F[1]}++ ;}else{  $hash3{$F[1]}+=$F[2]/$F[3]; $hash4{$F[1]}++ ; }  if(eof()){ foreach my $key (keys %hash) {$flag=1; if($hash{$key}<0){$flag =-1} print join("\t",$key,$flag,$hash{$key},$hash2{$key},level1)}  foreach my $key (keys %hash3) {$flag=1; if($hash3{$key}<0){$flag =-1} if(!exists $hash{$key}){ print join("\t",$key,$flag,$hash3{$key},$hash4{$key},level2)}} }' >250.2.txt2

6. less genes.go.score.genescore 250.2.txt2 |perl -lane '$i++; if($i<=19449){$hash{$F[0]}=$F[1]}else{if(exists $hash{$F[0]}){print join("\t",$F[0],$hash{$F[0]},@F[1..@F-1]) }}' |sort -k2,2nr >250.2.txt3
   less genes.go.score.genescore 250.2.txt2 |perl -lane '$i++; if($i<=19449){if($F[1]>6){$F[1]=6} $hash{$F[0]}=$F[1]}else{if(exists $hash{$F[0]}){print join("\t",$F[0],$hash{$F[0]},@F[1..@F-1]) }}' |sort -k2,2nr >250.2.txt4

################################################
### L1000 top and bottom 80 genes
#############################################

7.  less 250.2.txt3 /data1/weiq1/databases20210723/L1000/rankMatrix.topdown80.genes |perl -lane '$i++; if($i<=14368){ $hash{$F[0]} = $F[1]*$F[2]; $hash2{$F[0]}=$F[5] } else{if(exists $hash{$F[0]}){ print join("\t",@F[0..2],$hash{$F[0]},$hash2{$F[0]},@F[3..@F-1])}}' > rankMatrix.topdown.genes2.all

8. less rankMatrix.topdown.genes2.all |perl -lane '$hash{$F[1]}+=$F[2]*$F[3];$hash2{$F[1]}++; if(eof()){ foreach $key (keys %hash){print join("\t",$key,$hash2{$key},$hash{$key}/$hash2{$key}) }} ' |sort -k3,3gr >rankMatrix.topdown.genes2.all.mean

9. less /data1/weiq1/databases20210723/L1000/compoundinfo_beta.720216.txt rankMatrix.topdown.genes2.all.mean |perl -F"\t" -lane '$i++;if($i<=720217){$hash{$F[0]}=join("\t",@F)}else{print join("\t",@F,$hash{$F[0]}) }' > topdown.genes2.all.mean.final2


#################################################
### distance between genes for network.
#############################################

11. less genes.go.score.genescore |sort -k1,1 >tmp.a

12. less genes.go.score /data1/weiq1/databases20210723/GO/GO.genepairs tmp.a |perl -lane '$i++; if($i<=3500){$hash{$F[0]} = $F[1] }elsif($i<=109597879){$num=0; for($k=2;$k<@F;$k++){if(exists $hash{$F[$k]}){$num+=$hash{$F[$k]}} }  $hash2{"$F[0]\t$F[1]"}=$num }else{$a[$i-109597879-1]=$F[0]  } if(eof()){for($k=0;$k<@a;$k++){for($k2=$k+1;$k2<@a;$k2++){ if (exists $hash2{"$a[$k]\t$a[$k2]"}){print join("\t",$a[$k],$a[$k2],$hash2{"$a[$k]\t$a[$k2]"})  }}  }   }' |sort -k3,3nr >T2D.specificity.allgenes.network

13. rm -rf tmp.a



##############################3
## plot network
##############################
##
 R
rm(list = ls())

library(visNetwork)
library(geomnet)
library(igraph)
library(dplyr)

 nodes <- read.table("~/Downloads/T2D.genes20.first2.uniq.network.top500.nodes", comment.char = "")
 nodes <- as.data.frame(nodes)
 colnames(nodes) <- c("id", "label", "value", "group","pathway", "color")
 nodes <- data.frame(nodes,color=nodes$group)

 nodes$color[nodes$color==1] = "red"
 nodes$color[nodes$color==0] = "grey"
 nodes$color[nodes$color==-1] = "green"

 set.seed(100)
 visNetwork(nodes, edges, width = "100%", height = "850px",) %>%
  visIgraphLayout() %>%
  visNodes(
    shape = "dot",
    color = list(
      background = "#0085AF",
      border = "#013848",
      highlight = "#FF8000"
    ),
    shadow = list(enabled = TRUE, size = 10)
  ) %>%
  visEdges(
    shadow = FALSE,
    color = list(color = "#0085AF", highlight = "#C62F4B")
  ) %>%
  visOptions(highlightNearest = list(enabled = T, degree = 1, hover = T),
             selectedBy = "group") %>% 
  visGroups(groupname = "1", color = "red", label="up") %>%
  visGroups(groupname = "-1", color = "green", label="down") %>%
  visGroups(groupname = "0", color = "grey", label="unknown") %>%
  visLegend(width = 0.1, position = "right", main = "Group") %>%
  visLayout(randomSeed = 11)


