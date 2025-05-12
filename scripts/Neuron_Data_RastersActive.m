function Neuron_Data_RastersActive(filename)
% Neuron_Data_RastersActive('neuralData/ADR001_1_3000.mat')
% Inputs compressed neural data and displays rasters and PSTHs per cue class.
% Cue classes are arranged spatially.
% Features go: circle-diamond-H-number-plus-square-triangle-upsidedown Y
% 5-16-06 TM

load(filename, 'MatData')

% Set up cue class layout
if length(MatData.class) == 8
    subindex = [9 3 2 1 7 13 14 15];
    class_labels = {'1','2','3','4','5','6','7','8'};
else
    subindex = [9 3 2 1 7 13 14 15 8];
    class_labels = {'1','2','3','4','5','6','7','8','9'};
end

% Compute max firing rate for PSTH normalization
max_resp = 0;
for n = 1:length(MatData.class)
    if isfield(MatData.class(n).ntr, 'cuerate')
        max_resp = max([max_resp max([MatData.class(n).ntr.cuerate])]);
    end
end

% Raster + PSTH config
bin_width = 0.100;  % seconds
hf = figure('Color', [0.1 0.1 0.1]);  % white background
subtitle(['Neuron Rasters + PSTHs: ', filename])  % Add title

for m = 1:length(MatData.class)
    allTS = [];
    trials = MatData.class(m).ntr;
    n_trials = length(trials);

    %% Raster Plot (Top)
    subplot(6, 3, subindex(m));
    hold on
    for n = 1:n_trials
        fixation = trials(n).Cue_onT - 1;
        cue     = trials(n).Cue_onT - fixation;
        sample  = trials(n).Sample_onT - fixation;
        reward  = trials(n).Reward_onT - fixation;
        TS      = trials(n).TS - fixation;

        for o = 1:length(TS)
            line([TS(o), TS(o)], [n-0.4, n+0.4], 'Color', 'y');
        end
        for e = [cue, cue+0.5, sample, sample+0.5, reward]
            line([e, e], [n-0.5, n+0.5], 'Color', 'b');
        end

        allTS = [allTS TS];
    end
    title(['Cue Class ', class_labels{m}]);
    ylabel('Trial');
    xlim([0 7]);
    ylim([0 n_trials + 1]);
    set(gca, 'YDir','reverse');  % flip so trial 1 is on top
    box on

    %% PSTH Plot (Bottom)
    subplot(6, 3, subindex(m) + 3)
    hold on
    if ~isempty(allTS)
        bin_edges = 0:bin_width:max(allTS);
        [counts, ~] = histcounts(allTS, bin_edges);
        psth = counts / (bin_width * n_trials);
        bins = bin_edges(1:end-1) + 0.5 * bin_width;

        bar(bins, psth, 1, 'FaceColor', 'w', 'EdgeColor', 'k');
        line([0 0], [0 max_resp], 'LineWidth', 1, 'Color', 'k', 'LineStyle','--');
        ylim([0 max_resp])
        xlim([0 7])
        xlabel('Time (s)');
        ylabel('Firing Rate');
    else
        text(1, 1, 'No spikes', 'Color', 'r')
        axis([0 7 0 1])
    end
    box on
end
end
