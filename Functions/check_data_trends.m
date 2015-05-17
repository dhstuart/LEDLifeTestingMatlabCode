% p = path;
% p1 = genpath([pwd '\Functions']);
% p2 = genpath([pwd '\Data']);
% addpath([p1 p2]);
%
% resetPath = onCleanup(@()path(p));      %this will reset the path the next time "close all" is used



function [outNames, outData] = check_data_trends(model, sample, hours)

% model = 5
% sample = 21
% hours = 4000

load LEDLifeTestingData2.mat

%load new data from labview
printPlot = 0;
savePlot = 0;

fieldNamesOut = {
    'power'
    'powerFactor'
    'percentFlicker'
    };

tempData = data(model,sample);
allFieldNames = fieldnames(tempData(1,1));
allFieldNames = allFieldNames(14:end);  %only include fields that weren't already added via the test matrix
flickerFieldNames = {'fundFreqUnfilt';'fundFreqFilt';'SNR';'flickerIndex';'percentFlicker';'averageLevel'};

%% -------------------one meter sphere data-----------------------
% tempPath = [directory '\' folderListOneMeter{i} '\' fileName];
% if exist(tempPath)==2
%     temp = grabPhotometricData(tempPath);
%     tempFieldNames = fieldnames(temp);
%     for dum = 1:length(tempFieldNames)
%         data(model,sample).(tempFieldNames{dum})(:,i) = temp.(tempFieldNames{dum});
%     end
% elseif i>size(data(model,sample).luminousFlux,2)   %if the path doesn't exist, lamp is dead, fill in properties with NaN
%     for dum = 1:length(allFieldNames)
%         data(model,sample).(allFieldNames{dum})(:,i) = NaN;
%     end
% end
%% ---------------flicker data------------------
fileName = ['Flicker - ledLifeTesting - ' num2str(hours) ' - ' num2str(model) ' - ' num2str(sample) '.csv'];
tempPath = ['C:\Users\dhstuart\Dropbox\CLTC\PhotometricElectricTestingAutomation\Output\' fileName];

if exist(tempPath)==2
    flickerMetrics = flicker_process_data_simplified(tempPath, hours, printPlot,savePlot);
    tempFieldNames = fieldnames(flickerMetrics);
    for i = 1:length(tempFieldNames)
        tempData.(tempFieldNames{i}) = [tempData.(tempFieldNames{i}) flickerMetrics.(tempFieldNames{i})];
        %         figure('name',tempFieldNames{i})
        %         plot_new_data([tempData.hours hours], tempData.(tempFieldNames{i}))
        
    end
else % if data doesn't exist, fill in properties with NaN
    disp('Error. Cannot find flicker data file')
end


%% ----------------Electrical Data --------------------
fileName = ['Electrical - ledLifeTesting - ' num2str(hours) ' - ' num2str(model) ' - ' num2str(sample) '.tdms'];
tempPath = ['C:\Users\dhstuart\Dropbox\CLTC\PhotometricElectricTestingAutomation\Output\' fileName];

if exist(tempPath)==2
    electricalMetrics = grab_electrical_data_TDMS(tempPath);
    tempFieldNames = fieldnames(electricalMetrics);
    for i = 1:length(tempFieldNames)
        tempData.(tempFieldNames{i}) = [tempData.(tempFieldNames{i}) electricalMetrics.(tempFieldNames{i})];
        %         figure('name',tempFieldNames{i})
        %         plot_new_data([tempData.hours hours], tempData.(tempFieldNames{i}))
    end
    
    
end
outNames = [];
for i = 1:length(fieldNamesOut)
    outData(i,:) = tempData.(fieldNamesOut{i});
    outNames = [outNames sprintf('%s, ' , fieldNamesOut{i})];  %labview doesn't let string output
end
outNames = outNames(1:end-1);% strip final comma


% out = tempPath;

% export2base
% end



%% -------------------checks for fit
% power
% lumens
% current
% PF
% look for residual size on second order exponentials

% function plot_new_data(x,y)
% plot(x,y,'LineStyle','-', 'Marker','o','MarkerSize',10,'Color',[0 0 1])
% hold all
% plot(x(end),y(end),'ro','MarkerSize',10)
% end

% function export2base
% w = evalin('caller','who');
% n = length(w);
% for i = 1:n
%     assignin('base',w{i},evalin('caller',w{i}))
% end
% end


% fileName = ['LT ' sprintf('%02.0f',model) '-' sprintf('%02.0f',sample) '_PS_100_light.csv'];
% tempPath = [directory '\' folderListFlicker{i} '\' fileName];
% printPlot = 0;
% savePlot = 0;
% if exist(tempPath)==2
%     metrics = flicker_process_data_simplified(tempPath, hours(i), printPlot,savePlot);
%     tempFieldNames = fieldnames(metrics);
%     for dum = 1:length(tempFieldNames)
%         data(model,sample).(tempFieldNames{dum})(:,i) = metrics.(tempFieldNames{dum});
%     end
% else % if data doesn't exist, fill in properties with NaN
%     for dum = 1:length(flickerFieldNames)
%         data(model,sample).(flickerFieldNames{dum})(:,i) = NaN;
%     end
% end
% %             end
% elapsedTime = toc;
% itterationsLeft = (length(hours)*20*30) - ((i-1)*(20)*(30)+(model-1)*30+(sample-1));
% timeLeft = itterationsLeft*toc/60;
% disp(['time left is ' num2str(timeLeft) ' minutes'])

