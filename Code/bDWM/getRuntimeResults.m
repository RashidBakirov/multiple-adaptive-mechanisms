
for j=1:2
    for i=1:10
            runtimes_mean(i,:,j)=mean(vertcat(time_50_10{j,i}{:}));
            runtimes_std(i,:,j)=std(vertcat(time_50_10{j,i}{:}));
    end
    runtimes_mean(i+1,:,j)=mean(vertcat(time_50_5{j,i}{:}));
    runtimes_mean(i+2,:,j)=mean(vertcat(time_50_2{j,i}{:}));
    runtimes_std(i+1,:,j)=std(vertcat(time_50_5{j,i}{:}));
    runtimes_std(i+2,:,j)=std(vertcat(time_50_2{j,i}{:}));
end

runtimes_mean=[runtimes_mean(:,:,1); runtimes_mean(:,:,2)];
runtimes_mean=[runtimes_std(:,:,1); runtimes_std(:,:,2)];


runtimes_mean_diff=runtimes_mean(:,1);
for i=2:88   
    runtimes_mean_diff=[runtimes_mean_diff runtimes_mean(:,i)-runtimes_mean(:,i-1)];
end