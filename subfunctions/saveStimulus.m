function fileName = saveStimulus(path, fileName, DataBlock, Units, parameterFile, trial, CustomTag)
%function exportFileName = saveStimulus(DataBlock, parameterFile, trial,
%exportPathName, preName)
%
% saves data block and parameters of a single labChart trial (block) to the
% specified path. Note that a labChart block may contain several flyfly
% trials, since the labchart blocks are cut by the (optional) flyfly
% pauses. Which flyfly trials corresponds to this block is specified by the
% parameter "trial", which is in the format [trial1 trial2 ... trialn].
% (Note that trial1 is not equal to 1.)
%
%

load(parameterFile);

% Correct for differences in capitalisation
if exist('stimulus', 'var')
    Stimulus = stimulus;
    clear stimulus
end

try 
    t = datetime(timeStartPrecision);
catch
    t = datetime(timeStart, 'Format','d-MMM-y HH_mm_ss');
end
fileName = [datestr(t, 'yyyy-mm-dd@hh_MM_ss') '-' fileName];

%loads:
%-Stimulus
%-debugData
%-message
%-skippedInTrial
%-timeFinish
%-timeStart
%-totalSkippedFrames

Experiment_Name = Stimulus.name;

if isempty(CustomTag)
    clear CustomTag;
end
if isempty(Units)
    clear Units;
end

for n = 1:length(Stimulus.layers)
    
   % layer     = debugData.stimulus.layers(n); old version
    layer     = Stimulus.layers(n); %sarah's changes
    
    for k = 1:length(trial)
       % trialData = layer.data(:,trial(k)); old version
        trialData = cell2mat(struct2cell(layer.Param(:,trial(k)))); %sarah's changes

        
        layerName = layer.name;
        layerName = regexprep(layerName, ' ', '_'); %replace space with underscore
        
        eval(['Layer_' num2str(n) '_Name = layerName;']);
        
        [R C] = size(trialData);
        for r = 1:R
            
          %  parName = [layer.parameters{r}]; %old version
          parName = fieldnames(layer.Param); %sarah's changes
           parName = parName{r}; %sarah's changes
            parName = regexprep(parName, ' ', '_'); %replace space with underscore

            eval(sprintf('Layer_%d_Parameters.%s(%d)=trialData(%d);',n,parName,k,r));
        end
    end
end

A_spacer = '-------Data and Parameters-----------';
Z_spacer = '-------Additional Stuff -------------';

clear R C parName n layer Stimulus layerName r skippedInTrial ...
    trialData timeFinish exportPathName trial preName k;

save(fullfile(path,fileName));



