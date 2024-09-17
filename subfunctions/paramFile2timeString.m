function [timeString, fileNameList, trial] = paramFile2timeString(directory, date)
%
% Aquire a list of all the dates corresponding to the parameter files in
% 'directory', with an optional date given
%

disp(directory)
fileList = dir(directory); %list of all files in folder "directory"
N = length(fileList);

% Aquire timeString for all trials in an experiment, one experiment each
% iteration

p = 0; % Counter of trials

for n = 3:N % First two files are "." and "..", ignore them
    
    ok = 0;
    fileName = fileList(n).name;
    
    if strcmp(fileName(end-3:end), '.mat')
        
        dateString = fileName(end-23:end-4); % experimentName-dd-mmm-yyyy HH_MM_SS.mat
                                             % -> fileName(end-23:end-4) = dd-mmm-yyyy HH_MM_SS;
        
        dateString = regexprep(dateString, '_', ':'); %switch to normal format
        fileDate   = dateString(1:11); %pick out date
        
        if strcmp(fileDate, date)
            ok = 1;
        end
    end
    
    if ok %just use parameters from same day
        % We don't know capitalisation of some files so we get matlab to
        % temporarily shut up
        warning('off')
        load([directory fileName], 'debugData', 'timeStartPrecision', 'Stimulus', 'stimulus');
        warning('on')

        if exist('stimulus', 'var') 
            Stimulus = stimulus;
            clear stimulus
        end

        numLayers = length(Stimulus.layers); % Number layers used
        numRuns   = length(debugData.trialSubset);
        %numRuns   = length(skippedInTrial);  %numer of trials
        
        T.time     = [];
        T.pause    = [];
        T.preStim  = [];
        T.postStim = [];
        
        for z = 1:numLayers
            % GET STIMULUS TIMES FOR EACH LAYER
            T.time(z,:)     = debugData.screenData.ifi*[Stimulus.layers(z).Param(:).Time]';
            T.pause(z,:)    = debugData.screenData.ifi*[Stimulus.layers(z).Param(:).PauseTime]';
            T.preStim(z,:)  = debugData.screenData.ifi*[Stimulus.layers(z).Param(:).PreStimTime]';
            T.postStim(z,:) = debugData.screenData.ifi*[Stimulus.layers(z).Param(:).PostStimTime]';
        end
        
        %Array with duration of all trials
        T.trialDuration = T.time + T.preStim + T.postStim + T.pause; %total trial time
        T.stimDuration  = T.time + T.preStim + T.postStim;           %stim time
        T.drawEndTime   = T.time + T.preStim;                        %end drawing
        
        T.maxTrialDuration = max(T.trialDuration,[],1);
        T.maxStimDuration  = max(T.stimDuration,[],1);
        
        if exist('timeStartPrecision', 'var') %check if variable exist
            % Determine what kind of date string we're using
            if ischar(timeStartPrecision) || isstring(timeStartPrecision)
                % Attempt to grab correct time format
                try
                    trialTime = datetime(timeStartPrecision, 'Format', 'd-MMM-y HH:mm:ss:SSS');
                catch
                    timeStartPrecision = [fileDate ' ' convertStringsToChars(timeStartPrecision)];
                    trialTime = datetime(timeStartPrecision, 'Format', 'd-MMM-y HH:mm:ss:SSS');
                end
                trialTime = datenum(trialTime);
            else
                % Use old method and function
                trialTime = datenum(timeStartPrecision);
            end
        else
            trialTime = datenum(dateString); %time of first trial
        end
        
        newTrial = 1;
        for k = 1:numRuns
            
            if newTrial
                p = p+1;
                timeString(p)   = trialTime;
                trial{p}        = k;
                fileNameList{p} = fileName;
                
            else %trial fits with the one before it
                trial{p}(end+1) = k;
            end
            
            if T.maxStimDuration(k) < T.maxTrialDuration(k) %: last trial in seq
                newTrial = 1;
            else
                newTrial = 0;
            end
            
            trialTime = trialTime + T.maxTrialDuration(k)/24/60/60;
        end
        
    end
end

timeString   = timeString';   %return as single col
fileNameList = fileNameList'; %return as single col
trial        = trial';
