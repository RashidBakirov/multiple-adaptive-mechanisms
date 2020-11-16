#running the bDWM code for 31 classification datasets using batch size of 10/20/50

for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabDWM_batch.sh $i 10
done
for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabDWM_batch.sh $i 20
done
for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabDWM_batch.sh $i 50
done
