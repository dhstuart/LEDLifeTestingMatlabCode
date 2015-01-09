% create_tables_for_tim.m

clear all
close all
clc

cd('photometric data')
load LEDLifeTestingData2.mat

allFieldNames = fieldnames(data(1,1));
singleHrNames = allFieldNames([1 2 4:13]);
shortFieldNames = allFieldNames([3 14:46 48:54]);
spd = 360:1000;
header = [singleHrNames' shortFieldNames' num2cell(spd)];
out2 = [];
for hours = 1:4
    dum=0;
    for modelIndex = 1%:20
        for sampleIndex = 1%:31
            dum=dum+1;
            out = [];
            for field = 1:length(singleHrNames)
                out(field) = num2str(data(modelIndex,sampleIndex).(singleHrNames{field}));
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
%     xlswrite('LEDLifeTestingData.xlsx',out2,hours)
end