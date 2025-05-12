% now we tie it all together...
% goal: batch process all epochs: fixation, cue, and delay 
% also include ANOVAs for all neurons

clear; clc;

data_folder = 'D:/GithubRepos/neuralDataDemo/neuralData';
files = dir(fullfile(data_folder,'*.mat'));
results = [];

for i = 1:length(files)
    fname = files(i).name;

    try
        data = load(fname);
        classData = data.MatData.class;

        % only process spatial tasks
        if length(classData) ~= 9
            fprintf("Skipping %s: not spatial (classes not equal to 9)\n", fname);
            continue
        end

        % pass all epochs thru to our analysis algorithm
        [fixSpikes, fixP] = analyzeEpochSpikes(classData, 'fixation', '');
        [cueSpikes, cueP] = analyzeEpochSpikes(classData, 'Cue_onT', 'Sample_onT');
        [delaySpikes, delayP] = analyzeEpochSpikes(classData, 'Sample_onT', 'Reward_onT');


        % meta data
        parts = split(fname, {'_', '.'});
        monkeyID = parts{1};
        neuronID = str2double(parts{end-1});

        % store results
        results = [results; {fname, monkeyID, neuronID, fixSpikes, cueSpikes, delaySpikes, fixP, cueP, delayP}];

        fprintf("PASS: %s processed\n", fname);

    catch ME
        fprintf("FAIL: Error with %s: %s\n", fname, ME.message);
        continue
    end
end

% === Convert to table and save ===
resultsTable = cell2table(results, ...
    'VariableNames', {'FileName', 'MonkeyID', 'NeuronID', 'FixationSpikesPerClass', 'CueSpikesPerClass', 'DelaySpikesPerClass', 'p_Fixation', 'p_Cue', 'p_Delay'});

% add flags for easier filtering / selecting tuned neurons easy later
resultsTable.IsFixationTuned = resultsTable.p_Fixation < 0.05;
resultsTable.IsCueTuned = resultsTable.p_Cue < 0.05;
resultsTable.IsDelayTuned = resultsTable.p_Delay < 0.05;

save('epoch_spike_analysis.mat', 'resultsTable');
fprintf("\nPASS: All epochs processed and saved to epoch_spike_analysis.mat\n");
