clc
clear all
close all

directory = 'C:\Users\dhstuart\Dropbox\CLTC\LED life testing\photometric data';
filename = [directory '\Lifetesting Summary 20140908.xlsx'];
sheets = {
    'Baseline'
    '1000'
    '2000'
    '3000'};

for i = 1:length(sheets)
    [a,b,c] = xlsread(filename,sheets{i});
    a = a(2:end,:);  %remove headers
    
    %remove sample 31 data - (THIS IS WRONG)
    a2=ones(size(a,1),1);
%     a2(31:31:620)=0;
    a=a(find(a2),:);
    
    out(i).power = a(:,5);
    out(i).powerFactor = a(:,6);
    out(i).VTHD = a(:,7);
    out(i).ITHD = a(:,8);
    out(i).luminousFlux = a(:,9);
    out(i).CIEx = a(:,10);
    out(i).CIEy = a(:,11);
    % CIEz = temp(6);
    out(i).uprime = a(:,13);
    out(i).vprime = a(:,14);
    out(i).Duv = a(:,15);
    out(i).CCT = a(:,16);
    out(i).dominantWavelength = a(:,17);
    out(i).peakWavelength = a(:,18);
    out(i).centerWavelength = a(:,19);
    out(i).fullWidthHalfMaxWavelength = a(:,20);
    out(i).centroidWavelength = a(:,21);
    out(i).purity = a(:,22);
    out(i).R1 = a(:,23);
    out(i).R2 = a(:,24);
    out(i).R3 = a(:,25);
    out(i).R4  = a(:,26);
    out(i).R5 = a(:,27);
    out(i).R6 = a(:,28);
    out(i).R7 = a(:,29);
    out(i).R8 = a(:,30);
    out(i).R9 = a(:,31);
    out(i).R10  = a(:,32);
    out(i).R11 = a(:,33);
    out(i).R12 = a(:,34);
    out(i).R13 = a(:,35);
    out(i).R14 = a(:,36);
    out(i).SPD = a(:,40:end);
    out(i).Ra = a(:,37);
    % CriDC = temp(:,36);
    
    %     %re-arrange
    %     for j = 1:size(a,1)
    %         product = a(j,1);
    %         sample = a(j,2);
    %         index = (product-1)*30+sample;
    %         em.product(index,i) = a(j,1);
    %         em.sample(index,i) = a(j,2);
    %         em.voltage(index,i) = a(j,3);
    %         em.current(index,i) = a(j,4);
    %         em.power(index,i) = a(j,5);
    %         em.powerFactor(index,i) = a(j,6);
    %         em.VTHD(index,i) = a(j,7);
    %         em.ITHD(index,i) = a(j,8);
    %         % out.date = a();
    %         % out.time = a();
    %     end
    
end
photometricData2mSpheres = out;
save('photometricData2mSpheres.mat','photometricData2mSpheres')