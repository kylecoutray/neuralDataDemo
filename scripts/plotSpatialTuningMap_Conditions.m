function plotSpatialTuningMap_Conditions(filename)
% plotSpatialTuningMap_Conditions('ADR014_1_3096.mat')
% Shows match vs non-match spatial tuning maps and PSTHs for one neuron

%mac directory: /Users/kyle./Documents/GitHub/neuralDataDemo/neuralData/
neuralDataDir = '/Users/kyle./Documents/GitHub/neuralDataDemo/neuralData/';  % adjust if needed
fpath = fullfile(neuralDataDir, filename);

if ~isfile(fpath)
    error("File not found: %s", fpath);
end

% Load neuron
data = load(fpath);
classData = data.MatData.class;

% Preallocate
rates = struct('match', struct('fix', zeros(1,9), 'cue', zeros(1,9), 'delay', zeros(1,9), 'psth', []), ...
               'nonmatch', struct('fix', zeros(1,9), 'cue', zeros(1,9), 'delay', zeros(1,9), 'psth', []));

% Trial loop
for c = 1:9
    match = struct('fix', [], 'cue', [], 'delay', [], 'spikes', []);
    nonmatch = match;

    trials = classData(c).ntr;
    for t = 1:length(trials)
        trial = trials(t);
        if ~isfield(trial, 'IsMatch') || isempty(trial.TS)
            continue
        end
        TS = trial.TS;
        cue = trial.Cue_onT;
        sample = trial.Sample_onT;
        reward = trial.Reward_onT;

        tFix = [cue - 1, cue];
        tCue = [cue, sample];
        tDelay = [sample, reward];
        alignedSpikes = TS - cue;

        if trial.IsMatch
            match.fix(end+1) = sum(TS >= tFix(1) & TS < tFix(2));
            match.cue(end+1) = sum(TS >= tCue(1) & TS < tCue(2));
            match.delay(end+1) = sum(TS >= tDelay(1) & TS < tDelay(2));
            match.spikes = [match.spikes, alignedSpikes];
        else
            nonmatch.fix(end+1) = sum(TS >= tFix(1) & TS < tFix(2));
            nonmatch.cue(end+1) = sum(TS >= tCue(1) & TS < tCue(2));
            nonmatch.delay(end+1) = sum(TS >= tDelay(1) & TS < tDelay(2));
            nonmatch.spikes = [nonmatch.spikes, alignedSpikes];
        end
    end

    % Store average per class
    rates.match.fix(c) = mean(match.fix);
    rates.match.cue(c) = mean(match.cue);
    rates.match.delay(c) = mean(match.delay);

    rates.nonmatch.fix(c) = mean(nonmatch.fix);
    rates.nonmatch.cue(c) = mean(nonmatch.cue);
    rates.nonmatch.delay(c) = mean(nonmatch.delay);
end

% Compute PSTHs
bin_width = 0.1;
bin_edges = -1:bin_width:4;
bin_centers = bin_edges(1:end-1) + 0.5*bin_width;

rates.match.psth = histcounts(match.spikes, bin_edges) / (bin_width * 9);
rates.nonmatch.psth = histcounts(nonmatch.spikes, bin_edges) / (bin_width * 9);

% === Plotting ===
figure('Color', 'k', 'Position', [100 100 1400 600]);

% Top row: spatial maps
maps = {'fix','cue','delay'};
for i = 1:3
    subplot(3,4,i); 
    imagesc(reshape(rates.match.(maps{i}), [3 3]));
    title(['Match - ', upper(maps{i}), ' Map']); colorbar;
    axis square; set(gca, 'XTick', [], 'YTick', []);

    subplot(3,4,i+4); 
    imagesc(reshape(rates.nonmatch.(maps{i}), [3 3]));
    title(['Non-Match - ', upper(maps{i}), ' Map']); colorbar;
    axis square; set(gca, 'XTick', [], 'YTick', []);
end

% Bottom row: PSTHs
subplot(3,4,[9 10 11]);
plot(bin_centers, rates.match.psth, 'w', 'LineWidth', 2); hold on;
plot(bin_centers, rates.nonmatch.psth, 'r', 'LineWidth', 2);
xlabel('Time from Cue (s)');
ylabel('Firing Rate (Hz)');
title('Cue-Aligned PSTH: Match vs Non-Match');
legend('Match', 'Non-Match');
xlim([-1 4]);
grid on;

sgtitle(['Spatial Maps + PSTHs: ', filename], 'Interpreter', 'none');


end
