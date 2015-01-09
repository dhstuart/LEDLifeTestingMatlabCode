% LED_life_testing_photometric_data_reduction

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

%need to run the following first:
% *grabElectricalData
% *grabPhotometricData2mSpheres

current = 'C:\Users\dhstuart\Dropbox\CLTC\LED life testing\photometric data';
directory = 'C:\Users\dhstuart\Box Sync';
hours = [0 1000 2000];
folderList = {
    'LT Photometric - 0000 hr Data'
    'LT Photometric - 1000 hr Data'
    'LT Photometric - 2000 hr Data'};

for i = 1:length(hours)
    
    cd([directory '\' folderList{i}]);
    files = dir('*.csv');
    cd(current)
    fileList = {files.name}';
    for j = 1:length(fileList)
        tempName = fileList{j};
        model = str2num(tempName(4:5));
        sample = str2num(tempName(7:8));
        
        
        %add photometric data (one file per sample and test period)
        temp = grabPhotometricData([directory '\' folderList{i} '\' fileList{j}]);
        tempFieldNames = fieldnames(temp);
        for dum = 1:length(tempFieldNames)
            data(model,sample).(tempFieldNames{dum})(:,i) = temp.(tempFieldNames{dum});
        end
        
        
        
    end
end

load('testMatrix.mat');
load('electricalData.mat');
load('photometricData2mSpheres.mat');
%%

for model = 1:20
    for sample = 1:30
        %                 if i == 2 %only need to add these fields once, and this skips the first because there is no baseline data
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
        % tempW = find(tm.product==model);
        data(model,sample).nominalWattage = tm.wattages(model);
        
        %add electrical data (from single file, once)
        emIndex = (model-1)*30+sample;
        data(model,sample).voltage = em.voltage(emIndex,:);
        data(model,sample).current = em.current(emIndex,:);
        data(model,sample).power = em.power(emIndex,:);
        data(model,sample).powerFactor = em.powerFactor(emIndex,:);
        data(model,sample).VTHD = em.VTHD(emIndex,:);
        data(model,sample).ITHD = em.ITHD(emIndex,:);
        
        %add original photometric data from 2m spheres
        tempFieldNames = fieldnames(photometricData2mSpheres);
        for i = 1:length(tempFieldNames)
            for j = 1:2 %loop over hours
                temp = photometricData2mSpheres(j).(tempFieldNames{i})(emIndex);
                if ~isnan(temp)
                    data(model,sample).(tempFieldNames{i})(:,j) = temp;
                end
            end
        end
    end
end

save('LEDLifeTestingData.mat','data')