function [ out_data ] = wekaNumericToNominal( in_data, attributes )
%WEKANUMERICTONOMINAL Summary of this function goes here
%   Detailed explanation goes here
        filter = weka.filters.unsupervised.attribute.NumericToNominal();
        filter.setOptions( weka.core.Utils.splitOptions(['-R ' attributes]) );
        filter.setInputFormat(in_data);   
        out_data = filter.useFilter(in_data, filter);

end

