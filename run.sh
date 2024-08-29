#!/bin/bash

DATAROOT=./data/

seqs=( "09" "10" )
datasets=($(ls $DATAROOT))

for seq in ${seqs[@]}
do
    for dataset in ${datasets[@]}
    do
        cmd="sh script/run_mulls_slam.sh $seq $dataset"
        echo $cmd
        eval $cmd
    done
done