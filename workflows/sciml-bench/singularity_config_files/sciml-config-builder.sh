{ (envsubst < sciml-config-header.txt) & (cat sciml-config-body.txt); } > tmp_file.def 2>/dev/null
sudo -E singularity build sciml-bench-with-config.sif tmp_file.def
rm tmp_file.def
