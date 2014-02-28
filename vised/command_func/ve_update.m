function EEG = ve_update(EEG, g)

if isfield(g, 'eventupdate');
    for i=1:length(g.eventupdate);
        if strcmp(g.eventupdate(i).proc, 'new');
            eventindex=length(EEG.event)+1;
            EEG.event(eventindex).latency=g.eventupdate(i).latency;
            EEG.event(eventindex).type=g.eventupdate(i).type;
            if ndims(EEG.data)==3;
                EEG.event(eventindex).epoch=g.eventupdate(i).epoch;
            end
        end
        if strcmp(g.eventupdate(i).proc, 'clear');
            eventindex=g.eventupdate(i).index;
            EEG.event(eventindex).action='clear';
        end
        if strcmp(g.eventupdate(i).proc, 'edit');
            eventindex=g.eventupdate(i).index;
            EEG.event(eventindex).action='edit';
            EEG.event(eventindex).actlat=g.eventupdate(i).latency;
        end
    end
end

j=0;
for i=1:length(EEG.event);
    if isfield(EEG.event(i),'action');
        if strcmp(EEG.event(i).action,'edit');
            EEG.event(i).latency=EEG.event(i).actlat;
        end
        if strcmp(EEG.event(i).action,'clear');
            j=j+1;
            clearInd(j)=i;
        end
    end
end

if isfield(EEG.event, 'action');
    EEG.event=rmfield(EEG.event,'action');
end
if isfield(EEG.event, 'actlat');
    EEG.event=rmfield(EEG.event,'actlat');
end

if exist('clearInd');
    EEG.event(clearInd)=[];
end

%sort events.
if ~isempty(EEG.event);
    tmpevent  = EEG.event;
    eventorder=[1:length(EEG.event);[tmpevent.latency]]';
    eventorder=sortrows(eventorder,2);
    for i=1:length(EEG.event);
        TMP.event(i)=EEG.event(eventorder(i,1));
    end
else
    TMP.event=[];
end

rmfield(EEG,'event');
EEG.event=TMP.event;

EEG=eeg_checkset(EEG, 'eventconsistency');

%% HANDLE MANUAL SELECTION OF TIME PERIODS. UPDATE "manual" time_info... 
manual_ind=find(strcmp('manual',{EEG.marks.time_info.label}));
if isempty(manual_ind);
    disp('There is no "manual" flag in the marks.time_info structure... creating it...');
    n_time_marks=length(EEG.marks.time_info);
    manual_ind=n_time_marks+1;
    EEG.marks.time_info(manual_ind).label='manual';
    EEG.marks.time_info(manual_ind).color=[.5,.5,.5];
    EEG.marks.time_info(manual_ind).flags=zeros(size(EEG.data(1,:,:)));
else
    disp('Replacing existing "manual" flags...');
    EEG.marks.time_info(manual_ind).flags=zeros(size(EEG.data(1,:,:)));
end

for i=1:size(g.winrej,1);
    if ndims(EEG.marks.time_info(manual_ind).flags)==2;
        EEG.marks.time_info(manual_ind).flags(round(g.winrej(i,1)):round(g.winrej(i,2)))=1;
    else
        EEG.marks.time_info(manual_ind).flags(1,:,round(g.winrej(i,2)/EEG.pnts))=1;
    end
end
    
%% HANDLE MANUAL SELECTION OF CHANNELS. UPDATE "manual" chan_info... 
switch g.data_type
    case 'EEG'
        for ml_i=1:length(EEG.marks.chan_info)
            manual_ind_marks=ml_i;%find(strcmp(EEG.marks.chan_info{i}.label,{EEG.marks.chan_info.label}));
            manual_ind_g=find(strcmp(EEG.marks.chan_info(ml_i).label,{g.chan_marks_struct.label}));
            for i=1:length(g.eloc_file);
                EEG.marks.chan_info(manual_ind_marks).flags(g.eloc_file(i).index,1)=g.chan_marks_struct(manual_ind_g).flags(i,1);
            end
        end
    case 'ICA'
        for ml_i=1:length(EEG.marks.comp_info)
            manual_ind_marks=ml_i;%find(strcmp('manual',{EEG.marks.comp_info.label}));
            manual_ind_g=find(strcmp(EEG.marks.comp_info(ml_i).label,{g.chan_marks_struct.label}));
            for i=1:length(g.eloc_file);
                EEG.marks.comp_info(manual_ind_marks).flags(g.eloc_file(i).index,1)=g.chan_marks_struct(manual_ind_g).flags(i,1);
            end
        end        
end
%switch datoric
%    case 1
%    case 2
%end

%%

eeglab redraw


%% OBSOLETE ... ADD/UPDATE WINREJ FIELD IN EEG STRUCTURE ...
%EEG.winrej=[];
%EEG.winrej=g.winrej;
%% OBSOLETE ... HANDLE BADCHAN FIELD OF ELOC_FILE STRUCTURE ...        
if isfield(g,'eloc_file');
    if length(g.eloc_file(1).labels)>=4;
        if strmatch(g.eloc_file(1).labels(1:4),'comp');
            datoric=2;
        end
    end
end
if ~exist('datoric', 'var');
    datoric=1;
end

if isfield(g.eloc_file, 'badchan');
    switch datoric
        case 1
            for i=1:length(g.eloc_file);
                EEG.chanlocs(g.eloc_file(i).index).badchan=g.eloc_file(i).badchan;
            end
        case 2
            for i=1:length(g.eloc_file);
                EEG.reject.gcompreject(g.eloc_file(i).index)=g.eloc_file(i).badchan;
            end
    end
end

