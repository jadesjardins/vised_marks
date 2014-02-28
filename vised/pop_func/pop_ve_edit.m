% pop_fig_EditEvent() - Set parameters for editing events from the eegplot figure window.
%
% Usage:
%   >>  g = pop_fig_EditEvent(data, g, Latency, EventType, EventIndex, Proc);
%
% Inputs:
%   data       - EEG channel data being displayed in eegplot figure window.
%   g          - eegplot UserData
%   Latency    - data point of button press.
%   EventType  - Label of selected or new event.
%   EventIndex - Index of Event to be edited (0 if creating new event).
%   Proc       - procedure to use on selected event (New, Edit, Delete).
%
% Outputs:
%   EEG  - output dataset
%
% If there are no events near the time point of the button press the user
% is given the option of either entering a new event into the data or
% toggling a bad channel status. If the "Edit events" check box is selected
% the string in the "Event tupe" edit box will be the "type" of the new
% event (note that while the "Event editing procedure" popup menu is
% present in this UI it is only populated by "New"). If the "Toggle bad
% channel status" check box is selected the bad channel status of the
% channel identified by the label in the "Channel selection" popup menu
% will alternate (this alternation affects the EEG.chanlocs.badchan field
% by setting it to 0 or 1).
%
% If there are events close to the time point of the button press the user
% is given the option of selecting among existing events (within +/-20
% points of the button press) using the "Event close to press" popup menu,
% then perform a procedure listed in the "Event editing procedure" (New,
% Edit, Delete). Note: In this case if a new event name is entered into
% the "Event type" edit box the only procedure that makes sense is "New",
% but the other options are still available in the "Event editing procedure"
% popup box and will produce errors if used.

%
% See also:
%   EEGLAB, eegplot, VisEd

% Copyright (C) <2008>  <James Desjardins> Brock University
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA



function [EEG,g,com]=pop_ve_edit(EEG,g, Latency, EventType, EventIndex, Proc)
% the command output is a hidden output that does not have to
% be described in the header
com = ''; % this initialization ensure that the function will return something
% if the user press the cancel button
% display help if not enough arguments
% ------------------------------------

if nargin < 1
    help pop_sig_EditEvent;
    return;
end;

EventChan = '';
if nargin < 5
    
    ProcCell={'New', 'Delete'};
    
    if ~isfield(g.eventedit, 'SelEventStruct');
        tmp.event(1).index=0;
        tmp.event(1).Dist=0;
        tmp.event(1).type='User';
        tmp.event(1).latency=g.eventedit.PosLat;
        if length(g.datasize)==3;
            tmp.event(1).epoch=floor(tmp.event(1).latency/g.datasize(3));
        end
        
        if ~isempty(g.quick_evtmk);
            results = {1 g.quick_evtmk 1 0 '' {''}};
        elseif ~isempty(g.quick_chanflag);
            mark_ind=find(strcmp(g.quick_chanflag, {g.chan_marks_struct.label}));
            if isempty(mark_ind);
                if strcmp(g.data_type,'EEG');info_type='chan_info';else info_type='comp_info';end;
                [EEG,com]=pop_marks_add_label(EEG,'info_type',info_type,'label',g.quick_chanflag,'message','BBBOOOOOOYYYAAAAAAAA!!!!!');
                mark_ind=length(g.chan_marks_struct)+1;
                g.chan_marks_struct(mark_ind).label=g.quick_chanflag;
                switch g.data_type
                    case 'EEG'
                        ind=length(EEG.marks.chan_info);
                        g.chan_marks_struct(mark_ind).line_color=EEG.marks.chan_info(ind).line_color;
                        g.chan_marks_struct(mark_ind).tag_color=EEG.marks.chan_info(ind).tag_color;
                        g.chan_marks_struct(mark_ind).order=EEG.marks.chan_info(ind).order;
                    case 'ICA'
                        ind=length(EEG.marks.comp_info);
                        g.chan_marks_struct(mark_ind).line_color=EEG.marks.comp_info(ind).line_color;
                        g.chan_marks_struct(mark_ind).tag_color=EEG.marks.comp_info(ind).tag_color;
                        g.chan_marks_struct(mark_ind).order=EEG.marks.comp_info(ind).order;
                end
                g.chan_marks_struct(mark_ind).flags=zeros(size(g.chan_marks_struct(1).flags));
            end
            results = {0 '' 1 1 ...
                       mark_ind ...
                       {g.eloc_file(g.eventedit.ChanIndex).labels}};
        else            
            
            % pop up window
            % -------------
            
            results=inputgui( ...
                {[1] [1] [2 2] [2 2] [1] [1 1] [2 1 3] [1]}, ...
                {...
                ...1
                {'Style', 'text', 'string', 'Select editing parameters.', 'FontWeight', 'bold'}, ...
                ...2
                {'Style', 'checkbox', 'tag', 'EditEventCheck', 'string', 'Edit events:', 'value', 1, ...
                'callback', 'set(findobj(''tag'', ''MarkBadChanCheck''), ''value'', 0);' }, ...
                ...3
                {'Style', 'text', 'string', 'Event type.'}, ...
                {'Style', 'text', 'string', 'Event editing procedure.'}, ...
                ...4
                {'Style', 'edit', 'tag', 'SelEventTypeEdit', 'string', tmp.event(1).type}, ...
                {'Style', 'Popup', 'string', ProcCell{1}}, ...
                ...5
                {}, ...
                ...6
                {'Style', 'checkbox', 'tag', 'MarkBadChanCheck', 'string', 'Toggle channel marks status:', 'value', 0, ...
                'callback', 'set(findobj(''tag'', ''EditEventCheck''), ''value'', 0);' }, ...
                {'Style','popup','string',{g.chan_marks_struct.label},'value',1}, ...
                ...7
                {'Style', 'text', 'string', 'Channels selection:' }, ...
                {'Style', 'pushbutton', 'string', '...', 'tag', 'ChanLabelButton',...
                'callback', ['tmpchan = get(gcbf, ''userdata''); [ChanLabelIndex,ChanLabelStr,ChanLabelCell]=pop_chansel({tmpchan.labels});' ...
                'set(findobj(gcbf, ''tag'', ''ChanLabelEdit''), ''string'', vararg2str(ChanLabelCell)); clear tmpchan ChanLabelIndex,ChanLabelStr,ChanLabelCell;']}, ...
                {}, ...
                ...8
                {'Style', 'edit', 'string', {g.eloc_file(g.eventedit.ChanIndex).labels} ,'tag', 'ChanLabelEdit'}, ...
                }, ...
                'pophelp(''pop_fig_EditEvent'');', 'event edit -- pop_fig_EditEvent()', g.eloc_file);%, [], 'return');
            %close;
            if isempty(results);return;end
            
        end
        
        if isempty(results);return;end
    
        if results{1}==1;
            Proc       = ProcCell{results{3}};
            
            Latency    = g.eventedit.PosLat;
            EventType  = results{2};
            EventIndex = 0;
        end
        
        % get channel string
        ChanLabelStr=results{6};
        if iscell(ChanLabelStr);
            g.eventedit.ChanLabelCell=ChanLabelStr;
            EventChan = ChanLabelStr{1};
        else
            EventChan = ChanLabelStr;
            g.eventedit.ChanLabelCell=eval(['{' ChanLabelStr '}']);
        end
        
        % toggle bad channel
        if results{4}==1
            g.quick_chanflag=g.chan_marks_struct(results{5}).label;
            %if ~isfield(g.eloc_file, 'badchan');
            %    for i=1:length(g.eloc_file);
            %        g.eloc_file(i).badchan=0;
            %    end
            %end
            %ChanLabelStr=results{5};
            %if iscell(ChanLabelStr);
            %    g.eventedit.ChanLabelCell=ChanLabelStr;
            %else
            %    g.eventedit.ChanLabelCell=eval(['{' ChanLabelStr '}']);
            %end
            for i=1:length(g.eventedit.ChanLabelCell);
                g.eventedit.ChanIndex=strmatch(g.eventedit.ChanLabelCell{i},{g.eloc_file.labels},'exact');
                %if g.eloc_file(g.eventedit.ChanIndex).badchan==0;
                %    g.eloc_file(g.eventedit.ChanIndex).badchan=1;
                %else
                %    g.eloc_file(g.eventedit.ChanIndex).badchan=0;
                %end
                mark_ind=find(strcmp(g.quick_chanflag,{g.chan_marks_struct.label}));
                if g.chan_marks_struct(mark_ind).flags(g.eventedit.ChanIndex)==0;
                    g.chan_marks_struct(mark_ind).flags(g.eventedit.ChanIndex)=1;
                else
                    g.chan_marks_struct(mark_ind).flags(g.eventedit.ChanIndex)=0;
                end
            end
            g = rmfield(g, 'eventedit');
            %set(gcbf, 'UserData', g);            
            set(findobj('tag', g.tag), 'UserData', g);
            ve_eegplot('drawp',0);
            return
        end
    else
        
        for i=1:length(g.eventedit.SelEventStruct);
            tmpInd(i,1)=g.eventedit.SelEventStruct(i).dist;
            tmpInd(i,2)=i;
        end
        tmpSort=sortrows(tmpInd,1);
        clear tmpInd
        
        for i=1:length(tmpSort(:,1));
            tmp.event(i)=g.eventedit.SelEventStruct(tmpSort(i,2));
        end
        clear tmpSort
        
        if strcmp(g.quick_evtrm,'on');
            results = {'' 2 1};
            Proc       = ProcCell{results{2}};
            if strcmp(Proc,'New');
                Latency    = g.eventedit.PosLat;
                EventType  = results{1};
                EventIndex = 0;
            else
                Latency    = tmp.event(results{3}).latency;
                EventType  = tmp.event(results{3}).type;
                EventIndex = tmp.event(results{3}).index;
            end
        else
            
            
            % pop up window
            % -------------
            if nargin < 5
                
                results=inputgui( ...
                    {[1] [2 2] [2 2] [2 2] [2 2]}, ...
                    {...
                    ...1
                    {'Style', 'text', 'string', 'Select editing parameters.', 'FontWeight', 'bold'}, ...
                    ...2
                    {'Style', 'text', 'string', 'Event type.'}, ...
                    {'Style', 'text', 'string', 'Event editing procedure.'}, ...
                    ...3
                    {'Style', 'edit', 'tag', 'SelEventTypeEdit', 'string', tmp.event(1).type}, ...
                    {'Style', 'Popup', 'tag', 'EventProcPupup','string', ProcCell, 'Value', 2} ...
                    ...5
                    {'Style', 'text', 'string', 'Events close to press:'}, ...
                    {}, ...
                    ...6
                    {'Style', 'Popup', 'tag', 'SelEventTypePopup', 'string', {tmp.event.type}, ...
                    'callback', ['tmpeventtype=get(findobj(''tag'', ''SelEventTypePopup''),''string'');', ...
                    'cureventtype=tmpeventtype{get(findobj(''tag'', ''SelEventTypePopup''),''Value'')};', ...
                    'set(findobj(''tag'', ''SelEventTypeEdit''),''string'', cureventtype);']}, ...
                    {}, ...
                    }, ...
                    'pophelp(''pop_fig_EditEvent'');', 'event edit -- pop_fig_EditEvent()' ...
                    );
                
                if isempty(results);return;end
                
            
                Proc       = ProcCell{results{2}};                
                if strcmp(Proc,'New');
                    Latency    = g.eventedit.PosLat;
                    EventType  = results{1};
                    EventIndex = 0;
                else
                    Latency    = tmp.event(results{3}).latency;
                    EventType  = tmp.event(results{3}).type;
                    EventIndex = tmp.event(results{3}).index;
                end
            end
        end
    end
    
    
end



% return the string command
% -------------------------
com = sprintf('g = pop_fig_edit_event(%s, %s, %s, %s, %s);', inputname(1), vararg2str(Latency), vararg2str(EventType), vararg2str(EventIndex), vararg2str(Proc));

% call function "FFTStandard" on raw data.
% ---------------------------------------------------
%g=fig_edit_event(g, Latency, EventType, EventIndex, EventChan, Proc);

switch Proc; %if strcmp(Proc, 'New');
    
    case 'New'
        
        if ~isfield(g, 'newindex');
            g.newindex=g.nevents+1;
        else
            g.newindex=g.newindex+1;
        end
        
        % Create new event.
        if isempty(g.events);
            g.events(1).latency=Latency;
        else
            g.events(length(g.events)+1).latency=Latency;
        end
        
        g.events(length(g.events)).type=EventType;
        g.events(length(g.events)).chan=EventChan;
        g.events(length(g.events)).urevent=length(g.events);
        g.events(length(g.events)).proc='new';
        g.events(length(g.events)).index=g.newindex;
        if length(g.datasize)==3;
            g.events(length(g.events)).epoch=ceil(Latency/g.datasize(3));
        end
        
        if ~isfield(g, 'eventupdate');
            updateindex=1;
        else
            updateindex=length(g.eventupdate)+1;
        end
        
        g.eventupdate(updateindex).latency=Latency;
        g.eventupdate(updateindex).type=EventType;
        g.eventupdate(updateindex).chan=EventChan;
        g.eventupdate(updateindex).proc='new';
        g.eventupdate(updateindex).index=g.newindex;
        if length(g.datasize)==3;
            g.eventupdate(updateindex).epoch=ceil(Latency/g.datasize(3));
        end
        
        
        %end
        
        
    case 'Delete'; %if strcmp(Proc, 'Delete');
        
        % log event update field.
        if ~isfield(g, 'eventupdate');
            updateindex=1;
        else
            updateindex=length(g.eventupdate)+1;
        end
        
        g.eventupdate(updateindex).latency=[];
        g.eventupdate(updateindex).type=[];
        g.eventupdate(updateindex).proc='clear';
        g.eventupdate(updateindex).index=g.events(EventIndex).index;
        
        % Clear SelEvent.
        g.events(EventIndex)=[];
        
        %end
        
        
    case 'Edit';% if strcmp(Proc, 'Edit');
        
        
        % Set default "edittime" if edit time has not already been set for this
        % figure.
        if ~isfield(g, 'edittime');
            g.edittime=[-500 500];
        end
        
        % Define index of channel to display.
        chanind=round((g.chans-g.elecoffset)-(g.tmppos(1,2)*g.dispchans));
        
        
        % EditFig parameter UI goes here.
        % pop up window
        % -------------
        results=inputgui( ...
            {[1] [4 3] [4 3]}, ...
            {...
            ...1
            {'Style', 'text', 'string', 'Select edit figure parameters.', 'FontWeight', 'bold'}, ...
            ...2
            {'Style', 'text', 'string', 'Time around event to display (eg. -500 500):'}, ...
            {'Style', 'edit', 'string', num2str(g.edittime)}, ...
            ...3
            {'Style', 'text', 'string', 'Index of channel to be displayed:'}, ...
            {'Style', 'edit', 'string', num2str(chanind)}, ...
            }, ...
            'pophelp(''pop_EventEdit'');', 'event edit -- pop_EventEdit()' ...
            ); ...
            if isempty(results);return;end
        
        g.edittime = str2num(results{1});
        chanind    = str2num(results{2});
        
        
        % Check if EditTime extends outside of available data.
        % - if possible adjust window to available data.
        editpnts=g.edittime*(g.srate/1000);
        
        if Latency<=editpnts(1)*-1;
            EditStartPnt=1;
            MrkLat=Latency;
        else
            EditStartPnt=Latency+editpnts(1);
            MrkLat=abs(editpnts(1));
        end
        EditEndPnt=EditStartPnt+(editpnts(2)-editpnts(1));
        
        
        % Create EditData (data to be displayed in EditPlot.
        EditData=[];
        EditData=g.data(chanind, EditStartPnt:EditEndPnt);
        
        
        % if requested create EditData2 (overlay waveform).
        if ~isempty(g.data2);
            EditData2=g.data2(chanind, EditStartPnt:EditEndPnt);
        end
        
        
        % Set EditPlot axes parameters and target event limits.
        EditMin=min(EditData);
        EditMax=max(EditData);
        MrkMin=EditMin-((EditMax-EditMin)*.5);
        MrkMax=EditMax+((EditMax-EditMin)*.5);
        
        
        %this will be removed.
        EditTime=[EditStartPnt*(1000/g.srate):1000/g.srate:EditEndPnt*(1000/g.srate)];
        
        
        %create EditPlot fgure and call ginput.
        EditFig=figure;
        plot(EditTime,EditData, 'k');
        hold on;
        if ~isempty(g.data2);
            plot(EditTime,EditData2, 'r');
        end
        
        plot([EditTime(MrkLat) EditTime(MrkLat)+.001], [MrkMin MrkMax], '-b');
        axis([EditTime(1) EditTime(length(EditTime)) MrkMin MrkMax]);
        hold off;
        x=ginput;
        close(EditFig);
        %    tmpLatency=g.events(EventIndex).latency;
        g.events(EventIndex).latency=round(x(length(x(:,1)),1)*(g.srate/1000));
        
        
        %Update "g.eventupdate" field.
        if ~isfield(g, 'eventupdate');
            updateindex=1;
        else
            updateindex=length(g.eventupdate)+1;
        end
        
        g.eventupdate(updateindex).latency=g.events(EventIndex).latency;
        g.eventupdate(updateindex).type=EventType;
        g.eventupdate(updateindex).type=EventChan;
        g.eventupdate(updateindex).proc='edit';
        g.eventupdate(updateindex).index=g.events(EventIndex).index;
        
end


% Create new eventtypes parameters if necessary.
if isfield(g, 'eventtypes');
    if ~any(strcmp(EventType, g.eventtypes));
        eventtypesN=length(g.eventtypes)+1;
        g.eventtypes{eventtypesN} = EventType;
        g.eventtypecolors{eventtypesN} = 'k';
        g.eventtypestyle{eventtypesN} = '-';
        g.eventtypewidths(eventtypesN) = 1;
    end
else
    eventtypesN=1;
    g.eventtypes{eventtypesN} = EventType;
    g.eventtypecolors{eventtypesN} = 'k';
    g.eventtypestyle{eventtypesN} = '-';
    g.eventtypewidths(eventtypesN) = 1;
    g.plotevent='on';
end
% Clear remaining display parameters.
if isfield(g, 'eventcolors');
    fields={'eventcolors', 'eventstyle', 'eventwidths', 'eventlatencies', 'eventlatencyend'};
    g=rmfield(g,fields);
end

if isempty(g.events);
    g.eventcolors=[];
    g.eventstyle=[];
    g.eventwidths=[];
    g.eventlatencies=[];
    g.eventlatencyend=[];
else
    for i=1:length(g.events);
        eventtypeindex=find(strcmp(g.eventtypes,g.events(i).type));
        g.eventcolors{i}=g.eventtypecolors{eventtypeindex};
        g.eventstyle{i}=g.eventtypestyle{eventtypeindex};
        g.eventwidths(i)=g.eventtypewidths(eventtypeindex);
        g.eventlatencies(i)=g.events(i).latency;
        g.eventlatencyend(i)=g.events(i).latency+g.eventwidths(i);
    end
end

g = rmfield(g, 'eventedit');

set(gcf, 'UserData', g);
ve_eegplot('drawp', 0);
