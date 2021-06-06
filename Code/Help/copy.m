function newObj = copy(obj)
        % R2010b or newer - directly in memory (faster)
        objByteArray = getByteStreamFromArray(obj);
        newObj = getArrayFromByteStream(objByteArray);
end