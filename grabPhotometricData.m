function out = grabPhotometricData(filename)
% filename = 'C:\Users\dhstuart\Box Sync\LT 01-01.csv';

fid = fopen(filename, 'r');
tline = fgetl(fid);
tline = fgetl(fid);
%  Split header
temp = regexp(tline, '\,', 'split');
fclose(fid);

numScans = length(temp)-2;

t1 = dlmread(filename,',',[3 numScans 19 numScans]);
t2 = dlmread(filename,',',[22 numScans 38 numScans]);
t3 = dlmread(filename,',', 44,numScans);

temp= [t1;t2;t3];


out.luminousFlux = temp(2);
out.CIEx = temp(4);
out.CIEy = temp(5);
% CIEz = temp(6);
out.uprime = temp(9);
out.vprime = temp(10);
out.Duv = temp(8);
out.CCT = temp(17);
out.dominantWavelength = temp(14);
out.peakWavelength = temp(11);
out.centerWavelength = temp(12);
out.fullWidthHalfMaxWavelength = temp(15);
out.centroidWavelength = temp(13);
out.purity = temp(16);
out.R1 = temp(21);
out.R2 = temp(22);
out.R3 = temp(23);
out.R4 = temp(24);
out.R5 = temp(25);
out.R6 = temp(26);
out.R7 = temp(27);
out.R8 = temp(28);
out.R9 = temp(29);
out.R10 = temp(30);
out.R11 = temp(31);
out.R12 = temp(32);
out.R13 = temp(33);
out.R14 = temp(34);
out.SPD = temp(35:end);
out.Ra = temp(20);
% CriDC = temp(:,36);