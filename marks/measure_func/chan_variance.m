function [EEG,data_sd]=chan_variance(EEG,varargin)

g=struct(varargin{:});

try g.data_field; catch, g.data_field='data'; end;
if strcmp(g.data_field,'data');
    try g.chan_inds;    catch, g.chan_inds=1:EEG.nbchan; end;
else
    try g.chan_inds;    catch, g.chan_inds=1:size(EEG.icawinv,2); end;
end
try g.epoch_inds;   catch, g.epoch_inds=1:EEG.pnts; end;
try g.plot_figs;  catch, g.plot_figs='off'; end;

if strcmp(g.data_field,'icaact') && isempty(EEG.icaact);
    for i=1:EEG.trials;
        tmpdata(:,:,i)=(EEG.icaweights*EEG.icasphere)*(EEG.data(:,:,i));
    end
    data=tmpdata(g.chan_inds,:,g.epoch_inds);
else
    eval(['data=EEG.',g.data_field,'(g.chan_inds,:,g.epoch_inds);']);
end
            
for i=1:size(data,3);
    data_sd(:,i)=std(data(:,:,i),[],2);
end

if strcmp(g.plot_figs,'on');
    figure;surf(double(data_sd),'LineStyle','none');
    axis('tight');
    view(0,90);
end