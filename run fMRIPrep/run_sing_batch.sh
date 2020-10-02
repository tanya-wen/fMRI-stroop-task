export STUDY=/hpc/group/egnerlab
sbatch --array=1-$(( $( wc -l $STUDY/decodCC.01_BIDS/Nifti/participants.tsv | cut -f1 -d' ' ) - 1 )) sing_batch.sh