function acc = lev_bag_python(i,k,j,mode,r,nFolds)
    run_string=['!python lev_bag_rb.py ./' num2str(i) '_trn.csv D:\Work\Research\MAM\Damien\code\bLB\' num2str(i) '_tst.csv ' num2str(k) ' ' num2str(j) ' ' num2str(mode) ' ' num2str(r) ' ' num2str(nFolds)];
    acc=evalc(run_string);
    acc=str2double(acc);
end