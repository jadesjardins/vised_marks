function [EEG,data_sd]=chan_variance(EEG,varargin)

g=struct(varargin{:});

try g.datafield; catch, g.datafield='data'; end;
if strcmp(g.datafield,'data');
    try g.chinds;    catch, g.chinds=1:EEG.nbchan; end;
else
    try g.chinds;    catch, g.chinds=1:size(EEG.icawinv,2); end;
end
try g.latinds;   catch, g.latinds=1:EEG.pnts; end;
try g.plotfigs;  catch, g.plotfigs='off'; end;

if strcmp(g.datafield,'icaact') && isempty(EEG.icaact);
    for i=1:EEG.trials;
        tmpdata(:,:,i)=(EEG.icaweights*EEG.icasphere)*(EEG.data(:,:,i));
    end
    data=tmpdata(g.chinds,:,g.latinds);
else
    eval(['data=EEG.',g.datafield,'(g.chinds,:,g.latinds);']);
end
            
for i=1:size(data,3);
    data_sd(:,i)=std(data(:,:,i),[],2);
end

if strcmp(g.plotfigs,'on');
    figure;surf(double(data_sd),'LineStyle','none');
    axis('tight');
    view(0,90);
end