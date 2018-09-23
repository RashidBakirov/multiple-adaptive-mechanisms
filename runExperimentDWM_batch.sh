for ((i=1;i<=31;i=i+1))
do
qsub -l q=compute ./callMatlabDWM_batch.sh $i 10
done

for ((i=1;i<=31;i=i+1))
do
qsub -l q=compute ./callMatlabDWM_batch.sh $i 20
done