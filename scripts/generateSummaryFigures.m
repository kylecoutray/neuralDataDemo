function generateSummaryFigures()
% Requires: epoch_spike_analysis_enriched.mat in current folder
% Uses: resultsTable
% Outputs: summary figures into /summary_figures

% === Load Data ===
load('epoch_spike_analysis_enriched.mat', 'resultsTable');

% === Create Output Folder ===
outputDir = 'summary_figures';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% === Extract Spike Matrices ===
FixationSpikes = resultsTable.FixationSpikesPerClass;
CueSpikes      = resultsTable.CueSpikesPerClass;
DelaySpikes    = resultsTable.DelaySpikesPerClass;


% === Figure 1: % of Tuned Neurons ===
n = height(resultsTable);
nFix = sum(resultsTable.IsFixationTuned);
nCue = sum(resultsTable.IsCueTuned);
nDelay = sum(resultsTable.IsDelayTuned);

figure;
bar([nFix, nCue, nDelay]/n * 100);
xticklabels({'Fixation','Cue','Delay'});
ylabel('% Tuned Neurons');
title('Percentage of Neurons Tuned per Epoch');
ylim([0 100]);
grid on;
saveas(gcf, fullfile(outputDir, 'percent_tuned_neurons.png'));

% === Figure 2: Selectivity Index Distributions ===
figure;
hold on;
histogram(resultsTable.SI_Fixation, 'BinWidth', 0.05, 'FaceAlpha', 0.6, 'DisplayName', 'Fixation');
histogram(resultsTable.SI_Cue, 'BinWidth', 0.05, 'FaceAlpha', 0.6, 'DisplayName', 'Cue');
histogram(resultsTable.SI_Delay, 'BinWidth', 0.05, 'FaceAlpha', 0.6, 'DisplayName', 'Delay');
xlabel('Selectivity Index (SI)');
ylabel('Neuron Count');
title('Distribution of Selectivity Indices');
legend;
grid on;
saveas(gcf, fullfile(outputDir, 'si_distributions.png'));

% === Figure 3: Population Heatmaps ===
epochs = {'Fixation', 'Cue', 'Delay'};
spikeMats = {FixationSpikes, CueSpikes, DelaySpikes};

for i = 1:3
    figure;
    imagesc(spikeMats{i});
    colormap('hot');
    colorbar;
    xlabel('Cue Class (1–9)');
    ylabel('Neuron #');
    title(['Population Tuning - ', epochs{i}]);
    saveas(gcf, fullfile(outputDir, ['heatmap_', lower(epochs{i}), '.png']));
end

disp('✅ All summary figures generated and saved.');

end
