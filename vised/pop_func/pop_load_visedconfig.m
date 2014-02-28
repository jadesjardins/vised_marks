function [com] = pop_load_visedconfig(fname,fpath)

if nargin < 2;
    [fname,fpath]=uigetfile('*.cfg','Select vised configuration file:');
end

global VISED_CONFIG

if ~isempty(VISED_CONFIG)
    VISED_CONFIG=[];
end

com=['global VISED_CONFIG;load(''',fullfile(fpath,fname), ''', ''-mat'');'];

evalin('base',com);
