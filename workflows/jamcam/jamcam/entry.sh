#!/bin/bash
# Entrypoint for jamcam workflow, requires execution within suitable container. See README

while [ -n "$1" ]; do # 
	case "$1" in
	--verify) 		echo "Verifying Environment and data...\n" &&
					python3 jamcam/verify.py ;; # env & dataset verification
	
	--gen-valid) 	echo "Generating validation dataset...\n" &&
					python3 ../ssd/generate_val_dataset.py 
								--input_image_dir=$LOCAL_DATA_DIR/train/images \
                                --input_label_dir=$LOCAL_DATA_DIR/train/labels \
                                --output_dir=$LOCAL_DATA_DIR/val ;; 
	
	--tune-bdb) echo "Tuning bounding box...\n" ;;
	--convert-data) echo "Converting dataset formats...\n" ;;
	--train) echo "Beginning training with default parameters...\n" ;;
	--eval) echo "Beginning evaluation with default parameters...\n" ;;
	--vis) echo "Displaying visualisation...\n" ;;
	--export) echo "Exporting model...\n" ;;

	*) echo "Option $1 not recognized" ;;

	esac

	shift

done

echo "Done."