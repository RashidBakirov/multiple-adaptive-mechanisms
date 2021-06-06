%close all;
%clear all;
%clc;
myCluster = parcluster('local');
delete(myCluster.Jobs);
disp('start');

disp('starting');

  
for j=0:1
    time_50_2_c=cell(1,10);
    time_50_5_c=cell(1,10);
    time_50_10_c=cell(1,10);
    parfor cnt=1:10
        output = ['Return :' num2str(j),', Mode:' num2str(5),', Cnt:' num2str(cnt)];
        disp(output);
        tic
        lev_bag_python(28,0,50,5,j,2);
        time_50_2_c{cnt}=toc;
        tic
        lev_bag_python(28,0,50,5,j,5);
        time_50_5_c{cnt}=toc;
        tic
        lev_bag_python(28,0,50,5,j,10);
        time_50_10_c{cnt}=toc;
    end
    times{6+8*j}=time_50_2_c;
    times{7+8*j}=time_50_5_c;
    times{8+8*j}=time_50_10_c;
end

save ('LB_runtimes_full.mat', 'times');

% disp('50_10')
% for i=0:4
%     for j=0:1
%         time_50_10_c=cell(1,10);
%         parfor cnt=1:10
%             output = ['Return :' num2str(j),', Mode:' num2str(i),', Cnt:' num2str(cnt)];
%             disp(output);
%             tic
%             lev_bag_python(28,0,50,i,j,10);
%             time_50_10_c{cnt}=toc;
%         end
%         times{i+1+8*j}=time_50_10_c;
%     end
% end
% 
% save ('LB_runtimes_full.mat','times');
  
%end
%parfor_progress(0);

%save('../../results/results_levbag')

%exit

