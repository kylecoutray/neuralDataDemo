%this code is ligthly adapted to be as close as possible to the provided
%one

function Neuron_Data_PSTHCue_All()

% CONFIGURATION
excel_file = '/scripts/NeuronList3_APpostonly.xlsx';     % list of neurons
data_folder = '/Users/kyle./Downloads/matlabDemos/allNeuralData'; % where .mat files live
bin_width = 0.10;                              % seconds
bin_edges = -1:bin_width:4;
bins = bin_edges + 0.5 * bin_width;
n_classes = 9;

% Load neuron filenames
[~, txt] = xlsread(excel_file);
neuron_names = txt(:,9);
fprintf('Loaded %d neurons from list.\n', length(neuron_names));

% Initialize PSTH data
psth_match_all = [];
psth_nonmatch_all = [];

% Process each neuron and each cue class
for i = 1:length(neuron_names)
    neuron_id = neuron_names{i}(1:13); % trim any extra chars
    file_path = fullfile(data_folder, [neuron_id, '.mat']);

    if ~isfile(file_path)
        fprintf('Missing file: %s\n', file_path);
        continue
    end

    try
        for class_num = 1:n_classes
            psth_match = Get_Psth(file_path, class_num, true, bin_edges, bin_width);
            psth_nonmatch = Get_Psth(file_path, class_num, false, bin_edges, bin_width);

            if ~isempty(psth_match)
                psth_match_all(end+1, :) = psth_match;
            end
            if ~isempty(psth_nonmatch)
                psth_nonmatch_all(end+1, :) = psth_nonmatch;
            end
        end
    catch ME
        fprintf('Error processing %s: %s\n', neuron_id, ME.message);
    end
end

% Compute population means
psth_match_mean = mean(psth_match_all, 1);
psth_nonmatch_mean = mean(psth_nonmatch_all, 1);

% Plot
figure;
hold on;
plot(bins, psth_match_mean, 'r', 'LineWidth', 2);
plot(bins, psth_nonmatch_mean, 'b', 'LineWidth', 2);
line([0 0], [0 max([psth_match_mean psth_nonmatch_mean])], 'color', 'k', 'LineStyle', '--');
line([0.5 0.5], [0 max([psth_match_mean psth_nonmatch_mean])], 'color', 'k', 'LineStyle', '--');
xlabel('Time (s)');
ylabel('Firing Rate (spikes/s)');
legend('Match', 'Non-Match');
title('Cue-aligned PSTH: Match vs Non-Match');
grid on;
set(gcf, 'Color', 'k');
hold off;

fprintf('PSTH plotting complete. %d match, %d non-match traces averaged.\n', ...
    size(psth_match_all,1), size(psth_nonmatch_all,1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psth = Get_Psth(file_path, class_num, isMatch, bin_edges, bin_width)
% Load data and compute PSTH for a single class and match/nonmatch condition

load(file_path, 'MatData');
allTS = [];
n_trials = 0;

if class_num > length(MatData.class)
    psth = [];
    return;
end

trials = MatData.class(class_num).ntr;

for t = 1:length(trials)
    trial = trials(t);

    try
        % Check condition
        if (~isfield(trial, 'IsMatch') || trial.IsMatch ~= isMatch)
            continue
        end

        % Cue-sample interval must be valid
        if abs(trial.Sample_onT - trial.Reward_onT) <= 1.5 && ...
           abs(trial.Sample_onT - trial.Target_onT) <= 1.5
            continue
        end

        TS = trial.TS - trial.Cue_onT;  % align to cue
        allTS = [allTS TS];
        n_trials = n_trials + 1;

    catch
        continue
    end
end

if n_trials > 0
    psth = histc(allTS, bin_edges) / (bin_width * n_trials);
else
    psth = [];
end
end
