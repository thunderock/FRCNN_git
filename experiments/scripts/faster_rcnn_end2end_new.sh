#!/bin/bash
# Usage:
# ./experiments/scripts/faster_rcnn_end2end_new.sh GPU NET DATASET [options args to {train,test}_net.py]
# DATASET is (either pascal_voc or coco or) building.
#
# Example:
# ./experiments/scripts/faster_rcnn_end2end_new.sh 0 VGG16 building

set -x
set -e

export PYTHONUNBUFFERED="True"

GPU_ID=$1
NET=$2
NET_lc=${NET,,}
DATASET=$3

array=( $@ )
len=${#array[@]}
EXTRA_ARGS=${array[@]:3:$len}
EXTRA_ARGS_SLUG=${EXTRA_ARGS// /_}

TRAIN_IMDB="building_train"
TEST_IMDB="building_test"
PT_DIR="building"
ITERS=70000	

LOG="experiments/logs/faster_rcnn_end2end_new_${NET}_${EXTRA_ARGS_SLUG}.txt.`date +'%Y-%m-%d_%H-%M-%S'`"
exec &> >(tee -a "$LOG")
echo Logging output to "$LOG"

time python ./tools/train_net.py --gpu ${GPU_ID} \
  --weights data/pretrain_model/VGG_imagenet.npy \
  --imdb ${TRAIN_IMDB} \
  --iters ${ITERS} \
  --cfg experiments/cfgs/faster_rcnn_end2end_new.yml \
  --network VGGnet_train \
  ${EXTRA_ARGS}

set +x
NET_FINAL=`grep -B 1 "done solving" ${LOG} | grep "Wrote snapshot" | awk '{print $4}'`
set -x

#time python ./tools/test_net.py --gpu ${GPU_ID} \
#  --weights ${NET_FINAL} \
#  --imdb ${TEST_IMDB} \
#  --cfg experiments/cfgs/faster_rcnn_end2end_new.yml \
#  --network VGGnet_test \
#  ${EXTRA_ARGS}
