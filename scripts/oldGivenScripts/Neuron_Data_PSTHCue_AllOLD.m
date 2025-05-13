function Neuron_Data_PSTHCue_All()

[Neurons_num Neurons_txt] = xlsread(['NeuronList3_APpostonly.xlsx']);
warning off MATLAB:divideByZero
Neurons = [Neurons_txt(:,1) num2cell(Neurons_num(:,1))];

% Neurons_long={};
% Neurons={};
%  Neurons_long=[Neurons_long flist_AREA{1,2}.cue];
%  Neurons_long=[Neurons_long flist_AREA{1,2}.delay1];
%  Neurons_long=[Neurons_long flist_AREA{1,2}.sample];
%  Neurons_long=[Neurons_long flist_AREA{1,2}.delay2];
% 
% %sNeurons_long=[Neurons_long flist_AREA{1,2}.nonsel_ind];
% 
% for n=1:length(Neurons_long)
%     Neurons{n}=Neurons_long{n}(1:13);
% end
% Neurons=unique(Neurons);


sBest_Cue = Get_Maxes(Neurons);

n=1;
for nn = 1:length(Neurons)
    for j=1:9
    try
        filename = Neurons{nn}(1:13);
        psth1(n,:) = Get_PsthM(filename,j);
        psth2(n,:) = Get_PsthNM(filename,j);
        n=n+1;
    catch
        disp(['error processing neuron ',filename])
    end
    end
end

figure
colors = 'rgb';
bin_width = 0.10;  % 100 milliseconds bin
bin_edges=-1:bin_width:4;
bins = bin_edges+0.5*bin_width;

hold on

psth1 = mean(psth1);
psth2 = mean(psth2);
plot(bins,psth1,'r',bins,psth2,'m','LineWidth',3);
line([0 0], [0 20],'color','k')
line([0.5 0.5], [0 20],'color','k')
line([2 2], [0 20],'color','k')
line([2.5 2.5], [0 20],'color','k')
axis([-1 3.9 0 max([psth1 psth2])])
title('Cue-Sample in vs Cue-Sample out')
set(gca,'XTick',[-.5:.5:3.9],'XTickLabel',{'';'1';'';'2';'';'3';'';'4';''})

hold off
drawnow
xlabel('Time s')
ylabel('Firing Rate spikes/s')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function max_results = Get_Maxes(Neurons)
max_result(1:length(Neurons),1:3) = NaN;
for n = 1:length(Neurons)
    filename = Neurons{n}(1:13);
    temp = Neuron_Data_Max(filename);
    max_results(n,1:length(temp)) = temp(1);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psth_temp = Get_PsthM(filename,class_num)
load(filename)
bin_width = 0.10;  % 100 milliseconds bin
bin_edges=-1:bin_width:4;
bins = bin_edges+0.5*bin_width;
allTS = [];
m_counter = 0;
if ~isempty(MatData)    
    for m = 1:length(MatData.class(class_num).ntr)
        try
            if (abs(MatData.class(class_num).ntr(m).Sample_onT-MatData.class(class_num).ntr(m).Reward_onT) > 1.5) & (MatData.class(class_num).ntr(m).IsMatch == 1)
                TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                allTS = [allTS TS];
                m_counter = m_counter + 1;
            end
        catch
            if (abs(MatData.class(class_num).ntr(m).Sample_onT-MatData.class(class_num).ntr(m).Target_onT) > 1.5) & (MatData.class(class_num).ntr(m).IsMatch == 1)
                TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                allTS = [allTS TS];
                m_counter = m_counter + 1;
            end
        end
    end
    ntrs = m_counter;
else
    ttest_result = [];
end
psth_temp =histc(allTS,bin_edges)/(bin_width*ntrs);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psth_temp = Get_PsthNM(filename,class_num)
load(filename)
bin_width = 0.10;  % 100 milliseconds bin
bin_edges=-1:bin_width:4;
bins = bin_edges+0.5*bin_width;
allTS = [];
m_counter = 0;
if ~isempty(MatData)    
    for m = 1:length(MatData.class(class_num).ntr)
        try
            if (abs(MatData.class(class_num).ntr(m).Sample_onT-MatData.class(class_num).ntr(m).Reward_onT) > 1.5) & (MatData.class(class_num).ntr(m).IsMatch == 0)
                TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                allTS = [allTS TS];
                m_counter = m_counter + 1;
            end
        catch
            if (abs(MatData.class(class_num).ntr(m).Sample_onT-MatData.class(class_num).ntr(m).Target_onT) > 1.5) & (MatData.class(class_num).ntr(m).IsMatch == 0)
                TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                allTS = [allTS TS];
                m_counter = m_counter + 1;
            end
        end
    end
    ntrs = m_counter;
else
    ttest_result = [];
end
psth_temp =histc(allTS,bin_edges)/(bin_width*ntrs);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%