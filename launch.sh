#!/bin/bash

if [ -z $(which tmux) ]
then
    echo -e "\e[31mERROR: install tmux first\e[39m"
    exit 1
fi

ARCH=resnet50
MY_NAME=my_${ARCH,,}
DATASET_DIR=/data1/hanguangyun/data/pytorch/caltech256/256_ObjectCategories

cd runtime/image_classification

tmux kill-session -t "pipestream" || true
tmux new -d -s "pipestream"
for i in {0..2}; do tmux split-window -t "pipestream" -d ; done

for i in {0..3}
do
    tmux send -t "pipestream.$i" "python main_with_runtime.py --module models.${MY_NAME}.gpus=4 -b 32 --data_dir ${DATASET_DIR} --rank ${i} --local_rank ${i} --master_addr localhost --config_path models/${MY_NAME}/gpus=4/mp_conf.json --distributed_backend gloo" C-m
done
