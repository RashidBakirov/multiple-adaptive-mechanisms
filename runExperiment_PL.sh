for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 20 0 trees.HoeffdingTree"'
done

for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 50 0 trees.HoeffdingTree"'
done

