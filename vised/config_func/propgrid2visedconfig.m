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
