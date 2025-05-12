function plotSpatialTuningMap(filename)
% plotSpatialTuningMap('ADR014_1_3096.mat')
% Shows spatial tuning maps and cue PSTH for one neuron

neuralDataDir = 'neuralData';  % adjust if needed
fpath = fullfile(neuralDataDir, filename);

if ~isfile(fpath)
    error("File not found: %s", fpath);
end

% Load neuron
data = load(fpath);
classData = data.MatData.class;

% Preallocate spike rate vectors
fixRates = zeros(1,9);
cueRates = zeros(1,9);
delayRates = zeros(1,9);
allCueSpikes = [];

for c = 1:9
    trials = classData(c).ntr;
    fix = [];
    cue = [];
    dly = [];
    
    for t = 1:length(trials)
        trial = trials(t);
        TS = trial.TS;
        if isempty(TS) || ~isfield(trial, 'Cue_onT') || ...
           ~isfield(trial, 'Sample_onT') || ~isfield(trial, 'Reward_onT')
            continue
        end
        
        % Fixation = 1s before cue
        tFix = [trial.Cue_onT - 1, trial.Cue_onT];
        % Cue = Cue to Sample
        tCue = [trial.Cue_onT, trial.Sample_onT];
        % Delay = Sample to Reward
        tDelay = [trial.Sample_onT, trial.Reward_onT];
        
        fix(end+1) = sum(TS >= tFix(1) & TS < tFix(2));
        cue(end+1) = sum(TS >= tCue(1) & TS < tCue(2));
        dly(end+1) = sum(TS >= tDelay(1) & TS < tDelay(2));

        % For PSTH
        allCueSpikes = [allCueSpikes, TS - trial.Cue_onT];
    end

    fixRates(c) = mean(fix);
    cueRates(c) = mean(cue);
    delayRates(c) = mean(dly);
end

% Prepare layout for heatmaps and PSTH
figure('Color', 'k', 'Position', [100 100 1200 400]);

% Plot 3x3 spatial heatmaps
subplot(2,3,1);
imagesc(reshape(fixRates, [3 3]));
title('Fixation Spatial Map'); colorbar;
axis square; set(gca, 'XTick', [], 'YTick', []);
caxis([0 max([fixRates, cueRates, delayRates])]);

subplot(2,3,2);
imagesc(reshape(cueRates, [3 3]));
title('Cue Spatial Map'); colorbar;
axis square; set(gca, 'XTick', [], 'YTick', []);
caxis([0 max([fixRates, cueRates, delayRates])]);

subplot(2,3,3);
imagesc(reshape(delayRates, [3 3]));
title('Delay Spatial Map'); colorbar;
axis square; set(gca, 'XTick', [], 'YTick', []);
caxis([0 max([fixRates, cueRates, delayRates])]);

% PSTH aligned to Cue — now as line plot
subplot(2,3,[4 5 6]);
bin_width = 0.100;
bin_edges = -1:bin_width:4;
[counts, ~] = histcounts(allCueSpikes, bin_edges);
psth = counts / (bin_width * 9); % normalized per class
bins = bin_edges(1:end-1) + 0.5 * bin_width;

plot(bins, psth, 'w', 'LineWidth', 2);
xlabel('Time from Cue (s)');
ylabel('Firing Rate (Hz)');
title('Cue-Aligned PSTH (All Classes)');
xlim([-1 4]);
grid on;

sgtitle(['Spatial Tuning + PSTH: ', filename], 'Interpreter', 'none');

end
