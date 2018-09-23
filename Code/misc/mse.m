function [ error ] = mse( actual, prediction )
    if iscell(prediction)
        batchSize=length(prediction{1});
        for i=1:length(prediction)
            error(i)=sqrt(sum((actual(1+(i-1)*batchSize:i*batchSize)-prediction{i}).^2))/batchSize; 
        end
    else
        error=sqrt(sum((actual-prediction).^2)/length(prediction));   
    end
end

