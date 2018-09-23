bestG=[];
bestGRC=[];
orig=[];
origRC=[];
xv=[];
xvRC=[];

for i=1:26
    res_i=vertcat(res{(i-1)*12+1:(i-1)*12+8,:});
    res_i=reshape(res_i,8,12);
    bestGi=max([res_i(:,3) res_i(:,7) res_i(:,11)]);
    bestGRCi=max([res_i(:,4) res_i(:,8) res_i(:,12)]);
    
    bestG=[bestG;bestGi];
    bestGRC=[bestGRC;bestGRCi];
    orig=[orig; [res{(i-1)*12+10,3} res{(i-1)*12+10,7} res{(i-1)*12+10,11}]];
    origRC=[origRC; [res{(i-1)*12+10,4} res{(i-1)*12+10,8} res{(i-1)*12+10,12}]];
    
    xv=[xv; [res{(i-1)*12+11,7} res{(i-1)*12+11,11}]];
    xvRC=[xvRC; [res{(i-1)*12+11,8} res{(i-1)*12+11,12}]];
end

for i=27:31
    res_i=vertcat(res{(i-1)*12+1:(i-1)*12+8,:});
    res_i=reshape(res_i,8,12);
    bestGi=max([res_i(:,1) res_i(:,5) res_i(:,9)]);
    bestGRCi=max([res_i(:,2) res_i(:,6) res_i(:,10)]);

    bestG=[bestG;bestGi];
    bestGRC=[bestGRC;bestGRCi];

    orig=[orig; [max([0,res{(i-1)*12+10,1}]) max([0,res{(i-1)*12+10,5}]) max([0,res{(i-1)*12+10,9}])]];
    origRC=[origRC; [max([0,res{(i-1)*12+10,2}]) max([0,res{(i-1)*12+10,6}]) max([0,res{(i-1)*12+10,10}])]];
    
    xv=[xv; [max([0,res{(i-1)*12+11,5}]) max([0,res{(i-1)*12+11,9}])]];
    xvRC=[xvRC; [max([0,res{(i-1)*12+11,6}]) max([0,res{(i-1)*12+11,10}])]];
end

res_all=[bestG(:,2),orig(:,2),xv(:,1),xvRC(:,1),bestG(:,3),orig(:,3),xv(:,2),xvRC(:,2)];