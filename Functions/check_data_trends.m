% p = path;
% p1 = genpath([pwd '\Functions']);
% p2 = genpath([pwd '\Data']);
% addpath([p1 p2]);
% 
% resetPath = onCleanup(@()path(p));      %this will reset the path the next time "close all" is used



function check_data_trends(model, sample, hours)

load LEDLifeTestingData2.mat

%load new data from labview
printPlot = 0;
savePlot = 0;


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
tempPath = ['C:\Users\dhstuart\Dropbox\CLTC\PhotometricElectricTestingAutomation\Output\' fileName]

if exist(tempPath)==2
    metrics = flicker_process_data_simplified(tempPath, hours, printPlot,savePlot);
    tempFieldNames = fieldnames(metrics);
    for dum = 1:length(tempFieldNames)
        tempData.(tempFieldNames{dum})(:,i) = metrics.(tempFieldNames{dum});
    end
else % if data doesn't exist, fill in properties with NaN
    disp('Error. Cannot find flicker data file')
end
end

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

