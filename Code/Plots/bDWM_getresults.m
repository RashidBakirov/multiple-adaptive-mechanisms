res =[];
for b=1:31
    filename=['results/' num2str(b) 'DWMAMS_ClassificationResults.mat']
    if exist(filename, 'file') == 2
        
        
        load (filename, 'avg_acc', 'avg_acc_test');
        resj=[vertcat(avg_acc{:}) vertcat(avg_acc_test{:})];
        resj=vertcat(resj(1:10,:), [{[]} {[]} {[]} {[]}], resj(11,:));
        
    else
        resj=[[{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}]];
    end
    
    filename=['results/' num2str(b) '_DWMAMS_ClassificationResults_batch10_10.mat']
    if exist(filename, 'file') == 2
        load (filename, 'avg_acc', 'avg_acc_test');
        avg_acc1=avg_acc;
        avg_acc_test1=avg_acc_test;
        avg_acc1{12}(1)={[]};
        avg_acc_test1{12}(1)={[]};
        avg_acc1{10}=[{[]} {[]}];
        avg_acc_test1{10}={[]};
        avg_acc1{11}(1)={[]};
        avg_acc_test1{11}(1)={[]};

        resj=[resj vertcat(avg_acc1{:}) vertcat(avg_acc_test1{:})];
    else
        resj=[resj [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}]];
    end
        
    filename=['results/' num2str(b) '_DWMAMS_ClassificationResults_batch20_10.mat']
    if exist(filename, 'file') == 2
        load (filename, 'avg_acc', 'avg_acc_test');
        avg_acc1=avg_acc;
        avg_acc_test1=avg_acc_test;
        avg_acc1{12}(1)={[]};
        avg_acc_test1{12}(1)={[]};
        avg_acc1{10}=[{[]} {[]}];
        avg_acc_test1{10}={[]};
        avg_acc1{11}(1)={[]};
        avg_acc_test1{11}(1)={[]};
      
        resj=[resj vertcat(avg_acc1{:}) vertcat(avg_acc_test1{:})];
    else
        resj=[resj [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]};{[]}]];
    end        
    
    res=[res;resj];
end

for i=1:12*372
if isempty(res{i})
res{i}=0;
end
end