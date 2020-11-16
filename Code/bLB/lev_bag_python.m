function acc = lev_bag_python(i,k,j,mode,r)
    run_string=['!/home/rbakirov/env/bin/python3 /home/rbakirov/LevBag/lev_bag_rb.py ' num2str(i) '_trn.csv ' num2str(i) '_tst.csv ' num2str(k) ' ' num2str(j) ' ' num2str(mode) ' ' num2str(r)];
    acc=evalc(run_string);
    acc=str2double(acc);


end