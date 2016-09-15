function update_config(config_name,option_string)
% I do not think this file ever gets called by anything....

% get rid of global

eval(['global ,' config_struct,';']); % this seems like it would crash...

for i=1:size(option_string,1)
    fieldname=option_string(i,1:strfind(option_string(i,:),',')-1);
    evalin('base',[config_name,'.',fieldname,'=',option_string(i,strfind(option_string(i,:),',')+1),';']);
end
    