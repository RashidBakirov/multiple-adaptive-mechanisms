#running the bPL code for 31 classification datasets using batch size of 10/20/50 amd theta values of 0/2/4


for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabPairedBatch.sh $i 10 0
done
for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabPairedBatch.sh $i 20 0
done
for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabPairedBatch.sh $i 50 0
done
for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabPairedBatch.sh $i 10 2
done
for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabPairedBatch.sh $i 20 2
done
for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabPairedBatch.sh $i 50 2
done
for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabPairedBatch.sh $i 10 4
done
for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabPairedBatch.sh $i 20 4
done
for ((i=1;i<=31;i=i+1))
do
$1 ./callMatlabPairedBatch.sh $i 50 4
done
