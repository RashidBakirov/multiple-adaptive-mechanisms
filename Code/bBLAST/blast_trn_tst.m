close all;
clear all;
clc;

clear java;
javaaddpath('D:\Work\Research\MAM\MLj\moa\lib');
javaaddpath('D:\Work\Research\MAM\MLj\moa\lib\moa.jar');
javaaddpath(pwd);


results_ = zeros(31,12,3);
%results_nb = zeros(2,4,3);
%results_ht = zeros(2,4,3);
j_idx=0;

%poolobj = gcp;
%addAttachedFiles(poolobj,{'BlastExperimentXV.class', '.\lib\moa.jar'})


for j=[10,20,50]
    j_idx=j_idx+1;
    for i=1:31
    %for i=1:31
        %folder = getAttachedFilesFolder;
        %javaaddpath(folder);
        %javaaddpath(folder + '\moa.jar');
        bExp=BlastExperimentXV();
        line = zeros(1,10);
        for mode=0:4
            for r=0:1
                    %t = getCurrentTask();
                    output = ['Batchsize:' num2str(j),', Dataset:' num2str(i) ', AS:' num2str(mode) ', Return:' num2str(r)];
                    disp(output);
                    %disp(['START --- ' output])
                    acc=bExp.runExp(i,j,mode,r);
                    %disp(['FINISH --- ' output])
                    line(mode+5*r+1)=acc;
            end
        end
        line
        results(i,:,j_idx)=line;
        writematrix(results(i,:,j_idx),'results.xls','Sheet',j_idx,'Range',['A' num2str(i) ':L' num2str(i)]);
    end
end

save('../../results/blast_results');


