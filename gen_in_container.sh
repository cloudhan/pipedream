#!/bin/bash

set -ex

THIS_DIR=$(dirname $0)
THIS_DIR=$(realpath ${THIS_DIR})

# there should be folder ${DATASET_DIR}/train ${DATASET_DIR}/val
DATASET_DIR=/data1/hanguangyun/data/pytorch/caltech256/256_ObjectCategories

ARCH=resnet50
BATCHSIZE=64
NUM_GPU=4

MY_NAME=my_${ARCH,,}


################################ profiling stage ################################
cd ${THIS_DIR}/profiler/image_classification

CUDA_VISIBLE_DEVICES=0 \
python main.py -a ${ARCH} -b ${BATCHSIZE} --data_dir ${DATASET_DIR}


################################ optimize stage 1 ################################
cd ${THIS_DIR}/optimizer
python optimizer_graph_hierarchical.py -f ../profiler/image_classification/profiles/${ARCH}/graph.txt -n ${NUM_GPU} --activation_compression_ratio 1 -o ${MY_NAME}


################################ optimize stage 2 ################################
cd ${THIS_DIR}/optimizer
num_gpu_minus_one=$(python -c "print(${NUM_GPU} - 1)")
mkdir -p ../runtime/image_classification/models/${MY_NAME}

python convert_graph_to_model.py \
    -f ${MY_NAME}/gpus=${NUM_GPU}.txt \
    -n ${MY_NAME} \
    -a ${ARCH} \
    -o ../runtime/image_classification/models/${MY_NAME}/gpus=${NUM_GPU} \
    # --stage_to_num_ranks 0:${num_gpu_minus_one},1:1
