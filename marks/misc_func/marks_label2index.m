function out_array=marks_label2index(marks_struct,labels,out_type,varargin)

%% INITIATE VARARGIN STRUCTURES...
try
    options = varargin;
    for index = 1:length(options)
        if iscell(options{index}) & ~iscell(options{index}{1}), options{index} = { options{index} }; end;
    end;
    if ~isempty( varargin ), g=struct(options{:});
    else g= []; end;
catch
    disp('marks_label2index() error: calling convention {''key'', value, ... } error'); return;
end;

try g.exact; catch, g.exact='on';end

if strcmp(g.exact,'off')
    labels=marks_match_label(labels,{marks_struct.label});
end

if ischar(labels);
    labels={labels};
end

if ~exist('out_type')
    out_type='indexes';
end

for i=1:length(labels);
    if length(marks_struct)>1
        flagind=find(strcmp(labels{i},{marks_struct.label}));
    else
        flagind=1;
    end
    for ii=1:length(flagind);
        if length(size(marks_struct(flagind(ii)).flags))==2;
            flagscat(i,:)=marks_struct(flagind(ii)).flags;
        elseif length(size(marks_struct(flagind(ii)).flags))==3;
            flagscat(i,:)=squeeze(any(marks_struct(flagind(ii)).flags,2));
        end
    end
end

flags=any(flagscat,1);
switch out_type
    case 'flags'
        out_array=flags;
    case {'indexes','indices'}
        out_array=find(flags);
    case 'bounds'
        bounds=find(diff(flags));
        if flags(1)==1;bounds=[0,bounds];end
        if flags(length(flags))==1;bounds=[bounds,length(flags)];end
        out_array=reshape(bounds,2,length(bounds)/2)';
        out_array(:,1)=out_array(:,1)+1;
end