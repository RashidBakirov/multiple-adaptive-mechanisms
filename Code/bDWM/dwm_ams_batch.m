function[acc, avg_acc , result, preds, avg_acc_test, pred_test, ams, time] = dwm_ams_batch(data, labels, classifier, mode, flag_rc,  batchsize, test_data, test_labels, folds)
tic
% dynamic weighted majority with multiple ams
% mode to select AM
% 1:8 - respective AM only
% 9 - original dwm
% 10 - xval
% 11 - optimal

disp('START');
disp(['MODE = ' num2str(mode)]);
disp(['RC = ' num2str(flag_rc)]);

NUMFOLDS = folds %xval folds
numlabels = length(unique(labels));
 
[rows cols]=size(data);

time=zeros(1,floor(rows/batchsize)-1);

ds1=dataset(data(1:batchsize,:),labels(1:batchsize)) %create the first datapoint
dsk=[];
cl=ds1*classifier;
if flag_rc
    for i=1:8
        % initialize the first learner with weight 1, given classifier
        ensemble{i}{1}.model=cl;
        ensemble{i}{1}.weight=1;
        ensemble{i}{1}.data=ds1;
    end
else
    selected_ensemble{1}.model=cl;
    selected_ensemble{1}.weight=1;
    selected_ensemble{1}.data=ds1;
end
result = zeros(1,rows-batchsize);
%exp_count=zeros(1,rows);
%ens_hist{1}={ensemble{1}{1}.model ensemble{1}{1}.weight length(ensemble{1}{1}.data)};
acc=zeros(1,floor(rows/batchsize)-1);
preds=zeros(1,rows-batchsize);
ams=zeros(floor(rows/batchsize)-1,2);

subwindow_size=size(test_data,1)/size(data,1);

result_test = zeros(1,size(test_data,1)-subwindow_size*batchsize);
pred_test = zeros(1,size(test_data,1)-subwindow_size*batchsize);
avg_acc=[];
avg_acc_test=[];
avg_result_test=zeros(1,rows-1);
xval_selection=4;

%result(1)=1;

exp_count=1;
acc(1)=1;
exp_hist=[];

if mode==11 && ~flag_rc
    return;
end

numBatches=floor(rows/batchsize);

%for all the data rows do incrementally the following:
for k = 2:numBatches
    % 1) calculate prediction of ensemble
    % disp('step 1');
    
    
    dataBatch=data(1+(k-1)*batchsize:k*batchsize,:);
    labelsBatch=labels(1+(k-1)*batchsize:k*batchsize);
    dsk=dataset(dataBatch,labelsBatch); %make a new dataset consisiting of current data point
    
    
    %select an ensemble member to predict, if flag_return is set
    if flag_rc
    
        if mode<=8 %always same AM
            r=mode;
            disp([num2str(k) ': AM deployed = ' num2str(r)]);
        elseif mode==9 %original dwm
            if k>2
                if mean(resultsBatch)<threshold    
                    r=5;
                else
                    r=1;
                end
            else
                r=4;
            end
            disp([num2str(k) ': AM deployed = ' num2str(r)]);
        elseif mode==10 %optimal
            r=xval_selection;
            disp([num2str(k) ': AM deployed = ' num2str(r)]);         
        elseif mode==11
            r=1; %this doesn't matter here
        end
 
        %parfor i=1:8
        % predicting with all possible ensembles
        for i=1:8   
            [~, ensemble{i}] = wm_mult_predict_batch(ensemble{i},dsk,labelsBatch); 
        end       
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=ensemble{r}{1}.ensemble_prediction; %assigning predictions to the predictions of the selected batch r

        %---------------------------------------------------------------
        %BEGIN TESTING ON A SEPARATE TESTSET, without learning on itif a
        %testset is given

        if ~isempty(test_data)
         test_dsk=dataset(test_data(1+(k-1)*subwindow_size*batchsize:(k)*subwindow_size*batchsize,:));                      
         test_preds=wm_mult_predict_batch_test(ensemble{r},test_dsk); %calculate prediction
         pred_test(1+(k-2)*subwindow_size*batchsize:(k-1)*subwindow_size*batchsize)=test_preds;
         result_test(1+(k-2)*subwindow_size*batchsize:(k-1)*subwindow_size*batchsize)=test_preds==test_labels(1+(k-1)*subwindow_size*batchsize:(k)*subwindow_size*batchsize);
        end
        %---------------------------------------------------------------

        %RC
        r_actual=r;
        [selected_ensemble, r] = dwm_candidate_select_batch(ensemble);
        %selected_ensemble = ensemble{r};
        disp([num2str(k) ': AM optimal = ' num2str(r)])
        if mode==11 %optimal am
           preds(1+(k-2)*batchsize:(k-1)*batchsize)=selected_ensemble{1}.ensemble_prediction;
        end
        ams(k-1,1)=r_actual; ams(k-1,2)=r-1;
 
        
    else %flag_rc is not set, only one ensemble
    
        [~, selected_ensemble] = wm_mult_predict_batch(selected_ensemble,dsk,labelsBatch);
        
         %---------------------------------------------------------------
        %BEGIN TESTING ON A SEPARATE TESTSET, without learning on itif a
        %testset is given

        if ~isempty(test_data)
         test_dsk=dataset(test_data(1+(k-1)*subwindow_size*batchsize:(k)*subwindow_size*batchsize,:));   
         test_preds=wm_mult_predict_batch_test(selected_ensemble,test_dsk); %calculate prediction
         pred_test(1+(k-2)*subwindow_size*batchsize:(k-1)*subwindow_size*batchsize)=test_preds;
         result_test(1+(k-2)*subwindow_size*batchsize:(k-1)*subwindow_size*batchsize)=test_preds==test_labels(1+(k-1)*subwindow_size*batchsize:(k)*subwindow_size*batchsize);
        end
        
        
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=selected_ensemble{1}.ensemble_prediction;
       
    end
    
    %distr=tabulate(labels(1:k*batchsize)); %get the distribution of labels up to this point to estimate the threshold for DWM
    distr=tabulate(labels(1+(k-2)*batchsize:(k-1)*batchsize)); %get the distribution of labels from the last batch to estimate the threshold for DWM
    threshold=max(distr(:,end))/100; %the proportion of majority label
    
    resultsBatch=preds(1+(k-2)*batchsize:(k-1)*batchsize)==labelsBatch';
    result(1+(k-2)*batchsize:(k-1)*batchsize)=resultsBatch;

    
    %adaptation-----------------------------------------------------
    
    %xval selection
    if mode == 10
        if flag_rc
            [xval_selection] = dwm_xval_select_batch(ensemble{r}, dataBatch, labelsBatch, classifier, batchsize, NUMFOLDS);
        else
            [xval_selection] = dwm_xval_select_batch(selected_ensemble, dataBatch, labelsBatch, classifier, batchsize, NUMFOLDS);
        end
    end
    % create all variations of dwm adaptation if flag return is set
    %parfor i=0:7
    if flag_rc
        %parfor i=1:8
        for i=1:8
            ensemble{i}=dwm_adapt_batch(selected_ensemble,dsk,classifier,i);
        end
        
    elseif mode~=11 %if not set selected_ensemble auomatically
        if mode<=8 %always same AM
            r=mode;
            disp([num2str(k) ': AM deployed = ' num2str(mode)]);
      elseif mode==9 %original dwm
                if mean(resultsBatch)<threshold    
                    r=5;
                else
                    r=1;
                end
            disp([num2str(k) ': AM deployed = ' num2str(r)]);
        elseif mode == 10 %xval
            [r] = xval_selection;
            disp([num2str(k) ': AM deployed = ' num2str(r)]);
        end
         ams(k-1,1)=r;ams(k-1,2)=r;
        selected_ensemble=dwm_adapt_batch(selected_ensemble,dsk,classifier,r);       
    end
    
    
    
    
    
    %create accuracy data for plot
     acc(k) = sum(result)/((k-1)*batchsize);

%     
    %save the experts, weights and size of dataset
%     ens_hist{k}={};
%     for j=1:size(ensemble,1)
%         aa={ensemble{j,1} ensemble{j,2} length(ensemble{j,3})};
%         ens_hist{k}=[ens_hist{k};aa];
%     end
    
    %save number of experts
%    exp_count(k)=size(ensemble,1);


time(k-1)=toc;    
    
end

avg_acc=mean(result());

if ~isempty(test_data)
    for i=1:floor(rows/batchsize)-1
         avg_result_test(i)=mean(result_test((i-1)*subwindow_size*batchsize+1:i*subwindow_size*batchsize));
    end
    
    avg_acc_test=mean(result_test);
end
    



% for j=1:size(ensemble,1)        
% exp_hist=[exp_hist; [size(ensemble{j,3},1),1]];
% end
%time(3)=toc
end
