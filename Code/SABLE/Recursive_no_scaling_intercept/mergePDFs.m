function [ mutualPDFUpdated, mutualPDFPosUpdated ] = mergePDFs(mutualPDFNew, mutualPDFPosNew,mutualPDF, mutualPDFPos, coeffOld, coeffNew)

%merge pdf-s. where there are collision, the new one wins

for iEx=1:length(mutualPDF)
    for iFeat=1:length(mutualPDF{iEx})  
        
        iEx;
        iFeat;
        
        %first it is needed to construct updated PDF for the older
        %descriptor, which has exaclty the same grid as n
        
        featRangeInput=mutualPDFPos{iEx}{iFeat}(1:size(mutualPDF{iEx}{iFeat},1),1);
        featRangeOutput=mutualPDFPos{iEx}{iFeat}(1:size(mutualPDF{iEx}{iFeat},2),2);
        
        newFeatRangeInput=mutualPDFPosNew{iEx}{iFeat}(1:size(mutualPDFNew{iEx}{iFeat},1),1);
        newFeatRangeOutput=mutualPDFPosNew{iEx}{iFeat}(1:size(mutualPDFNew{iEx}{iFeat},2),2);
        
        [gridX, gridY] = meshgrid(featRangeInput,featRangeOutput);
        %now we need to construct all of the pairs of newFeatRangeInput and
        %newFeatRangeOutput
        [newGridX, newGridY] = meshgrid(newFeatRangeInput,newFeatRangeOutput);
        
        if (coeffOld>0)
            newGridZ=interp2(gridX, gridY, mutualPDF{iEx}{iFeat}', newGridX(:), newGridY(:),'nearest',0); 
            mutualPDFOld1=reshape(newGridZ,length(newFeatRangeInput), length(newFeatRangeOutput))';

            mutualPDFNew1=coeffOld*mutualPDFOld1+coeffNew*mutualPDFNew{iEx}{iFeat};
        else
            mutualPDFNew1=mutualPDFNew{iEx}{iFeat};
        end
      
        mutualPDFUpdated{iEx}{iFeat}=mutualPDFNew1;
        mutualPDFPosUpdated{iEx}{iFeat}=mutualPDFPosNew{iEx}{iFeat};        
    end
end
        