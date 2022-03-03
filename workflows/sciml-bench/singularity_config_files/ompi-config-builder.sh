{ (envsubst < ompi-header.txt) & (cat ompi-body.txt); } > tmp_file.def 2>/dev/null
sudo -E singularity build ${OMPI4_CONTAINER} tmp_file.def
rm tmp_file.def
