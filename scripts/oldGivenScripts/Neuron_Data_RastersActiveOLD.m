function Neuron_Data_Rasters(filename)

% Neuron_Data_Rasters('filename_neuron#')
% This program inputs the compressed neural data from the extraction script
% Neuron_Data and displays the rasters and histograms.  The figures are
% arranged by either their spatial location or by their feature.  Features
% are in the following location, starting at the 0 degree and working
% counter clockwise:
% circle-diamond-H-number-plus-square-triangle-upsidedown Y
% 5-16-06 TM

load(filename)
max_resp = 0;
for n = 1:length(MatData.class)
    max_resp = max([max_resp max([MatData.class(n).ntr.cuerate])]);
end
if length(MatData.class) == 8
    subindex = [9 3 2 1 7 13 14 15];
else
    subindex = [9 3 2 1 7 13 14 15 8];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% This section displays the data %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% Find the maximum psth response for all histogram axes %%%%%%%%%%%%
allTS = [];
bin_width = 0.100;  % 100 milliseconds bin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hf = figure;
for m = 1:length(MatData.class)
    allTS = [];
    try
        hold on
        for n = 1:length(MatData.class(m).ntr)
            subplot(6,3,subindex(m))            
            fixation = MatData.class(m).ntr(n).Cue_onT-1;
            cue = MatData.class(m).ntr(n).Cue_onT-fixation;
            sample = MatData.class(m).ntr(n).Sample_onT-fixation;
            %target = MatData.class(m).ntr(n).Target_onT-fixation;
            reward = MatData.class(m).ntr(n).Reward_onT-fixation;
            TS = MatData.class(m).ntr(n).TS-fixation;
            for o = 1:length(TS)
                line([TS(o),TS(o)],[n-.9,n-.1],'Color', 'y')
            end     
            line([cue cue],[n-1 n],'Color','b')
            line([cue+.5 cue+.5],[n-1 n],'Color','b')
            line([sample sample],[n-1 n],'Color','b')
            line([sample+.5 sample+.5],[n-1 n],'Color','b')
            %line([target target],[n-1 n],'Color','b')            
            line([reward reward],[n-1 n],'Color','b')
            allTS = [allTS TS];
        end
        axis([0 7 0 n+1])
        axis off
        hold off
        subplot(6,3,subindex(m)+3)
        hold on
        bin_edges=0:bin_width:max(allTS);
        psth=histc(allTS,bin_edges)/(bin_width*n);
        bins = bin_edges+0.5*bin_width;
        hb = bar(bins,psth);
        line([0 0],[0 max_resp], 'LineWidth', 1, 'Color', 'k')
        axis([0 7 0 max_resp])
        set(hb,'EdgeColor','w');
        set(hb,'FaceColor','w');
        axis off
        hold off    
    catch
        lasterr
    end
end
set(hf,'Color',[.5 .5 .5])