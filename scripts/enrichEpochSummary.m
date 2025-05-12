% goal: compute the selectivity index (SI) for each
% epocha nd add it to an enriched table

clear; clc;

load('epoch_spike_analysis.mat');  % loads: resultsTable

n = height(resultsTable); % num of neurons(rows)

% preallocate
SI_fix = zeros(n, 1);
SI_cue = zeros(n, 1);
SI_delay = zeros(n, 1);

for i = 1:n
    % grab 1x9 spike vectors
    fix = resultsTable.FixationSpikesPerClass(i, :);
    cue = resultsTable.CueSpikesPerClass(i, :);
    dly = resultsTable.DelaySpikesPerClass(i, :);

    % SI = (max - mean) / (max + mean)
    % we add eps (the smallest num in matlab) just in case max&mean are
    % both zero
    SI_fix(i) = (max(fix) - mean(fix)) / (max(fix) + mean(fix) + eps);
    SI_cue(i) = (max(cue) - mean(cue)) / (max(cue) + mean(cue) + eps);
    SI_delay(i) = (max(dly) - mean(dly)) / (max(dly) + mean(dly) + eps);
end

% Add to table
resultsTable.SI_Fixation = SI_fix;
resultsTable.SI_Cue = SI_cue;
resultsTable.SI_Delay = SI_delay;

% remove neurons with '_err.mat' in the filename
resultsTable(contains(resultsTable.FileName, '_err.mat'), :) = [];



% Save
save('epoch_spike_analysis_enriched.mat', 'resultsTable');
fprintf("\nPASS: Enriched table saved as epoch_spike_analysis_enriched.mat\n");
