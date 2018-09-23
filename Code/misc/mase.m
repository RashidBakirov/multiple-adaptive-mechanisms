function [ error ] = mase( actual, prediction )
    sumErrors=0;  
    n=length(prediction);
    
    for i=1:n
        sumErrors=sumErrors+abs(actual(i)-prediction(i));
    end
    
    sumValues=0;
    for i=2:n
        sumValues=sumValues+abs(actual(i)-actual(i-1));
    end
    
    error=((n-1)*sumErrors)/(n*sumValues);

end

