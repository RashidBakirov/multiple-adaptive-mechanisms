function [ mutualPDFUpdated, mutualPDFPosUpdated ] = mergePDFs2(mutualPDF1, mutualPDFPos1,mutualPDF2, mutualPDFPos2)

%merge pdf-s 2
%here the pdfs have different pdfPos-s
%first merged united grid is constructed
%then both of PDFs are simply summed

global par;

for iFeat=1:length(mutualPDF1)  
        
        iFeat;
        
        featRangeInput1=mutualPDFPos1{iFeat}(1:size(mutualPDF1{iFeat},2),1);
        featRangeOutput1=mutualPDFPos1{iFeat}(1:size(mutualPDF1{iFeat},1),2);
        
        featRangeInput2=mutualPDFPos2{iFeat}(1:size(mutualPDF2{iFeat},2),1);
        featRangeOutput2=mutualPDFPos2{iFeat}(1:size(mutualPDF2{iFeat},1),2);
        
        %merge ranges
        mergedFeatRangeInputReduced=combineMeshes( featRangeInput1', featRangeInput2', par.meshgridSize );
        mergedFeatRangeOutputReduced=combineMeshes(featRangeOutput1', featRangeOutput2', par.meshgridSize);
               
        %recalculate pdf's on new unified range
        [gridX1, gridY1] = meshgrid(featRangeInput1,featRangeOutput1);
        [gridX2, gridY2] = meshgrid(featRangeInput2,featRangeOutput2);

        [newGridX, newGridY] = meshgrid(mergedFeatRangeInputReduced,mergedFeatRangeOutputReduced);
 
        newGridZ1=interp2(gridX1, gridY1, mutualPDF1{iFeat}, newGridX(:), newGridY(:),'nearest',0); 
        mutualPDFNew1=reshape(newGridZ1,length(mergedFeatRangeInputReduced), length(mergedFeatRangeOutputReduced))';
        
        newGridZ2=interp2(gridX2, gridY2, mutualPDF2{iFeat}, newGridX(:), newGridY(:),'nearest',0); 
        mutualPDFNew2=reshape(newGridZ2,length(mergedFeatRangeInputReduced), length(mergedFeatRangeOutputReduced))';

        mutualPDFUpdated{iFeat}=mutualPDFNew1+mutualPDFNew2;
        mutualPDFPosUpdated{iFeat}=-1000*ones(max(length(mergedFeatRangeInputReduced),length(mergedFeatRangeOutputReduced)),2);
        mutualPDFPosUpdated{iFeat}(1:length(mergedFeatRangeInputReduced),1)=mergedFeatRangeInputReduced;
        mutualPDFPosUpdated{iFeat}(1:length(mergedFeatRangeOutputReduced),2)=mergedFeatRangeOutputReduced;           
    
end
        