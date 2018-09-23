function defineParametersGeneral(numLV)

global par;

%intial new experts generation
par.expGenerationFactionSamplesForPruning=1;
par.expGenerationSignificance=3;
par.expGenerationPruneFlag=1;
par.expGenerationPruneDiversityThreshold=0.05;
par.expGenerationtimeThreshold=1;
par.expGenerationNRandomStart=1;
par.expGenerationStartCluster=1;
par.expGenerationClusterFeatures=[];

%PLS training
par.PLSnLatentVectors=numLV;

%General adaptation
par.adaptPruneDiversityThreshold=0.05;
par.adaptPruneFlag=1;
par.adaptFactionSamplesForPruning=1;
par.changeDetectionFactor=2;
par.improvementFactor=2;

%RPLS adaptation
par.adaptRPLSlambda=1;
par.adaptRPLSflag=1;
par.adaptRPLSerrorTol=0.001;      