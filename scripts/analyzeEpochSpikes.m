function [spikesPerClass, p_ANOVA] = analyzeEpochSpikes(classData, epochStartField, epochEndField)

% this code was made to generalize and combine my initial scripts for fixation
% period: analyzeSingleNeuron.m , analyzeFixationSummary.m and analyzeAllNeurons.m.
% This code computes average spike counts during a specified epoch (time interval)
% for each cue class. I also added 'fixation' to be a keyword so we can use
% this for our custom time interval.
%

% Note: I have also decided to implement real ANOVA from here on out.

% inputs:
%   classData   ==>     1x9 struct –> classData = data.MatData.class
%   epochStartField ==> (string) –> field name for start time
%   epochEndField   ==> (string) –> field name for end time

%   epoch fields can be found in the variables of each ntr ("Cue_onT,
%   Sample_onT, etc...)
%
% output:
%   spikesPerClass -->  1x9 – mean spike counts for each cue class (1–9)

spikesPerClass = zeros(1, 9);
% preallocate and initialize array for avg spikes per class

allSpikeCounts = [];
allLabels = [];
%this is used for anova


for c = 1:9 % loop thru all classes
    trials = classData(c).ntr;
    spikeCounts = zeros(1, length(trials));

    for t = 1:length(trials) % loop thru all trials
        TS = trials(t).TS;

        if isempty(TS)
            continue
            %skips if no spike
        end


        % === added this later to hande fixation === %
        if strcmp(epochStartField, 'fixation')
            if ~isfield(trials(t), 'Cue_onT') % if Cue_onT is missing, skip
                continue
            end
            tStart = trials(t).Cue_onT - 1; % custom start for fix period
            tEnd = trials(t).Cue_onT; % cue onset is end of fixation
        else
            if ~isfield(trials(t), epochStartField) || ~isfield(trials(t), epochEndField)
                continue % skip trial if required timing fields are missing
            end
            tStart = trials(t).(epochStartField); % ntr(t).Cue_onT --> if 'Cue_onT' is passed in
            tEnd = trials(t).(epochEndField);
        end
        
        spikeCount = sum(TS >= tStart & TS < tEnd);
        spikeCounts(t) = spikeCount;
        %count spikes in time interval
        
        allSpikeCounts(end+1) = spikeCount; % puts the spike count for this trial in an array
        allLabels(end+1) = c; % puts a correspondong label in a different array for this class

    end
    
    %add avg spikes for all trials into our array
    spikesPerClass(c) = mean(spikeCounts);
end

% Real one way ANOVE

try
    p_ANOVA = anova1(allSpikeCounts, allLabels, 'off');
catch
    p_ANOVA = NaN; % fallback in case insufficient data / anova fails
end
