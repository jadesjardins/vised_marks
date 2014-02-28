function EEG = marks_init(EEG)

if isfield(EEG,'marks');
    sprintf('%s/n','Marks structure already exists...');
else
    disp('Adding the initial marks structure to EEG...');
    EEG=marks_add_label(EEG,'chan_info',{'manual',[.7,.7,.7],[.7,.7,.7],-1,zeros(EEG.nbchan,1)});
    if isempty(EEG.icawinv);
        EEG=marks_add_label(EEG,'comp_info',{'manual',[.7,.7,.7],[.7,.7,.7],-1,[]});
    else
        EEG=marks_add_label(EEG,'comp_info',{'manual',[.7,.7,.7],[.7,.7,.7],-1,zeros(size(EEG.icawinv,2),1)});
    end
    EEG=marks_add_label(EEG,'time_info',{'manual',[.7,.7,.7],zeros(1,EEG.pnts,EEG.trials)});
end
    