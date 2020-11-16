matlab -r "runPairedLearnerClusterBatch_nb $1 $2 $3" > $1+$2+$3paired_batch_nb.log
matlab -r "runPairedLearnerClusterBatch_ht $1 $2 $3" > $1+$2+$3paired_batch_ht.log

