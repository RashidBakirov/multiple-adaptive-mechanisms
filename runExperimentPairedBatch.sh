#for ((i=1;i<=31;i=i+1))
#do
#qsub -l q=compute ./callMatlabPairedBatch.sh $i 10 0
#done

#for ((i=1;i<=31;i=i+1))
#do
#qsub -l q=compute ./callMatlabPairedBatch.sh $i 20 0
#done

#for ((i=1;i<=31;i=i+1))
#do
#qsub -l q=compute ./callMatlabPairedBatch.sh $i 10 2
#done

#for ((i=1;i<=31;i=i+1))
#do
#qsub -l q=compute ./callMatlabPairedBatch.sh $i 20 2
#done

#for ((i=1;i<=31;i=i+1))
#do
#qsub -l q=compute ./callMatlabPairedBatch.sh $i 10 4
#done

#for ((i=1;i<=31;i=i+1))
#do
#qsub -l q=compute ./callMatlabPairedBatch.sh $i 20 4
#done


#qsub -l q=compute ./callMatlabPairedBatch.sh 8 20 0
#qsub -l q=compute ./callMatlabPairedBatch.sh 26 20 0

#qsub -l q=compute ./callMatlabPairedBatch.sh 22 10 2
#qsub -l q=compute ./callMatlabPairedBatch.sh 31 10 2
#qsub -l q=compute ./callMatlabPairedBatch.sh 4 10 2
#qsub -l q=compute ./callMatlabPairedBatch.sh 13 10 2
qsub -l q=compute ./callMatlabPairedBatch.sh 27 20 2

#qsub -l q=compute ./callMatlabPairedBatch.sh 2 20 4
#qsub -l q=compute ./callMatlabPairedBatch.sh 10 10 4
#qsub -l q=compute ./callMatlabPairedBatch.sh 12 20 4
#qsub -l q=compute ./callMatlabPairedBatch.sh 13 20 4
#qsub -l q=compute ./callMatlabPairedBatch.sh 16 10 4
#qsub -l q=compute ./callMatlabPairedBatch.sh 17 10 4

