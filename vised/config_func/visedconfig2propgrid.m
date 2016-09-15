function properties = visedconfig2propgrid(visedconfig)

% get rid of globals

% if nargin==0;%Use the global object BATCH_CONFIG
%     global VISED_CONFIG
%     if isempty(VISED_CONFIG);
%         sprintf('%s','There is no VISED_CONFIG object in the workspace... creating default.\n')
%         VISED_CONFIG=visedconfig_obj;
%     end
%     visedconfig=VISED_CONFIG;
% end

if nargin==0;
    
    try parameters = evalin('base', 'vised_config');
        vised_config=parameters;
        
        %job_config=parameters{2};
    catch %if nonexistent in workspace
        %job_config=batchconfig_obj;
        vised_config=visedconfig_obj;
        %assignin('base', 'job_config',job_config);
    end
end

if iscell(visedconfig.color);
    for i=1:length(visedconfig.color);
        if isnumeric(visedconfig.color{i})
            visedconfig.color{i}=num2str(visedconfig.color{i});
        end
    end
else
    visedconfig.color={visedconfig.color};
end

properties = [ ...
...    PropertyGridField('data_type', visedconfig.data_type, ...
...    'Type', PropertyType('denserealdouble', 'matrix'), ...
...    'Category', 'Data properties', ...
...    'DisplayName', 'data type', ...
...    'Description', ['[datatype] Type of data to present in eegplot scroll window.', ...
...                    '[1 = scalp data, 2 = ICA activation]']) ...
...    PropertyGridField('chan_index', visedconfig.chan_index, ...
...    'Type', PropertyType('denserealdouble', 'matrix'), ...
...    'Category', 'Data properties', ...
...    'DisplayName', 'channel indeces', ...
...    'Description', ['channel indeces to plot in the scroll window.']) ...
...    PropertyGridField('event_type', visedconfig.event_type, ...
...    ... 'Type', PropertyType('cellstr','row'), ...
...    'Category', 'Data properties', ...
...    'DisplayName', 'event types', ...
...    'Description', ['cell array of event type labels to display in the scroll window.']) ...
...    PropertyGridField('winrej_marks_labels', visedconfig.winrej_marks_labels, ...
...    ... 'Type', PropertyType('cellstr', 'row'), ...
...    'Category', 'Data properties', ...
...    'DisplayName', 'winrej mark labels', ...
...    'Description', ['mark types to be included in the initial manual time flagging of the scroll plot.']) ...
    PropertyGridField('quick_evtmk', visedconfig.quick_evtmk, ...
    'Type', PropertyType('char','row',''), ...
    'Category', 'visual editing options', ...
    'DisplayName', 'quick event create', ...
    'Description', ...
        ['String event type to immediately add (without pop up window) when ',...
        'alternate press ([ctrl + left-click] or [right-click]) is executed ', ...
        'on the eegplot data axis. This option overwrites any other specification ', ...
        'for altselectcommand at run time [Default = '' = no quick event].']) ...
    PropertyGridField('quick_evtrm', visedconfig.quick_evtrm, ...
    'Type', PropertyType('char','row',{'off','ext_press','alt_press'}), ...
    'Category', 'visual editing options', ...
    'DisplayName', 'quick event remove', ...
    'Description', ['Enable single click event removal (no pop up GUI). ' ...
    '"ext_press" = remove event when [Shift + left-click] is executed on events in the eegplot figure axis, '...
    '"alt_press" = remove event when [Ctrl + left-click] or [righ-click] is executed on events in the eegplot figure axis. ' ...
    'When set to "alt_press" this option will overwrite any other specification for altselectcommand at run time.' ...
    'When set to "ext_select" this option will overwrite any other specification for extselectcommand (including quick_evtmk) at run time.']) ...
    PropertyGridField('quick_chanflag', visedconfig.quick_chanflag, ...
    'Type', PropertyType('char','row',{'off','ext_press','alt_press'}), ...
    'Category', 'visual editing options', ...
    'DisplayName', 'quick channel flagging', ...
    'Description', ['Enable single click channel flag toggle (no pop up GUI). ' ...
    '"alt press" = toggle channel flag when Shift-left-click is executed on event in eegplot figure axis, '...
    '"ext press" = toggle channel flag when Ctrl-left-click [or simple righ-click] is executed on event in eegplot figure axis']) ...
    PropertyGridField('selectcommand', visedconfig.selectcommand, ...
    'Type', PropertyType('cellstr','row'), ...
    'Category', 'visual editing options', ...
    'DisplayName', 'select command [selectcommand]', ...
    'Description', ['[cell array] list of 3 commands (strings) to run when the mouse ' ...
                      'button is down, when it is moving and when the mouse button is up.']) ...
    PropertyGridField('extselectcommand', visedconfig.extselectcommand, ...
    'Type', PropertyType('cellstr','row'), ...
    'Category', 'visual editing options', ...
    'DisplayName', 'extended select command [extselectcommand]', ...
    'Description', ['[cell array] list of 3 commands (strings) to run when the mouse ' ...
                      'button + SHIFT is down, when it is ' ...
                      'moving and when the mouse button is up.']) ...
    PropertyGridField('altselectcommand', visedconfig.altselectcommand, ...
    'Type', PropertyType('cellstr','row'), ...
    'Category', 'visual editing options', ...
    'DisplayName', 'alternate select command [altselectcommand]', ...
    'Description', ['[cell array] list of 3 commands (strings) to run when the mouse ' ...
                      'button + CTRL (or simple right press) is down, when it is ' ...
                      'moving and when the mouse button is up.']) ...
    PropertyGridField('keyselectcommand', visedconfig.keyselectcommand, ...
    'Type', PropertyType('cellstr','column'), ...
    'Category', 'visual editing options', ...
    'DisplayName', 'key select command [keyselectcommand]', ...
    'Description', ['[cell array] each row is string containing a key character ' ...
                    'followed by "," then a command to execute when the key character ' ...
                    'is pressed while the pointer is over the data axis.']) ...
    PropertyGridField('mouse_data_front', visedconfig.mouse_data_front, ...
    'Type', PropertyType('char','row',{'on','off'}), ...
    'DisplayName', 'Keep figure at front [mouse_data_front]', ...
    'Category', 'eegplot options', ...
    'Description', ['[''on''|''off''] When mouse moves over the data axis bring/keep', ...
                    ' the eegplot figure window at the front {default: ''on''}']) ...
...
...
    PropertyGridField('marks_y_loc', visedconfig.marks_y_loc, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'marks property options', ...
    'DisplayName', 'marks y axis location [marks_y_loc]', ...
    'Description', ['Location along the y axis [percent from bottom to top] ' ...
                    'to diplay the marks structure flags {default .8}. May also ' ...
                    'be an array of values to plot ']) ...
    PropertyGridField('inter_mark_int', visedconfig.inter_mark_int, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'marks property options', ...
    'DisplayName', 'inter-mark interval [inter_mark_int]', ...
    'Description', ['Distance along the y axis [percent from bottom to top] ' ...
                    'to separate each marks type {default .04}.']) ...
    PropertyGridField('inter_tag_int', visedconfig.inter_tag_int, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'marks property options', ...
    'DisplayName', 'inter-tag interval [inter_tag_int]', ...
    'Description', ['Distance along the x axis [percent from left to right] ' ...
                    'to separate each channel tag pointing at flagged channel labels {default .002}.']) ...
    PropertyGridField('marks_col_int', visedconfig.marks_col_int, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'marks property options', ...
    'DisplayName', 'color interval for marks display [marks_col_int]', ...
    'Description', ['Marks surface plots depict values between 0 to 1. ' ...
                    'The marks_col_int sets the interval of color change in the plot {default .1}.']) ...
    PropertyGridField('marks_col_alpha', visedconfig.marks_col_alpha, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'marks property options', ...
    'DisplayName', 'marks surface plot transparency [marks_col_alpha]', ...
    'Description', ['Alpha is a value between 0 and 1 where 0 = transparent and 1 = opaque {default .7}.']) ...
...
...
    PropertyGridField('srate', visedconfig.srate, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'sampling rate [srate]', ...
    'Description', ['Sampling rate in Hz {default|0: 256 Hz}. ' ...
                    'Use in the calculation of', ...
                    'times labels on the x axis of the eegplot scroll window']) ...
    PropertyGridField('spacing', visedconfig.spacing, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'Y axis spacing [spacing]', ...
    'Description', ['Display range per channel (default|0: max(whole_data)-min(whole_data))' ...
                    'Y axis distance in uV between the zero value of', ...
                    'each waveform in the eegplot scroll window.']) ...
...    PropertyGridField('eloc_file', visedconfig.eloc_file, ...
...    'Type', PropertyType('char','row'), ...
...    'DisplayName', 'channel labels', ...
...    'Description', ['[eloc_file] Electrode filename (as in  >> topoplot', ...
...                   'example) to read ascii channel labels. Else,', ...
...                   '[vector of integers] -> Show specified channel numbers.', ...
...                   'Else, [] -> Do not show channel labels ', ...
...                   '{default|0 -> Show [1:nchans]}']) ...
    PropertyGridField('limits', visedconfig.limits, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'time limits [limits]', ...
    'Description', ['[start end] Time limits for data epochs in ms (for labeling' ... 
                    'purposes only).']) ...
...    PropertyGridField('freqlimits', visedconfig.freqlimits, ...
...    'Type', PropertyType('denserealdouble','matrix'), ...
...    'Category', 'eegplot options', ...
...    'DisplayName', 'frequency limits [freqlimits]', ...
...    'Description', ['[start end] If plotting epoch spectra instead of data, frequency' ... 
...                   'limits of the display. (Data should contain spectral values).']) ...
    PropertyGridField('winlength', visedconfig.winlength, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'window time length [winlength]', ...
    'Description', ['[value] Seconds (or epochs) of data to display in window {default: 5}']) ...
    PropertyGridField('dispchans', visedconfig.dispchans, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'n channels to display [dispchans]', ...
    'Description', ['[integer] Number of channels to display in the activity window ' ...
                   '{default: from data}.  If < total number of channels, a vertical ' ... 
                   'slider on the left side of the figure allows vertical data scrolling.']) ...
    PropertyGridField('title', visedconfig.title, ...
    'Type', PropertyType('char','row'), ...
    'DisplayName', 'title', ...
    'Category', 'eegplot options', ...
    'Description', ['Figure title {default: none}']) ...
    PropertyGridField('xgrid', visedconfig.xgrid, ...
    'Type', PropertyType('char','row',{'on','off'}), ...
    'DisplayName', 'X axis grid lines [xgrid]', ...
    'Category', 'eegplot options', ...
    'Description', ['[''on''|''off''] Toggle display of the x-axis grid {default: ''off''}']) ...
    PropertyGridField('ygrid', visedconfig.ygrid, ...
    'Type', PropertyType('char','row',{'on','off'}), ...
    'DisplayName', 'Y axis grid lines [ygrid]', ...
    'Category', 'eegplot options', ...
    'Description', ['[''on''|''off''] Toggle display of the y-axis grid {default: ''off''}']) ...
    PropertyGridField('ploteventdur', visedconfig.ploteventdur, ...
    'Type', PropertyType('char','row',{'on','off'}), ...
    'DisplayName', 'plot event duration [ploteventdur]', ...
    'Category', 'eegplot options', ...
    'Description', ['[''on''|''off''] Toggle display of event duration { default: ''off'' }']) ...
    PropertyGridField('data2', visedconfig.data2, ...
    'Type', PropertyType('char','row'), ...
    'DisplayName', 'ovelay data', ...
    'Category', 'eegplot options', ...
    'Description', ['[float array] identical size to the original data and ' ...
                   'plotted on top of it.']) ...
...
    PropertyGridField('command', visedconfig.command, ...
    'Type', PropertyType('char','row'), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'button command [command]', ...
    'Description', ['[''string''] Matlab command to evaluate when the ''REJECT'' button is ' ...
                   'clicked. The ''REJECT'' button is visible only if this parameter is ' ...
                   'not empty. As explained in the "Output" section below, the variable ' ...
                   '''TMPREJ'' contains the rejected windows (see the functions ' ...
                   'eegplot2event() and eegplot2trial()).']) ...
    PropertyGridField('butlabel', visedconfig.butlabel, ...
    'Type', PropertyType('char','row'), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'button label [butlabel]', ...
    'Description', ['Reject button label. {default: ''REJECT''}']) ...
...    PropertyGridField('winrej', visedconfig.winrej, ...
......    'Type', PropertyType('denserealdouble','matrix'), ...
...    'Category', 'eegplot options', ...
...    'DisplayName', 'window rejection', ...
...    'Description', ['[start end R G B e1 e2 e3 ...] Matrix giving data periods to mark ' ...
...                    'for rejection, each row indicating a different period ' ...
...                    '[start end] = period limits (in frames from beginning of data); ' ...
...                    '[R G B] = specifies the marking color; ' ...
...                    '[e1 e2 e3 ...] = a (1,nchans) logical [0|1] vector giving ' ...
...                    '     channels (1) to mark and (0) not mark for rejection.']) ...
PropertyGridField('color', visedconfig.color, ...
'Type', PropertyType('cellstr','column'), ...
'Category', 'eegplot options', ...
'DisplayName', 'channel color [color]', ...
'Description', ['[''on''|''off''|cell array] Plot channels with different colors. ' ...
'If an RGB cell array {''r'' ''b'' ''g''}, channels will be plotted ' ...
'using the cell-array color elements in cyclic order {default:''off''}.']) ...
...
PropertyGridField('wincolor', visedconfig.wincolor, ...
'Type', PropertyType('denserealdouble','matrix'), ...
'Category', 'eegplot options', ...
'DisplayName', 'axis marking color [wincolor]', ...
'Description', ['[color] Color to use to mark data stretches or epochs {default: ' ...
'[ 0.7 1 0.9]}']) ...
......    PropertyGridField('events', visedconfig.events, ...
......    'DisplayName', 'events', ...
......    'Description', ['[struct] EEGLAB event structure (EEG.event) to use to show events.']) ...
    PropertyGridField('submean', visedconfig.submean, ...
    'Type', PropertyType('char','row',{'on','off'}), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'subtract signal mean [submean]', ...
    'Description', ['[''on''|''off''] Remove channel means in each window {default: ''on''}']) ...
    PropertyGridField('position', visedconfig.position, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'figure window [position]', ...
    'Description', ['[lowleft_x lowleft_y width height] Position of the figure in pixels.']) ...
    PropertyGridField('tag', visedconfig.tag, ...
    'Type', PropertyType('char','row'), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'figure window [tag]', ...
    'Description', ['[string] Matlab object tag to identify this eegplot() window (allows ' ...
                    'keeping track of several simultaneous eegplot() windows).']) ...
    PropertyGridField('children', visedconfig.children, ...
    'Type', PropertyType('denserealdouble','matrix'), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'figure [children] handle', ...
    'Description', ['[integer] Figure handle of a *dependent* eegplot() window. Scrolling ' ...
                    'horizontally in the master window will produce the same scroll in ' ...
                    'the dependent window. Allows comparison of two concurrent datasets, ' ...
                    'or of channel and component data from the same dataset.']) ...
    PropertyGridField('scale', visedconfig.scale, ...
    'Type', PropertyType('char','row',{'on','off'}), ...
    'Category', 'eegplot options', ...
    'DisplayName', 'amplitude [scale]', ...
    'Description', ['[''on''|''off''] Display the amplitude scale {default: ''on''}.']) ...
...    PropertyGridField('mocap', visedconfig.mocap, ...
......    'Type', PropertyType('denserealdouble','matrix'), ...
...    'Category', 'eegplot options', ...
...    'DisplayName', 'motion capture', ...
...    'Description', ['[''on''|''off''] Display motion capture data in a separate figure. ' ...
...                     'To run, select an EEG data period in the scolling display using ' ...
...                     'the mouse. Motion capture (mocap) data should be ' ...
...                     'under EEG.moredata.mocap.markerPosition in xs, ys and zs fields which are ' ...
...                     '(number of markers, number of time points) arrays.']) ...
                      ];
