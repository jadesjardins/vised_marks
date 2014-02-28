% ADAPTED FROM eeg_regepochs()

% See also: pop_editeventvals(), pop_epoch(), rmbase();
%
% Authors: Hilit Serby, Arnaud Delorme & Scott Makeig, SCCN/INC/UCSD, Sep 02, 2005

% Copyright (C) Hilit Serby, SCCN, INC, UCSD, Sep 02, 2005, hilit@sccn.ucsd.edu
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

function [EEG] = marks_continuous2epochs(EEG, varargin)

if nargin < 1
    help marks_continuous2epochs;
    return;
end;

%% GET INPUTS ...
if ~isstruct(EEG) | ~isfield(EEG,'event')
   error('first argument must be an EEG structure')
elseif EEG.trials > 1
   error('input dataset must be continuous data (1 epoch)');
end

if nargin > 1 && ~isstr(varargin{1})
    options = {};
    if nargin >= 2, options = { options{:} 'recurrence' varargin{1} }; end;
    if nargin >= 3, options = { options{:} 'limits'     varargin{2} }; end;
    if nargin >= 5, options = { options{:} 'keepboundary'     varargin{3} }; end;
    
%    if nargin >= 4, options = { options{:} 'rmbase'     varargin{3} }; end;
else
    options = varargin;
end;
g = finputcheck(options, { 'recurrence'    'real'  []  1;
                            'limits'        'real'  []  [0 1];
                            'keepboundary'  'string' {'on','off'} 'on';
                            'rmbase'        'real'  []  [NaN];
                            'eventtype'     'string' {} 'tmp_cnt2win';
                            'extractepochs' 'string' { 'on','off' } 'on' }, 'eeg_regepochs');
if isstr(g), error(g); end;

%% ADJUST INPUTS ...
if EEG.srate*g.recurrence~=round(EEG.srate*g.recurrence);
    disp('Adjusting recurrence value to fall on sample...');
    g.recurrence=round(EEG.srate*g.recurrence)*(1/EEG.srate);
    disp(['New recurrence value = ',num2str(g.recurrence)]);
end

if EEG.srate*g.limits(1)~=round(EEG.srate*g.limits(1));
    disp('Adjusting first limit value to fall on sample...');
    g.limits(1)=round(EEG.srate*g.limits(1))*(1/EEG.srate);
    disp(['New first limit value = ',num2str(g.limits(1))]);
end

if EEG.srate*g.limits(2)~=round(EEG.srate*g.limits(2));
    disp('Adjusting second limit value to fall on sample...');
    g.limits(2)=round(EEG.srate*g.limits(2))*(1/EEG.srate);
    disp(['New second limit value = ',num2str(g.limits(2))]);
end
tmpevt=g.eventtype;
while ~isempty(strmatch(tmpevt,unique({EEG.event.type})));
    tmpevt=[tmpevt,'X'];
end

%% ADJUST DATA ARRAY ...
disp('Appending time_info channels to data array...');
EEG=marks_moveflags(EEG,1);%CONVERT TO MARKS STRUCTURE

%% REPLACE BOUNDARY EVENT TYPE IF KEEPBOUNDARY = 'ON'
if strcmp(g.keepboundary,'on');
    tmpbndtype='tmpbndtype';
    while ~isempty(find(strcmp(tmpbndtype,unique({EEG.event.type}))));
        tmpbndtype=[tmpbndtype,'X'];
    end
    bndevtind=find(strcmp('boundary',{EEG.event.type}));
    disp(['renaming ',num2str(length(bndevtind)),' "boundary" events as "',tmpbndtype,'"...']);
    if ~isempty(bndevtind);
        for i=1:length(bndevtind);
            EEG.event(bndevtind(i)).type=tmpbndtype;
        end
    end
end


%% CALL EEG_REGEPOCHS
EEG=eeg_regepochs(EEG, ...
                'recurrence',g.recurrence, ...
                'limits',g.limits, ...
                'rmbase',g.rmbase, ...
                'eventtype',tmpevt);

%% REMOVE THE TEMPORARY WINDOWING EVENTS FROM THE EPOCHED EEG STRUCTURE ...
tmpevtind=find(strcmp(tmpevt,{EEG.event.type}));
disp(['Removing ' num2str(length(tmpevtind)),' temporary ', tmpevt, ' events...']);
EEG.event(tmpevtind)=[];

disp('Moving time_info channels from data array to marks structure...');
EEG=marks_moveflags(EEG,2);

%% CORRECT THE BOUNDARY TYPE SWAP...
if strcmp(g.keepboundary,'on');
    bndevtind=find(strcmp(tmpbndtype,{EEG.event.type}));
    disp(['renaming ',num2str(length(bndevtind)),' "',tmpbndtype,'" events as "boundary"...']);
    if ~isempty(bndevtind);
        for i=1:length(bndevtind);
            EEG.event(bndevtind(i)).type='boundary';
        end
    end
end
