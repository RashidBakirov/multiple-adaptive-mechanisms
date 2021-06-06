close all;
clear all;
clc;
myCluster = parcluster('local');
delete(myCluster.Jobs);
disp('start');

disp('starting');
%parfor_progress(100);
%results_nb = zeros(31,12,3,100);
%results_ht = zeros(31,12,3,100);
results_nb = zeros(31,12,3);
results_ht = zeros(31,12,3);
progress = zeros(1,100);
%results_nb = zeros(2,4,3);
%results_ht = zeros(2,4,3);
%parfor iter = 1:100
    %t = getCurrentTask(); 
    j_idx=0;
    results_nb_iter=zeros(31,12,3);
    results_ht_iter=zeros(31,12,3);
    %for j=[10,20,50]
    for j=[50]
        j_idx=j_idx+1;
        %for i=1:31
        for i=1:1
            line_nb = zeros(1,12);
            line_ht = zeros(1,12);
            %line_nb = zeros(1,2);
            %line_ht = zeros(1,2);
            %for k=0:1
            for k=0
                for mode=0:5
                    for r=0:1                  
                            %disp(['START --- ' output])
                            acc=lev_bag_python(i,k,j,mode,r);
                            %disp(['FINISH --- ' output])          
                            if k==0
                                line_nb(mode+6*r+1)=acc;
                            end

                            if k==1
                                line_ht(mode+6*r+1)=acc;
                            end

                    end
                end
            end
          results_nb_iter(i,:,j_idx)=line_nb;
          %results_ht_iter(i,:,j_idx)=line_ht;

          %parfor_progress;

	  %line_nb
          %line_ht

          %xlswrite('results_nb.xls',line_nb,j_idx,['A' num2str(i+(iter-1)*31) ':L' num2str(i+(iter-1)*31)]);
          %xlswrite('results_ht.xls',line_ht,j_idx,['A' num2str(i+(iter-1)*31) ':L' num2str(i+(iter-1)*31)]);
        end
    end
  results_nb(:,:,:)=results_nb_iter;  
  %results_ht(:,:,:)=results_ht_iter;
  
%end
%parfor_progress(0);

%save('../../results/results_levbag')

%exit

