function visedconfig = propgrid2visedconfig(propgrid,visedconfig)

%global VISED_CONFIG;
if nargin<2;
%    if isempty(VISED_CONFIG);
        visedconfig=visedconfig_obj;
%    else
%        visedconfig=VISED_CONFIG;
%    end
end

npg=length(propgrid.Properties);

%visedconfig=[];
for pi=1:npg;
    eval(['visedconfig.',propgrid.Properties(pi).Name,'=propgrid.Properties(pi).Value;']);
end

if ~isempty(visedconfig.color);
    if iscell(visedconfig.color);
        for i=1:length(visedconfig.color);
            if ~isempty(str2num(visedconfig.color{i}));
                visedconfig.color{i}=str2num(visedconfig.color{i});
            end
        end
    end
end

if length(visedconfig.color)==1;
    if isempty(visedconfig.color{1});
        visedconfig.color='';
    end
end