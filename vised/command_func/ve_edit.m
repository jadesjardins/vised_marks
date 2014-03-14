function EEG=ve_edit(EEG,varargin)%quick_evtmk,quick_evtrm,quick_chanflag)

options = varargin;
for index = 1:length(options)
    if iscell(options{index}) && ~iscell(options{index}{1}), options{index} = { options{index} }; end;
end;
if ~isempty( varargin ), tmp_g=struct(options{:});
else tmp_g=[]; end;

try tmp_g.quick_evtmk; 		    catch, tmp_g.quick_evtmk		= ''; 	end;
try tmp_g.quick_evtrm; 		    catch, tmp_g.quick_evtrm		= 'off';end;
try tmp_g.quick_chanflag; 		catch, tmp_g.quick_chanflag		= ''; 	end;


ax1 = findobj('tag','backeeg','parent',gcbf);
tmppos = get(ax1, 'currentpoint');


% Store "UserData" and "temppos" variables to "g" structures.             
g=get(gcbf, 'UserData');
g.tmppos=tmppos;

g.quick_evtmk=tmp_g.quick_evtmk;
g.quick_evtrm=tmp_g.quick_evtrm;
g.quick_chanflag=tmp_g.quick_chanflag;

g.nevents=length(EEG.event);

g.datasize=size(EEG.data);

if ~isfield(g.events, 'index');
    for i=1:length(g.events);
        g.events(i).index=i;
        g.events(i).proc='none';
    end
end

% Define relative starting point for figure window latencies: "EEG.eventedit.WinStartPnt"
if EEG.trials==1; % define WinStartPt. data point at wich current display window begins.
    g.eventedit.WinStartPnt=g.time*EEG.srate;
    g.eventedit.EpochIndex=1;
else
    g.eventedit.WindowIndex=g.time+1;
    g.eventedit.WinStartPnt=g.eventedit.WindowIndex*EEG.pnts-(EEG.pnts-1);
    g.eventedit.EpochIndex=ceil((g.tmppos(1,1)+g.eventedit.WinStartPnt)/EEG.pnts);
end;

g.eventedit.PosLat=round(g.tmppos(1,1)+g.eventedit.WinStartPnt);


% Identify selected channel.
% By default use the 'Eelec' tex display of eegplot.
tmpChanIndex=strmatch(get(findobj(gcf,'Tag','Eelec'),'string'),{g.eloc_file.labels},'exact');
if length(tmpChanIndex)==1;
    g.eventedit.ChanIndex=tmpChanIndex;
else
    % Otherwise calculate ChanIndex from tmppos.
    nWin=(g.chans-g.dispchans)+1;
    stepWin=1/nWin;
    if g.dispchans==g.chans;
        curWinStrt=0;
    else
        curWinStrt=floor((1-get(findobj('tag','eegslider'),'value'))/stepWin);
    end
    curWinEnd=curWinStrt+g.dispchans;

    YIndex=floor((tmppos(1,2)/(1/(g.dispchans+1)))-.5);
    g.eventedit.ChanIndex=(curWinEnd-YIndex);

    if g.eventedit.ChanIndex==0;
        g.eventedit.ChanIndex=1;
    end
    if g.eventedit.ChanIndex>EEG.nbchan;
        g.eventedit.ChanIndex=EEG.nbchan;
    end
end
clear tmpChanIndex

% Check for event selection.
%if ~isempty(EEG.event);
    pntdist=ceil((g.winlength*g.srate)*0.002);
    % Check for event selection.
    if isfield(g.eventedit, 'SelEventStruct');
        g=rmfield(g.eventedit,'SelEventStruct');
    end
    j=0;
    for i=1:length(g.events);
        if abs(g.events(i).latency-g.eventedit.PosLat)<pntdist;
            j=j+1;
            g.eventedit.SelEventStruct(j).index=i;
            g.eventedit.SelEventStruct(j).dist=abs(g.events(i).latency-round(g.tmppos(1,1)+g.eventedit.WinStartPnt));
            g.eventedit.SelEventStruct(j).type=g.events(i).type;
            g.eventedit.SelEventStruct(j).latency=g.events(i).latency;
        end
    end
%end

% Call event edit UI.

[EEG,g] = pop_ve_edit(EEG,g);
