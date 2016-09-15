function flags=padflags(EEG,flags,npad)

for np=1:npad;
    for i=1:size(flags,3)-1;
        %forward...
        if any(flags(:,:,i+1))==1
            flags(:,:,i)=1;
        end
        %backward...
        if any(flags(:,:,(EEG.trials-(i-1))-1))==1
            flags(:,:,EEG.trials-(i-1))=1;
        end
    end
end
