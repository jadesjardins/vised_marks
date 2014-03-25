function EEG = ve_update(EEG)

udf=get(gcbf,'userdata');

if isfield(udf,'urdata');
    EEG.data=get(findobj('tag','eegaxis','parent',gcbf), 'userdata');
end

if isfield(udf, 'eventupdate');
    for i=1:length(udf.eventupdate);
        if strcmp(udf.eventupdate(i).proc, 'new');
            eventindex=length(EEG.event)+1;
            EEG.event(eventindex).latency=udf.eventupdate(i).latency;
            EEG.event(eventindex).type=udf.eventupdate(i).type;
            if ndims(EEG.data)==3;
                EEG.event(eventindex).epoch=udf.eventupdate(i).epoch;
            end
        end
        if strcmp(udf.eventupdate(i).proc, 'clear');
            eventindex=udf.eventupdate(i).index;
            EEG.event(eventindex).action='clear';
        end
        if strcmp(udf.eventupdate(i).proc, 'edit');
            eventindex=udf.eventupdate(i).index;
            EEG.event(eventindex).action='edit';
            EEG.event(eventindex).actlat=udf.eventupdate(i).latency;
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
%manual_ind=find(strcmp('manual',{EEG.marks.time_info.label}));
%if isempty(manual_ind);
%    disp('There is no "manual" flag in the marks.time_info structure... creating it...');
%    n_time_marks=length(EEG.marks.time_info);
%    manual_ind=n_time_marks+1;
%    EEG.marks.time_info(manual_ind).label='manual';
%    EEG.marks.time_info(manual_ind).color=[.5,.5,.5];
%    EEG.marks.time_info(manual_ind).flags=zeros(size(EEG.data(1,:,:)));
%else
%    disp('Replacing existing "manual" flags...');
%    EEG.marks.time_info(manual_ind).flags=zeros(size(EEG.data(1,:,:)));
%end

%for i=1:size(g.winrej,1);
%    if ndims(EEG.marks.time_info(manual_ind).flags)==2;
%        EEG.marks.time_info(manual_ind).flags(round(g.winrej(i,1)):round(g.winrej(i,2)))=1;
%    else
%        EEG.marks.time_info(manual_ind).flags(1,:,round(g.winrej(i,2)/EEG.pnts))=1;
%    end
%end
EEG.marks.time_info=udf.time_marks_struct;    
%% HANDLE MANUAL SELECTION OF CHANNELS. UPDATE "manual" chan_info... 
switch udf.data_type
    case 'EEG'
        for udfl_i=1:length(udf.chan_marks_struct)
            %manual_ind_marks=ml_i;%find(strcmp(EEG.marks.chan_info{i}.label,{EEG.marks.chan_info.label}));
            eegl_i=find(strcmp(udf.chan_marks_struct(udfl_i).label,{EEG.marks.chan_info.label}));
            if isempty(eegl_i)
                EEG.marks=marks_add_label(EEG.marks,'chan_info', ...
                    {udf.chan_marks_struct(udfl_i).label, ...
                    udf.chan_marks_struct(udfl_i).line_color, ...
                    udf.chan_marks_struct(udfl_i).tag_color, ...
                    udf.chan_marks_struct(udfl_i).order, ...
                    zeros(EEG.nbchan,1)});
                eegl_i=length(EEG.marks.chan_info);
            end
           for i=1:length(udf.eloc_file);
               EEG.marks.chan_info(eegl_i).flags(udf.eloc_file(i).index,1)=udf.chan_marks_struct(udfl_i).flags(i,1);
           end
        end
    case 'ICA'
        for ml_i=1:length(EEG.marks.comp_info)
            manual_ind_marks=ml_i;%find(strcmp('manual',{EEG.marks.comp_info.label}));
            manual_ind_g=find(strcmp(EEG.marks.comp_info(ml_i).label,{udf.chan_marks_struct.label}));
            for i=1:length(udf.eloc_file);
                EEG.marks.comp_info(manual_ind_marks).flags(udf.eloc_file(i).index,1)=udf.chan_marks_struct(manual_ind_g).flags(i,1);
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
if isfield(udf,'eloc_file');
    if length(udf.eloc_file(1).labels)>=4;
        if strmatch(udf.eloc_file(1).labels(1:4),'comp');
            datoric=2;
        end
    end
end
if ~exist('datoric', 'var');
    datoric=1;
end

if isfield(udf.eloc_file, 'badchan');
    switch datoric
        case 1
            for i=1:length(udf.eloc_file);
                EEG.chanlocs(udf.eloc_file(i).index).badchan=udf.eloc_file(i).badchan;
            end
        case 2
            for i=1:length(udf.eloc_file);
                EEG.reject.gcompreject(udf.eloc_file(i).index)=udf.eloc_file(i).badchan;
            end
    end
end

