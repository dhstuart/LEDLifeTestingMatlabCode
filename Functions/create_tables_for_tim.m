% create_tables_for_tim.m

clear all
close all
clc

% cd('photometric data')
cd('..\data')
load LEDLifeTestingData3.mat

allFieldNames = fieldnames(data(1,1));
% singleHrNames = allFieldNames([1 2 4:13]);    %old version of field names
singleHrNames = allFieldNames([1 2 4:9 13:16]);
% shortFieldNames = allFieldNames([3 14:46 48:54]);     %old version of field names
shortFieldNames = allFieldNames([3 17:49 51:57]);
spd = 360:1000;
header = [singleHrNames' shortFieldNames' num2cell(spd)];
out2 = [];
for hours = 1:6
    dum=0;
    for modelIndex = 1:10%:20
        for sampleIndex = 1:31
            dum=dum+1;
            out = [];
            for field = 1:length(singleHrNames)
%                 out(field) = num2str(data(modelIndex,sampleIndex).(singleHrNames{field}))  %not sure why this needed to be a string?
                out(field) = data(modelIndex,sampleIndex).(singleHrNames{field});
            end
            
            for field = 1+length(singleHrNames):length(shortFieldNames)+length(singleHrNames)
                if length(data(modelIndex,sampleIndex).(shortFieldNames{field-length(singleHrNames)}))<hours
                    out(field) = NaN;
                else
                    out(field) = data(modelIndex,sampleIndex).(shortFieldNames{field-length(singleHrNames)})(hours);
                end
            end
            out =  [out data(modelIndex,sampleIndex).SPD(:,hours)'];
            if dum == 1
                out2 = [header; num2cell(out)];
            else
                out2 = [out2;num2cell(out)];
            end
            
        end
    end
    xlswrite('LEDLifeTestingData2.xlsx',out2,hours)
end