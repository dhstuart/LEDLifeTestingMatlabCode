 % grabElectricalData.m
clc
clear all
close all

directory = 'C:\Users\dhstuart\Dropbox\CLTC\LED life testing\photometric data';
filename = [directory '\LED Lifetesting Electrical Data - Olga 1M 20141218.xlsx'];
sheets = {
    '1000 Hours'
    '2000 Hours'
    '3000 Hours'
    };

em.product = zeros(620,length(sheets)+1);
em.sample = zeros(620,length(sheets)+1);
em.voltage = zeros(620,length(sheets)+1);
em.current = zeros(620,length(sheets)+1);
em.power = zeros(620,length(sheets)+1);
em.powerFactor = zeros(620,length(sheets)+1);
em.VTHD = zeros(620,length(sheets)+1);
em.ITHD = zeros(620,length(sheets)+1);
for i = 2:length(sheets)+1    %starts at 2 to correctly index for baseline
    [a,b,c] = xlsread(filename,sheets{i-1});
%     if i == length(sheets)+1
%         a = [a;20 31 0 0 0 0 0 0 0 0];  %lamp 20-31 is a photometric lamp and no data was taken, we need to add this to fill in the last row of zeros to make right size
%     end
    %re-arrange
    for j = 1:size(a,1)

            product = a(j,1);
            sample = a(j,2);

        index = (product-1)*31+sample;
        em.product(index,i) = a(j,1);
        em.sample(index,i) = a(j,2);
        em.voltage(index,i) = a(j,3);
        em.current(index,i) = a(j,4);
        em.power(index,i) = a(j,5);
        em.powerFactor(index,i) = a(j,6);
        em.VTHD(index,i) = a(j,7);
        em.ITHD(index,i) = a(j,8);
        % out.date = a();
        % out.time = a();
    end
    
end

save('electricalData.mat','em')