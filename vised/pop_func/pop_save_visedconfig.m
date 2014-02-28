function pop_save_visedconfig(fname,fpath)


global VISED_CONFIG

if isempty(VISED_CONFIG);
    disp('There is no global VISED_CONFIG structure available to save.');
    return
else
    if nargin < 2;
        [fname,fpath]=uiputfile('*.cfg','Save vised configuration file:');
    end
    save(fullfile(fpath,fname),'VISED_CONFIG');
end
