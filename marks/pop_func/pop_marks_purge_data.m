function [EEG,com]=pop_marks_purge_data(EEG,infotype,flaglabels,varargin)

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            


% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_marks_purge_data;
	return;
end;	

%% INITIATE VARARGIN STRUCTURES...
try
    options = varargin;
    for index = 1:length(options)
        if iscell(options{index}) & ~iscell(options{index}{1}), options{index} = { options{index} }; end;
    end;
    if ~isempty( varargin ), g=struct(options{:});
    else g= []; end;
catch
    disp('ve_eegplot() error: calling convention {''key'', value, ... } error'); return;
end;

try g.exact; catch, g.exact='on';end


%% handle inputs
infotype_cell={'time_info','chan_info'};
if ~isempty(EEG.icaweights);
    infotype_cell{3}='comp_info';
end

if exist('infotype');
    infotype_ind=find(strcmp(infotype,infotype_cell));
else
    infotype_ind=1;
end

%% pop up window
% -------------
if nargin < 3
    
    results=inputgui( ...
        {[1] [3 3] [3 3] [5 1]}, ...
        {...
        ... %1
        {'style','text','string',blanks(80)}, ...
        ... %2
        {'Style', 'text', 'string', 'Information type to purge'}, ...
        {'Style', 'popup', 'string', infotype_cell, 'value',infotype_ind,'tag', 'pop_it'...
        'callback', ['switch get(findobj(gcbf, ''tag'', ''pop_it''), ''value'');' ...
        '    case 1;' ...
        '        tmp_flaglabels = {EEG.marks.time_info.label};' ...
        '        set(findobj(gcbf, ''tag'', ''but_fl''), ''callback'',' ...
        '            [''[flaglabel_ind,flaglabel_str,flaglabel_cell]=pop_chansel({EEG.marks.time_info.label});' ...
        '             set(findobj(gcbf, ''''tag'''', ''''edt_fl''''), ''''string'''', vararg2str(flaglabel_cell))'']);' ...
        '        set(findobj(gcbf, ''tag'', ''edt_fl''), ''string'', '''');' ...
        '    case 2;' ...
        '        tmp_flaglabels = {EEG.marks.chan_info.label};' ...
        '        set(findobj(gcbf, ''tag'', ''but_fl''), ''callback'',' ...
        '            [''[flaglabel_ind,flaglabel_str,flaglabel_cell]=pop_chansel({EEG.marks.chan_info.label});' ...
        '             set(findobj(gcbf, ''''tag'''', ''''edt_fl''''), ''''string'''', vararg2str(flaglabel_cell))'']);' ...
        '        set(findobj(gcbf, ''tag'', ''edt_fl''), ''string'', '''');' ...
        '    case 3;' ...
        '        tmp_flaglabels = {EEG.marks.comp_info.label};' ...
        '        set(findobj(gcbf, ''tag'', ''but_fl''), ''callback'',' ...
        '            [''[flaglabel_ind,flaglabel_str,flaglabel_cell]=pop_chansel({EEG.marks.comp_info.label});' ...
        '             set(findobj(gcbf, ''''tag'''', ''''edt_fl''''), ''''string'''', vararg2str(flaglabel_cell))'']);' ...
        '        set(findobj(gcbf, ''tag'', ''edt_fl''), ''string'', '''');' ...
        '    end;']}, ...
        ... %3
        {'Style', 'text', 'string', 'flag labels to purge'},...
        {'style','checkbox','string','exact label','value',1}, ...
        ... %4
        {'Style', 'edit', 'string', '', 'tag', 'edt_fl'}, ...
        {'Style', 'pushbutton', 'string', '...','tag','but_fl', ...
        'callback', ['[flaglabel_ind,flaglabel_str,flaglabel_cell]=pop_chansel({EEG.marks.time_info.label});' ...
        'set(findobj(gcbf, ''tag'', ''edt_fl''), ''string'', vararg2str(flaglabel_cell))']}, ...
        }, ...
        'pophelp(''pop_mark_flag_gap'');', 'remove data based on information int he marks structure -- pop_mark_purge_data()' ...
        );
    
    infotype_ind  	 = results{1};
    exact_val        = results{2};
    flaglabels     	 = eval(['{',results{3},'};']);
end

infotype=infotype_cell{infotype_ind};

%if exact_val
%    g.exact='on';
%else
%    g.exact='off';
%end

%% perform purge...
switch infotype
    
    case 'time_info'
        
        rminds=marks_label2index(EEG.marks.time_info,flaglabels,'indexes','exact',g.exact);
        rmbnds=marks_label2index(EEG.marks.time_info,flaglabels,'bounds','exact',g.exact);

        for i=1:length(EEG.marks.time_info)
            EEG.marks.time_info(i).flags=EEG.marks.time_info(i).flags(setdiff([1:EEG.pnts],rminds));
        end
        
        EEG=eeg_eegrej(EEG,rmbnds);

    case 'chan_info'
        
        rmch=marks_label2index(EEG.marks.chan_info,flaglabels,'indexes','exact',g.exact);
        
        for i=1:length(EEG.marks.chan_info)
            EEG.marks.chan_info(i).flags=EEG.marks.chan_info(i).flags(setdiff([1:EEG.nbchan],rmch));
        end
        
        EEG=pop_select(EEG,'nochannel',rmch);
        
    case 'comp_info'
        
        ncomp=min(size(EEG.icaweights));
        rmcomp=marks_label2index(EEG.marks.comp_info,flaglabels,'indexes','exact',g.exact);
        
        for i=1:length(EEG.marks.comp_info)
            EEG.marks.comp_info(i).flags=EEG.marks.comp_info(i).flags(setdiff([1:ncomp],rmcomp));
        end
        
        EEG=pop_subcomp(EEG,rmcomp);
        
end
% create the string command
% -------------------------
%com = ['EEG = pop_marks_purgedata(EEG,''',infotype_cell{infotype_ind},''',{',flaglabels,'});'];
%exec_com = ['EEG = marks_purgedata(EEG,''',infotype_cell{infotype_ind},''',{',flaglabels,'});']

%eval(exec_com)
