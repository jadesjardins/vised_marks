function out=fisherz(inarray,dim)

if dim==1;
    for i=1:size(inarray,1);
        inarray(:,i)=.5.*log((1+inarray(:,i))./(1-inarray(:,i)));
    end
end

if dim==2;
    for i=1:size(inarray,2);
        inarray(i,:)=.5.*log((1+inarray(i,:))./(1-inarray(i,:)));
    end
end

