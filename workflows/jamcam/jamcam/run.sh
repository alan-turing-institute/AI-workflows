#!/bin/sh
# RUN ALL

# Setup environment
# export KEY=dmRsbmY0dXZpdXNqYjl1dXZ2a2tvaG90cHA6NTRjZGE3ZjktNzliNy00ZTk5LWFhZDgtYzQ2NWQxN2Q0YWEx ## !! key is private
# export USER_EXPERIMENT_DIR=/workspace/yolo_v4
# export DATA_DOWNLOAD_DIR=/workspace/data
# export SPECS_DIR=/workspace/yolo_v4/specs
# export LOCAL_SPECS_DIR=/workspace/yolo_v4/specs
# export LOCAL_PROJECT_DIR=/workspace

# Run verify data is in accessible locations and in correct format
python3 verify.py

# Generate validation dataset
python3 ../ssd/generate_val_dataset.py --input_image_dir=$LOCAL_DATA_DIR/train/images \
                                        --input_label_dir=$LOCAL_DATA_DIR/train/labels \
                                        --output_dir=$LOCAL_DATA_DIR/val

# Tune bounding box
yolo_v4 kmeans -l $LOCAL_DATA_DIR/train/labels \
                    -i $LOCAL_DATA_DIR/train/images \
                    -n 9 \
                    -x 352 \
                    -y 288

# Convert to tao yolo_v4 dataset formats 
yolo_v4 dataset_convert -d $SPECS_DIR/yolo_v4_tfrecords_jamcam_train.txt -o $DATA_DOWNLOAD_DIR/train/tfrecords/train

yolo_v4 dataset_convert -d $SPECS_DIR/yolo_v4_tfrecords_jamcam_val.txt -o $DATA_DOWNLOAD_DIR/val/tfrecords/val 

# generate output locations
mkdir -p $LOCAL_EXPERIMENT_DIR/experiment_dir_unpruned

# Training
## To run with multigpu, please change --gpus based on the number of available GPUs in your machine.
yolo_v4 train -e $SPECS_DIR/yolo_v4_train_resnet18_jamcam.txt \
                   -r $USER_EXPERIMENT_DIR/experiment_dir_unpruned \
                   -k $KEY \
                   --gpus 1

# Evaluation
yolo_v4 evaluate -e $SPECS_DIR/yolo_v4_train_resnet18_jamcam.txt \
                      -m $USER_EXPERIMENT_DIR/experiment_dir_unpruned/weights/yolov4_resnet18_epoch_$EPOCH.tlt \
                      -k $KEY

# Visualisation
yolo_v4 inference -i $DATA_DOWNLOAD_DIR/test_samples \
                       -o $USER_EXPERIMENT_DIR/yolo_infer_images \
                       -e $SPECS_DIR/yolo_v4_retrain_resnet18_kitti.txt \
                       -m $USER_EXPERIMENT_DIR/experiment_dir_retrain/weights/yolov4_resnet18_epoch_$EPOCH.tlt \
                       -l $USER_EXPERIMENT_DIR/yolo_infer_labels \
                       -k $KEY

# Model export
yolo_v4 export -m $USER_EXPERIMENT_DIR/experiment_dir_retrain/weights/yolov4_resnet18_epoch_$EPOCH.tlt \
                    -k $KEY \
                    -o $USER_EXPERIMENT_DIR/export/yolov4_resnet18_epoch_$EPOCH.etlt \
                    -e $SPECS_DIR/yolo_v4_retrain_resnet18_kitti.txt \
                    --batch_size 16 \
                    --data_type fp32