% eegplugin_PatID() - EEGLAB plugin for visually editing event markers and identifying bad channels using eegplot.
%
% Usage:
%   >> eegplugin_PatID(fig, try_strings, catch_stringss);
%
% Inputs:
%   fig            - [integer]  EEGLAB figure
%   try_strings    - [struct] "try" strings for menu callbacks.
%   catch_strings  - [struct] "catch" strings for menu callbacks.
%
% Creates Edit menu option "Visually edit events and identify bad channels"
% and calls pop_vised(EEG). 
%
%
% Copyright (C) <2008> <James Desjardins> Brock University
%
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



function eegplugin_vised_marks(fig,try_strings,catch_strings)

%% vised
% find EEGLAB tools menu.
% ---------------------
filemenu=findobj(fig,'label','File');
editmenu=findobj(fig,'label','Edit');
%configmenu=uimenu(filemenu,'label','vised configuration','separator','on');
%visedmenu=uimenu(editmenu,'label','Visually edit in scroll plot','separator','on');

% Create "pop_vised" callback cmd.
%---------------------------------------
VisEd_cmd='[EEG,LASTCOM] = pop_vised(EEG,''pop_gui'',''on'');';
finalcmdVE=[try_strings.no_check VisEd_cmd catch_strings.add_to_hist];

%CONFIG
vc_menu=uimenu(filemenu, 'Label', 'Vised configuration','separator','on', ...
                'callback','VISED_CONFIG=pop_edit_vised_config;');
% New
%cmdNVEC=['clear global VISED_CONFIG;',...
%     'global VISED_CONFIG;', ...
%     'VISED_CONFIG=visedconfig_obj;', ...
%     'properties=visedconfig2propgrid();' ...
%     'properties = properties.GetHierarchy();' ...
%     'vecp=PropertyGrid(''Properties'', properties);'...
%     'uiwait;' ...
%     'VISED_CONFIG=propgrid2visedconfig(vecp);'];

% Load
%cmdLVEC='pop_load_visedconfig();';

% Edit
%cmdEVEC=['properties=visedconfig2propgrid();' ...
%     'properties = properties.GetHierarchy();' ...
%     'vecp=PropertyGrid(''Properties'', properties);' ...
%     'uiwait;' ...
%     'VISED_CONFIG=propgrid2visedconfig(vecp);'];

% Save
%cmdSVEC='pop_save_visedconfig();';

% Clear
%cmdCVEC='clear global VISED_CONFIG';


% Create "pop_loadrmtclstcfg" callback cmd.
%-------------------------------------------
%cmd='[LASTCOM] = pop_loadvisedcfg();';
%finalcmdLVEC=[cmd];

% Create "pop_savermtclstcfg" callback cmd.
%-------------------------------------------
%cmd='pop_savevisedcfg();';
%finalcmdSVEC=[cmd];

% add "Visual edit" submenu to the "Edit" menu.
%--------------------------------------------------------------------
uimenu(editmenu, 'label', 'Visually edit in scroll plot', 'callback', finalcmdVE);
%uimenu(visedconfigmenu,'label','Load','callback',finalcmdLVEC,'userdata','startup:on');
%uimenu(visedconfigmenu,'label','Edit');
%uimenu(visedconfigmenu,'label','Save','callback',finalcmdSVEC);
%uimenu(configmenu,'label','New','callback',cmdNVEC);
%uimenu(configmenu,'label','Load','callback',cmdLVEC);
%uimenu(configmenu,'label','Edit properties','callback',cmdEVEC);
%uimenu(configmenu,'label','Save','callback',cmdSVEC);
%uimenu(configmenu,'label','Clear','callback',cmdCVEC);


%%marks
%--------------------------------------------------------------------------
% Get File menu handle...
%--------------------------------------------------------------------------
toolsmenu=findobj(fig,'Label','Tools');

%--------------------------------------------------------------------------
% Create "Batch" menu.
% -------------------------------------------------------------------------
marksmenu  = uimenu( toolsmenu, 'Label', 'marks','separator','on');


% -------------------------------------------------------------------------
% Create submenus
%--------------------------------------------------------------------------
%
cmd='[EEG,LASTCOM] = pop_continuous2epochs(EEG);';
finalcmdC2E=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd='[EEG,LASTCOM] = pop_epochs2continuous(EEG);';
finalcmdE2C=[try_strings.no_check cmd catch_strings.new_and_hist];


cmd='LASTCOM=''EEG=reject2marks(EEG);'';eval(LASTCOM);';
finalcmdR2M=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd='[EEG,LASTCOM]=pop_marks_flag_gap(EEG);';
finalcmdMFG=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd='[EEG,LASTCOM]=pop_marks_event_gap(EEG);';
finalcmdMEG=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd='[EEG,LASTCOM]=pop_marks_merge_labels(EEG);';
finalcmdCFM=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd='[EEG,LASTCOM]=pop_marks_add_label(EEG);';
finalcmdARF=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd=['if ~isfield(EEG,''marks'');EEG.marks=[];', ...
    'if isempty(EEG.icaweights);', ...
    'EEG.marks=pop_marks_select_data(EEG.marks,''datasize'',size(EEG.data));', ...
    'else;', ...
    'EEG.marks=pop_marks_select_data(EEG.marks,''datasize'',size(EEG.data),''ncomps'',min(size(EEG.icaweights)));'];
finalcmdMPD=[try_strings.no_check cmd catch_strings.new_and_hist];

% Add submenus to the "marks" submenu.
%-------------------------------------
epochmenu=uimenu(marksmenu,'label','epoch/concatenate data');
editmenu=uimenu(marksmenu,'label','edit marks');

uimenu(epochmenu,'label','Epoch data into regular intervals','callback',finalcmdC2E);
uimenu(epochmenu,'label','Concatenate epochs into continuous data','callback',finalcmdE2C);

uimenu(editmenu,'label','Collect ''reject'' structure into ''marks'' structure','callback',finalcmdR2M);
uimenu(editmenu,'label','Mark flag gaps','callback',finalcmdMFG);
uimenu(editmenu,'label','Mark event gaps','callback',finalcmdMEG);
uimenu(editmenu,'label','Combine flag types','callback',finalcmdCFM);
uimenu(editmenu,'label','Add/remove/clear marks flag type','callback',finalcmdARF);


uimenu(marksmenu,'label','Select data','callback',finalcmdMPD);