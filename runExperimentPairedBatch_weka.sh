for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 10 1 trees.HoeffdingTree"'
done

for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 20 1 trees.HoeffdingTree"'
done

for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 50 1 trees.HoeffdingTree"'
done

for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 10 1 bayes.NaiveBayes"'
done

for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 20 1 bayes.NaiveBayes"'
done

for ((i=1;i<=31;i=i+1))
do
echo '"runPairedLearnerClusterBatch_weka ' $i ' 50 1 bayes.NaiveBayes"'
done
