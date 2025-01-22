###!/bin/bash


LN=$(wc -l hrg_2|perl -lane 'print $F[0]')

less hrg_2 database/GO/gene2GO |perl -slane '$i++; if( $i<=$x){ $hash{$F[1]}++ }else{ if( exists $hash{$F[0]} ) {print} }' -- -x=$LN  > go.tmp.a
