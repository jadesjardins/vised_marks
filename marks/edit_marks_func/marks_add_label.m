function EEG = marks_add_label(EEG,info_type,mark_prop)

if ~isfield(EEG,'marks')
    %EEG=marks_init(EEG);
    nflags=0;
else
    try eval(['nflags=length(EEG.marks.',info_type,');']);
    catch, nflags=0;end
end

flagind=1;

switch info_type

    case 'chan_info'
        if isfield(EEG,'marks');
            if isfield(EEG.marks,'chan_info')
                flagind=find(strcmp(mark_prop{1},{EEG.marks.chan_info.label}));
                if isempty(flagind);
                    flagind=nflags+1;
                    tmpflags=mark_prop{5};
                else
                    disp(['merging new flags into existing ''',mark_prop{1},''' mark label.']);
                    tmpflags=any([mark_prop{5},EEG.marks.chan_info(flagind).flags],2);
                end
            end
        end
        EEG.marks.chan_info(flagind).label=mark_prop{1};
        EEG.marks.chan_info(flagind).line_color=mark_prop{2};
        EEG.marks.chan_info(flagind).tag_color=mark_prop{3};
        EEG.marks.chan_info(flagind).order=mark_prop{4};
        EEG.marks.chan_info(flagind).flags=mark_prop{5};
        
    case 'comp_info'
        if isfield(EEG,'marks');
            if isfield(EEG.marks,'comp_info')
                flagind=find(strcmp(mark_prop{1},{EEG.marks.comp_info.label}));
                if isempty(flagind);
                    flagind=nflags+1;
                    tmpflags=mark_prop{5};
                else
                    disp(['merging new flags into existing ''',mark_prop{1},''' mark label.']);
                    tmpflags=any([mark_prop{5},EEG.marks.comp_info(flagind).flags],2);
                end
            end
        end
        EEG.marks.comp_info(flagind).label=mark_prop{1};
        EEG.marks.comp_info(flagind).line_color=mark_prop{2};
        EEG.marks.comp_info(flagind).tag_color=mark_prop{3};
        EEG.marks.comp_info(flagind).order=mark_prop{4};
        EEG.marks.comp_info(flagind).flags=mark_prop{5};
        
    case 'time_info'
        if isfield(EEG,'marks');
            if isfield(EEG.marks,'time_info')
                flagind=find(strcmp(mark_prop{1},{EEG.marks.time_info.label}));
                if isempty(flagind);
                    flagind=nflags+1;
                    tmpflags=mark_prop{3};
                else
                    disp(['merging new flags into existing ''',mark_prop{1},''' mark label.']);
                    tmpflags=any([mark_prop{3};EEG.marks.time_info(flagind).flags],1);
                end
            end
        end
        EEG.marks.time_info(flagind).label=mark_prop{1};
        EEG.marks.time_info(flagind).color=mark_prop{2};
        EEG.marks.time_info(flagind).flags=mark_prop{3};
        
        
    otherwise
        disp('check field string...');
        
end