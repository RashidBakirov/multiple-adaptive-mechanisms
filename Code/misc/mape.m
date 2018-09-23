function [ error ] = mape( actual, prediction )
    error=0;    
    for i=1:length(prediction)
        error=error+abs((actual(i)-prediction(i))/actual(i));
    end
    
    error=error/length(prediction);

end

