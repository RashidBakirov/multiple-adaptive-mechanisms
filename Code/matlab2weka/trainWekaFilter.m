function wekaFilter = trainWekaFilter(wekaData,type,options)
% Train a weka filter.
%
% wekaData - A weka java Instances object holding all of the training data.
%            You can convert matlab data to this format via the
%            matlab2weka() function or load existing weka arff data using
%            the loadARFF() function. 
%
% type    -  A string naming the type of filter to train relative to
%            the weka.filters package. There are many options - see
%            below for a few. See the weka documentation for the rest. 
%
% options - an optional cell array of strings listing the options specific
%           to the filter. See the weka documentation for details. 
%
% Example: 
% wekaFilter = trainWekaFilter(data,'unsupervised.attribute.RemoveUseless',{'-M', 99});
%


    if(~wekaPathCheck),wekaFilter = []; return,end
    wekaFilter = javaObject(['weka.filters.',type]);
    if(nargin == 3 && ~isempty(options))
        wekaFilter.setOptions(options);
    end
    wekaFilter.setInputFormat(wekaData);
end