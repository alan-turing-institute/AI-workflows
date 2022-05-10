#!/bin/bash
# Entrypoint for jamcam workflow, requires execution within suitable container. See README

# %environment
# export USER_EXPERIMENT_DIR=/workspace/yolo_v4
# export DATA_DOWNLOAD_DIR=/workspace/data
# export SPECS_DIR=/workspace/yolo_v4/specs
# export LOCAL_SPECS_DIR=/workspace/yolo_v4/specs
# export LOCAL_PROJECT_DIR=/workspace

while [ -n "$1" ]; do # 
	case "$1" in
	--verify) 		echo "Verifying Environment and data...\n" &&
					python3 jamcam/verify.py ;; # env & dataset verification
	
	--gen-valid) 	echo "Generating validation dataset...\n" &&
					python3 jamcam/generate_val_dataset.py --input_image_dir=$DATA_DOWNLOAD_DIR/train/images --input_label_dir=$DATA_DOWNLOAD_DIR/train/labels --output_dir=$DATA_DOWNLOAD_DIR/val ;; 
	
	--tune-bdb) echo "Tuning bounding box...\n" ;;
	--convert-data) echo "Converting dataset formats...\n" ;;
		# this is actually already done in the verification, could be split further
	--train) echo "Beginning training with default parameters...\n" ;;

	--eval) echo "Beginning evaluation with default parameters...\n" ;;

	--vis) echo "Displaying visualisation...\n" ;;

	--export) echo "Exporting model...\n" ;;

	*) echo "Option $1 not recognized" ;;

	esac

	shift

done

echo "Done."