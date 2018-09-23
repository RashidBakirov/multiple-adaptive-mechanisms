res={};
for q=0:2
    resq =[];
    for b=1:31              
        filename = ['results/' num2str(b) '_PairedLearnerResults_' num2str(q*2) '.mat'];
        if exist(filename, 'file') == 2
            load (filename,'avg_acc','avg_acc_test');
            resj=[vertcat(avg_acc{:}) vertcat(avg_acc_test{:})];
            resj=vertcat(resj(1:end-1,:), [{[]} {[]} {[]} {[]}], resj(end,:));
        else
            resj=[[{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]}]];
            b
            display('missing 0')
        end

        filename = ['results/' num2str(b) '_PairedLearnerResultsBatch_10_' num2str(q*2) '.mat'];

        if exist(filename, 'file') == 2
            load (filename,'avg_acc','avg_acc_test');
            resj=[resj vertcat(avg_acc{:}) vertcat(avg_acc_test{:})];
        else
            resj=[resj [{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]}]];
                    b
            display('missing 1')
        end
        filename = ['results/' num2str(b) '_PairedLearnerResultsBatch_20_' num2str(q*2) '.mat'];
        if exist(filename, 'file') == 2
            load (filename,'avg_acc','avg_acc_test');
            avg_acc1=avg_acc;
            resj=[resj vertcat(avg_acc{:}) vertcat(avg_acc_test{:})];
        else
            resj=[resj [{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]}] [{[]};{[]};{[]};{[]};{[]}]];
                    b
            display('missing 2')
        end

        resq=[resq;resj];
    end
    res{q+1}=resq;
end

for q=1:3
    for i=1:1860
        if isempty(res{q}{i})
            res{q}{i}=0;
        end
    end
end