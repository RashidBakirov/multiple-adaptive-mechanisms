Instructions to run the experiments.

Experiments were perfomed using Matlab R2015a. There are two possible ways of running the experiments.
a) From unix bash, run run.sh which is the whole pipeline of performing the analysis, collating the results and generating the graphs used in the paper.

b) Running matlab code directly. It is possible to separately run SABLE, bDWM and bPL experiments, using runSABLE.m, runBatchPairedLearner.m and runBatchDynamicWeightedMajority.m (note that the arguments must be passed as strings).
These generate the result files in Results folder. After that, to collate results and generate graphs, SABLE_all_plots.m
, bPL_all_plots.m, bDWM_all_plots.m can be run.


Data

Datasets used in the paper are stored in regressiondata.mat and classificationdata.mat. It should be noted that Oxidiser and Drier datasets are not public and hence not included. Classification datasets are numbered according as specified in paper. Here, alldata{x}{1} denotes input training data for dataset x, alldata{x}{2} output training data, alldata{x}{3} input test data and alldata{x}{4} output test data. 
