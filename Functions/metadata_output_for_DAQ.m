clear all
close all
clc


% addpath Library\export_fig
% addpath Library\export_fig\.ignore
% cd('photometric data')
cd ..
load Data\LEDLifeTestingData2.mat
columns = [1:2 4:12];
names = fieldnames(data(1,1));
for i = 1:size(data,1)
    for j = 1:size(data,2)  
        temp = struct2cell(data(i,j));
        index = (i-1)*size(data,2)+j;
        a(index,:) = temp(columns)';
        
    end
end

tableOut = [names(columns)';a];
cell2csv('LedLifeTestingMetadata.csv',tableOut)