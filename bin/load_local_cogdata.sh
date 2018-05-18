#!/bin/bash

for dir in C*_whogs
do
    #echo $dir
    #chrom=$(echo $dir | sed -E 's/(C[0-9]{1,3})\..+/\1/')
    chrom=$(echo $dir | sed -E 's/(C[[:digit:]]{1,3})\..+/\1/')
    echo "Refmol: "$chrom
    echo "whogs: " $dir
    rtn=$(cog_load_local_whog.pl $dir)
    echo "finished loading whogs: $rtn"
    echo "loading missing whogs"
    missing=$(ls ${chrom}.whogs_missing_*)
    echo "missing: "$missing
    rtn=$(cog_load_local_missing.pl ${missing})
    echo "finished loading missing whogs: $rtn"
    echo "loading unique whogs"
    unique=$(ls ${chrom}.whogs_unique_*)
    echo "unique: "$unique
    rtn=$(cog_load_local_novel.pl ${unique})
    echo "finished loading unique whogs: $rtn"
    echo
done


