echo '"runBatchDynamicWeightedMajority_single_ht 12 10 0 10 trees.HoeffdingTree"'
echo '"runBatchDynamicWeightedMajority_single_ht 12 10 1 10 trees.HoeffdingTree"'

for ((d=13;d<=31;d=d+1))
do
echo '"runBatchDynamicWeightedMajority_single_ht ' $d ' 10 0 10 trees.HoeffdingTree"'
for ((i=1;i<=11;i=i+1))
do
echo '"runBatchDynamicWeightedMajority_single_ht ' $d ' ' $i ' 1 10 trees.HoeffdingTree"'
done
done

for ((d=1;d<=31;d=d+1))
do
echo '"runBatchDynamicWeightedMajority_single_ht ' $d ' 10 0 20 trees.HoeffdingTree"'
for ((i=1;i<=11;i=i+1))
do
echo '"runBatchDynamicWeightedMajority_single_ht ' $d ' ' $i ' 1 20 trees.HoeffdingTree"'
done
done

for ((d=1;d<=31;d=d+1))
do
echo '"runBatchDynamicWeightedMajority_single_ht ' $d ' 10 0 50 trees.HoeffdingTree"'
for ((i=1;i<=11;i=i+1))
do
echo '"runBatchDynamicWeightedMajority_single_ht ' $d ' ' $i ' 1 50 trees.HoeffdingTree"'
done
done

for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 20 0 bayes.NaiveBayes"'
done

for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 50 0 bayes.NaiveBayes"'
done

for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 20 0 bayes.HoeffdingTree"'
done

for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 50 0 bayes.HoeffdingTree"'
done

