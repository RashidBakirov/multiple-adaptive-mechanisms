import moa.classifiers.Classifier;
import moa.core.TimingUtils;
import com.yahoo.labs.samoa.instances.Instance;
import java.io.IOException;
import java.util.ArrayList;
import moa.streams.ArffFileStream;

import com.github.javacliparser.IntOption;
import com.yahoo.labs.samoa.instances.Instance;
import moa.classifiers.MultiClassClassifier;

import moa.classifiers.meta.HeterogeneousEnsembleBlastMAM;

public class BlastExperimentXV {

        public BlastExperimentXV(){
        }

        public double runExp(int dataSet, int batchsize, int strategy, int flagReturn){
			
				HeterogeneousEnsembleBlastMAM learner = new HeterogeneousEnsembleBlastMAM();
				int testBatchSize = 1;
                ArffFileStream trn_stream = new ArffFileStream("D:\\Work\\Research\\MAM\\MLj\\data\\arff\\" + dataSet + "_trn.arff", -1);
				ArffFileStream tst_stream = new ArffFileStream("D:\\Work\\Research\\MAM\\MLj\\data\\arff\\" + dataSet + "_trn.arff", -1);
				try {
					tst_stream = new ArffFileStream("..\\data\\arff\\" + dataSet + "_tst.arff", -1);
					testBatchSize = 100;
				}
				catch (Exception e) {}
                trn_stream.prepareForUse();			
                tst_stream.prepareForUse();
                learner.prepareForUse();
                int numberSamplesCorrect = 0;
                int numberSamples = 0;		
                boolean preciseCPUTiming = TimingUtils.enablePreciseTiming();
                long evaluateStartTime = TimingUtils.getNanoCPUTimeOfCurrentThread();
				
				Instance trainInst;
				Instance testInst;
				ArrayList<Instance> batch = new ArrayList<Instance>(); 
				ArrayList<HeterogeneousEnsembleBlastMAM> learners_array = new ArrayList<HeterogeneousEnsembleBlastMAM>(); 
				int strategy_i;

				//train the first batch using 0 option to initialize weights, etc.
				learner.strategyOption=0;
				for (int i=0;i<batchsize;i++) {
					trainInst = trn_stream.nextInstance().getData();
					learner.trainOnInstance(trainInst);
					
					if (testBatchSize == 1) {
						for (int j=0;j<2;j++) {
							tst_stream.nextInstance().getData();
						}
					}
					else {
						for (int j=0;j<testBatchSize;j++) {
							tst_stream.nextInstance().getData();
						}
					}
				}			
				
				learner.strategyOption=strategy;				
                while (tst_stream.hasMoreInstances()) {
					
					//Training
					strategy_i = strategy;
					if (flagReturn ==1) {
															
						for (int i=0;i<batchsize;i++) {
							trainInst = trn_stream.nextInstance().getData();
							batch.add(trainInst);
						}
						if (strategy == 4) { //XV	
							strategy_i = xvSelect(batch, learner, batchsize);
						}
					
						for (int k=0;k<4;k++) {
							HeterogeneousEnsembleBlastMAM learner_k = (HeterogeneousEnsembleBlastMAM) learner.copy();
							learner_k.strategyOption = k;
							learners_array.add(learner_k);
						}	
						for (int i=0;i<batch.size();i++) {
							for (int k=0;k<4;k++) {
								learners_array.get(k).trainOnInstance(batch.get(0));						
							}
							batch.remove(0);							
						}					
					}
					
					else {
						if (strategy == 4) { //XV					
							for (int i=0;i<batchsize;i++) {
								trainInst = trn_stream.nextInstance().getData();
								batch.add(trainInst);
							}
							
							strategy_i = xvSelect(batch, learner, batchsize);
							learner.strategyOption=strategy_i;
									
							for (int j = 0; j < batch.size(); j++) {
								learner.trainOnInstance(batch.get(0));
								batch.remove(0);
							}											
						}
						else {
							for (int i=0;i<batchsize;i++) {
								trainInst = trn_stream.nextInstance().getData();
								learner.trainOnInstance(trainInst);
							}
						}
					}
					
					//Testing
					if (flagReturn==1) {
						int[] learnersacc = {0,0,0,0};
						for (int j=0;j<batchsize*testBatchSize;j++) {
							testInst = tst_stream.nextInstance().getData();
							numberSamples++;
							for (int k=0;k<4;k++) {
								if (learners_array.get(k).correctlyClassifies(testInst)){
									learnersacc[k]++;							
								}
							}
						}
						learner = learners_array.get(maxindex(learnersacc));
						numberSamplesCorrect = numberSamplesCorrect + learnersacc[strategy_i];
						learners_array.clear();
					}
						
					else {
						for (int j=0;j<batchsize*testBatchSize;j++) {
							testInst = tst_stream.nextInstance().getData();
							numberSamples++;
							if (learner.correctlyClassifies(testInst)){
								numberSamplesCorrect++;							
							}
						}
					}
					//System.out.println("Batch processed");

                }
                double accuracy = 100.0 * (double) numberSamplesCorrect/ (double) numberSamples;
                double time = TimingUtils.nanoTimeToSeconds(TimingUtils.getNanoCPUTimeOfCurrentThread()- evaluateStartTime);
                //System.out.println(numberSamples + " instances processed with " + accuracy + "% accuracy in "+time+" seconds.");
				//System.out.println(accuracy);
				return accuracy;
        }
		
		public int xvSelect(ArrayList<Instance> batch, HeterogeneousEnsembleBlastMAM learner, int batchsize) {
			
			int[] xvacc = {0,0,0,0};
			for (int k=0;k<4;k++) {
				//HeterogeneousEnsembleBlastMAM testLearner = new HeterogeneousEnsembleBlastMAM();
				HeterogeneousEnsembleBlastMAM testLearner =  (HeterogeneousEnsembleBlastMAM) learner.copy();
				testLearner.strategyOption=k;
				int trainSize=batchsize/10;
				for (int i=0;i<10;i++) {
					for (int j=0;j<trainSize;j++) {
						testLearner.trainOnInstance(batch.get(trainSize*i+j));
					}
					for (int j=0;j<batchsize;j++) {
						if (j<trainSize*i || j>=trainSize*(i+1)) {						
							if (testLearner.correctlyClassifies(batch.get(j))) {
								xvacc[k]++;		
							}
						}
					}					
				}
			}
			return maxindex(xvacc);			
		}
		
		public int maxindex(int[] inp) {
			int maxAt = 0;
			for (int i = 0; i < inp.length; i++) {
				//System.out.print(inp[i] +" ");
				maxAt = inp[i] > inp[maxAt] ? i : maxAt;
			}
			return maxAt;
		}
		

        public static void main(String[] args) throws IOException {
			
			int dataSet = Integer.parseInt(args[0]);
			int batchsize = Integer.parseInt(args[1]);
			int strategy = Integer.parseInt(args[2]);
			int flagReturn = Integer.parseInt(args[3]);
			
            BlastExperimentXV exp = new BlastExperimentXV();
				
            exp.runExp(dataSet, batchsize, strategy, flagReturn);
        }
}