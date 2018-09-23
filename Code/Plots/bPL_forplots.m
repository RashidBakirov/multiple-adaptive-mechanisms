res_all={};
bestG={};
bestGRC={};
orig={};
origRC={};
xv={};
xvRC={};

for t=1:3
    bestGt=[];
    bestGRCt=[];
    origt=[];
    origRCt=[];
    xvt=[];
    xvRCt=[];

    for i=1:26
        res_i=vertcat(res{t}{(i-1)*5+1:(i-1)*5+2,:});
        res_i=reshape(res_i,2,12);
        bestGi=max([res_i(:,3) res_i(:,7) res_i(:,11)]);
        bestGRCi=max([res_i(:,4) res_i(:,8) res_i(:,12)]);

        bestGt=[bestGt;bestGi];
        bestGRCt=[bestGRCt;bestGRCi];
        origt=[origt; [res{t}{(i-1)*5+3,3} res{t}{(i-1)*5+3,7} res{t}{(i-1)*5+3,11}]];
        origRCt=[origRCt; [res{t}{(i-1)*5+3,4} res{t}{(i-1)*5+3,8} res{t}{(i-1)*5+3,12}]];

        xvt=[xvt; [res{t}{(i-1)*5+4,7} res{t}{(i-1)*5+4,11}]];
        xvRCt=[xvRCt; [res{t}{(i-1)*5+4,8} res{t}{(i-1)*5+4,12}]];
    end

    for i=27:31
        res_i=vertcat(res{t}{(i-1)*5+1:(i-1)*5+2,:});
        res_i=reshape(res_i,2,12);
        bestGi=max([res_i(:,1) res_i(:,5) res_i(:,9)]);
        bestGRCi=max([res_i(:,2) res_i(:,6) res_i(:,10)]);

        bestGt=[bestGt;bestGi];
        bestGRCt=[bestGRCt;bestGRCi];

        origt=[origt; [res{t}{(i-1)*5+3,1} res{t}{(i-1)*5+3,5} res{t}{(i-1)*5+3,9}]];
        origRCt=[origRCt; [res{t}{(i-1)*5+3,2} res{t}{(i-1)*5+3,6} res{t}{(i-1)*5+3,10}]];

        xvt=[xvt; [res{t}{(i-1)*5+4,5} res{t}{(i-1)*5+4,9}]];
        xvRCt=[xvRCt; [res{t}{(i-1)*5+4,6} res{t}{(i-1)*5+4,10}]];
    end
    
    bestG{t}=bestGt;
    bestGRC{t}=bestGRCt;
    orig{t}=origt;
    origRC{t}=origRCt;
    xv{t}=xvt;
    xvRC{t}=xvRCt;
     
    res_all{t}=[bestGt(:,2),origt(:,2),xvt(:,1),xvRCt(:,1),bestGt(:,3),origt(:,3),xvt(:,2),xvRCt(:,2)];
end

