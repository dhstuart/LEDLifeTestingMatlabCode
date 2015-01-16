% LED_life_testing_photometric_data_reduction
% version 3 adds flicker

%data.(model).(sample).(properties)
% photometric data
% per product
% lumens over time
% CCT over time
% Duv over time
% CRI over time
%
% electrical
% model = 20;
% sample = 31;
%
% load via table
% convert to struct
% b=table2struct(LifetestingSummary20140908);
%
% properties = {
%     'voltage'};
% for i = 1:length(hours) %loop over 1000 hour interim inspection periods
%     for j = 1:model %loop over models
%         for k = 1:sample %loop over samples
%             for l = 1:length(properties)
%                 data3(j,k).(properties{l})(i) = 5;
%             end
%         end
%     end
% end
close all

clc
clear all

p = path;
p1 = genpath([pwd '\Functions']);
p2 = genpath([pwd '\Data']);
addpath([p1 p2]);

resetPath = onCleanup(@()path(p));      %this will reset the path the next time "close all" is used


%need to run the following first:
% *grabElectricalData
% *grabPhotometricData2mSpheres

% current = 'C:\Users\dhstuart\Dropbox\CLTC\LED life testing\photometric data';
directory = 'C:\Users\dhstuart\Box Sync';
hours = [0 1000 2000 3000];
folderListOneMeter = {
    'LT Photometric - 0000 hr Data'
    'LT Photometric - 1000 hr Data'
    'LT Photometric - 2000 hr Data'
    'LT Photometric - 3000 hr Data'};
folderListFlicker = {
    'LT Flicker - 0000 hr Data'
    'LT Flicker - 1000 hr Data'
    'LT Flicker - 2000 hr Data'
    'LT Flicker - 3000 hr Data'};

%%
% cd(current)
load('testMatrix.mat'); %in "photometric data" folder
load('electricalData.mat'); %in "photometric data" folder
load('photometricData2mSpheres.mat'); %in "photometric data" folder

for model = 1:20
    for sample = 1:31
        %                 if i == 2 %only  need to add these fields once, and this skips the first because there is no baseline data
        data(model,sample).model = model;
        data(model,sample).sample = sample;
        %         end
        data(model,sample).hours = hours;
        
        %add test matrix data (from single file, once)
        tmIndex = find(tm.product==model & tm.sample==sample);
        data(model,sample).orientation = tm.orientation{tmIndex};
        data(model,sample).housing = tm.housing(tmIndex);
        data(model,sample).dimming = tm.dimming(tmIndex);
        data(model,sample).rack = tm.rack(tmIndex);
        data(model,sample).branch = tm.branch(tmIndex);
        data(model,sample).socket = tm.socket(tmIndex);
        data(model,sample).manufacturer = tm.manufacturer(model);
        data(model,sample).productName = tm.productName(model);
        data(model,sample).lampShapeSize = tm.lampShapeSize(model);
        % tempW = find(tm.product==model);
        data(model,sample).rated_power = tm.rated_power(model);
        data(model,sample).rated_luminousFlux = tm.rated_luminousFlux(model);
        data(model,sample).rated_CCT = tm.rated_CCT(model);
        data(model,sample).rated_Ra = tm.rated_Ra(model);
        
        %add electrical data (from single file, once)
        emIndex = (model-1)*31+sample;
        data(model,sample).voltage = em.voltage(emIndex,:);
        data(model,sample).current = em.current(emIndex,:);
        data(model,sample).power = em.power(emIndex,:);
        data(model,sample).powerFactor = em.powerFactor(emIndex,:);
        data(model,sample).VTHD = em.VTHD(emIndex,:);
        data(model,sample).ITHD = em.ITHD(emIndex,:);
        
        %add original photometric data from 2m spheres
        tempFieldNames = fieldnames(photometricData2mSpheres);
        for i = 1:length(tempFieldNames)
            for j = 1:4 %loop over hours
                temp = photometricData2mSpheres(j).(tempFieldNames{i})(emIndex,:);
                if ~isnan(temp)
                    data(model,sample).(tempFieldNames{i})(:,j) = temp;
                end
            end
        end
    end
end

%% ------------------- Add one meter sphere and flicker data ---------------------------
allFieldNames = fieldnames(data(1,1));
allFieldNames = allFieldNames(14:end);  %only include fields that weren't already added via the test matrix
flickerFieldNames = {'fundFreqUnfilt';'fundFreqFilt';'SNR';'flickerIndex';'percentFlicker';'averageLevel'};
for i = 1:length(hours)
    for model = 1:20
        for sample = 1:31
            tic
            disp(['hours ' num2str(hours(i)) ' - model ' num2str(model) ' - sample ' num2str(sample)])
            %             cd([directory '\' folderList{i}]);
            %             files = dir('*.csv');
            %             cd(current)
            fileName = ['LT ' sprintf('%02.0f',model) '-' sprintf('%02.0f',sample) '.csv'];
            %             fileList = {files.name}';
            %             for j = 1:length(fileList)
            %                 tempName = fileList{j};
            %                 model = str2num(tempName(4:5));
            %                 sample = str2num(tempName(7:8));
            
            
            %add photometric data (one file per sample and test period)
            %                 temp = grabPhotometricData([directory '\' folderList{i} '\' fileList{j}]);
            %% -------------------one meter sphere data-----------------------
            tempPath = [directory '\' folderListOneMeter{i} '\' fileName];
            if exist(tempPath)==2
                temp = grabPhotometricData(tempPath);
                tempFieldNames = fieldnames(temp);
                for dum = 1:length(tempFieldNames)
                    data(model,sample).(tempFieldNames{dum})(:,i) = temp.(tempFieldNames{dum});
                end
            elseif i>size(data(model,sample).luminousFlux,2)   %if the path doesn't exist, lamp is dead, fill in properties with NaN
                for dum = 1:length(allFieldNames)
                    data(model,sample).(allFieldNames{dum})(:,i) = NaN;
                end
            end
            %% ---------------flicker data------------------
            fileName = ['LT ' sprintf('%02.0f',model) '-' sprintf('%02.0f',sample) '_PS_100_light.csv'];
            tempPath = [directory '\' folderListFlicker{i} '\' fileName];
            printPlot = 0;
            savePlot = 0;
            if exist(tempPath)==2
                metrics = flicker_process_data_simplified(tempPath, hours(i), printPlot,savePlot);
                tempFieldNames = fieldnames(metrics);
                for dum = 1:length(tempFieldNames)
                    data(model,sample).(tempFieldNames{dum})(:,i) = metrics.(tempFieldNames{dum});
                end
            else % if data doesn't exist, fill in properties with NaN
                for dum = 1:length(flickerFieldNames)
                    data(model,sample).(flickerFieldNames{dum})(:,i) = NaN;
                end
            end
            %             end
            elapsedTime = toc;
            itterationsLeft = (length(hours)*20*30) - ((i-1)*(20)*(30)+(model-1)*30+(sample-1));
            timeLeft = itterationsLeft*toc/60;
            disp(['time left is ' num2str(timeLeft) ' minutes'])
        end
        
    end
end

%%
save('Data\LEDLifeTestingData2.mat','data')
path(p);