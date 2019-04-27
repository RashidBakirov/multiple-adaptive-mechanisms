function [wekaOutput, output] = useWekaFilter(filter, data)

    if(~wekaPathCheck),output = data; return,end
    wekaOutput = javaMethod('useFilter', 'weka.filters.Filter', data, filter);
    [output,~,~,~,~] = weka2matlab(wekaOutput);
end