

res_all=[];
for i=1:3
    res = [];
    for j=1:5
        if ~isempty(restable{i}{j})
            ams=[restable{i}{j}(1,1), restable{i}{j}(2,1), restable{i}{j}(3,1), restable{i}{j}(4,1), restable{i}{j}(5,1)];
            best_am=min(ams);
            xv=restable{i}{j}(13,1);
            xvrc=restable{i}{j}(14,1);

            res = [res; [best_am xv xvrc]];
        end
    end
    res=res./repmat(sum(res,2),1,3);
    res_all=[res_all res];
end

