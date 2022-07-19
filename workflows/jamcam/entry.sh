#!/bin/bash
# ---
# Entrypoint for jamcam workflow, requires execution within suitable container. See README
# ---

# ---
# Comment out the below to skip directory creation for attaching workspace volume
# ---
mkdir -p /workspace/data/ /workspace/specs/ /workspace/yolo_v4/specs/

# ---
#  Uncomment the below to override environment variables
# ---
# export USER_EXPERIMENT_DIR=/workspace/yolo_v4
# export DATA_DOWNLOAD_DIR=/workspace/data
# export SPECS_DIR=/workspace/specs
# export LOCAL_SPECS_DIR=/workspace/yolo_v4/specs
# export LOCAL_PROJECT_DIR=/workspace

func_download(){
	echo "Downloading model and datasets..."
	/bin/bash download_data.sh
	mkdir -p "$DATA_DOWNLOAD_DIR/train/images" \
			 "$DATA_DOWNLOAD_DIR/train/labels_raw" \
			 "$DATA_DOWNLOAD_DIR/test/images" \
			 "$DATA_DOWNLOAD_DIR/test/labels_raw"
	unzip "$DATA_DOWNLOAD_DIR/task_jamcams_groundtruth.zip" -d jamcams_data &&
	(cd "$DATA_DOWNLOAD_DIR/jamcams_data/data/obj_train_data/" &&
	find . -wholename '*.jpg' | head -n 1000 | xargs -I {} mv {} ../../train/images &&
	find . -wholename '*.txt' | head -n 1000 | xargs -I {} mv {} ../../train/labels_raw &&
	find . -wholename '*.jpg' | head -n 141 | xargs -I {} mv {} ../../test/images &&
	find . -wholename '*.txt' | head -n 141 | xargs -I {} mv {} ../../test/labels_raw)
}

func_verify(){
	# env & dataset verification
	echo "Verifying environment and data..."
	python3 jamcam/verify.py
}

func_gen_valid(){
	# 
	echo "Generating validation dataset..."
	python3 jamcam/generate_val_dataset.py \
				--input_image_dir="$DATA_DOWNLOAD_DIR/train/images" \
				--input_label_dir="$DATA_DOWNLOAD_DIR/train/labels" \
				--output_dir="$DATA_DOWNLOAD_DIR/val"
}

func_tune_bdb(){
	# Tune bounding box
	echo "Tuning bounding box..."
	yolo_v4 kmeans -l "$LOCAL_DATA_DIR/train/labels" \
				   -i "$LOCAL_DATA_DIR/train/images" \
				   -n 9 \
				   -x 352 \
				   -y 288
}

func_convert_data(){
	# Convert to tfrecords (yolo_v4 dataset format)
	echo "Converting training dataset formats..."
	mkdir -p "$DATA_DOWNLOAD_DIR/train/tfrecords/train"
	yolo_v4 dataset_convert -d "$SPECS_DIR/yolo_v4_tfrecords_jamcam_train.txt" \
							-o "$DATA_DOWNLOAD_DIR/train/tfrecords/train/train"
	echo "Converting validation dataset formats..."
	mkdir -p "$DATA_DOWNLOAD_DIR/val/tfrecords/val"
	yolo_v4 dataset_convert -d "$SPECS_DIR/yolo_v4_tfrecords_jamcam_val.txt" \
							-o "$DATA_DOWNLOAD_DIR/val/tfrecords/val/val"
}

func_train(){
	# need to pass a gpu param here
	echo "Beginning training with default parameters..."
	yolo_v4 train -e "$SPECS_DIR/yolo_v4_train_resnet18_jamcam.txt" \
                  -r "$USER_EXPERIMENT_DIR/experiment_dir_unpruned" \
                  -k "$KEY" \
                  --gpus 1
}

func_eval(){
	echo "Beginning evaluation with default parameters..."
	yolo_v4 evaluate -e "$SPECS_DIR/yolo_v4_train_resnet18_jamcam.txt" \
                     -m "$USER_EXPERIMENT_DIR/experiment_dir_unpruned/weights/yolov4_resnet18_epoch_$EPOCH.tlt" \
                     -k "$KEY"
}

func_vis(){
	echo "Displaying visualisation..." \
	yolo_v4 inference -i "$DATA_DOWNLOAD_DIR/test_samples" \
                      -o "$USER_EXPERIMENT_DIR/yolo_infer_images" \
                      -e "$SPECS_DIR/yolo_v4_retrain_resnet18_jamcam.txt" \
                      -m "$USER_EXPERIMENT_DIR/experiment_dir_retrain/weights/yolov4_resnet18_epoch_$EPOCH.tlt" \
                      -l "$USER_EXPERIMENT_DIR/yolo_infer_labels" \
                      -k "$KEY"
}

func_export_model(){
	echo "Exporting model..." \
	yolo_v4 export -m "$USER_EXPERIMENT_DIR/experiment_dir_retrain/weights/yolov4_resnet18_epoch_$EPOCH.tlt" \
                   -k "$KEY" \
                   -o "$USER_EXPERIMENT_DIR/export/yolov4_resnet18_epoch_$EPOCH.etlt" \
                   -e "$SPECS_DIR/yolo_v4_retrain_resnet18_jamcam.txt" \
                   --batch_size 16 \
                   --data_type fp32
}

while [ -n "$1" ]; do
	case "$1" in
	--download) download ;;
	--verify) func_verify ;;
	--gen-valid) func_gen_valid ;;
	--tune-bdb) func_tune_bdb ;;
	--convert-data) func_convert_data ;;
	--train) func_train ;;
	--eval) func_eval ;;
	--vis) func_vis ;;
	--export) func_export_model ;;
	--all) download && func_verify && func_gen_valid && func_convert_data && func_train && func_eval && \
		   func_vis && func_export_model ;;
	*) echo "Option $1 not recognized" ;;

	esac

	shift

done

echo "Done."