function metrics = flicker_process_data_simplified(path, hours, printPlot,savePlot)

% savePlot = 1;
norm_freq = 10000;
cut_off1 = 200;
% norm_freq = 125000;
% cut_off1 = 125000;
% reductionFactor = 0.05;
reductionFactor = 0;

%% --------------- find file names and paths ----------------
% data_path = 'C:\Users\dhstuart\Documents\Energy Star Flicker Data\JST LuxPAR Flicker';
% data_path = 'C:\Users\dhstuart\Documents\Energy Star Flicker Data\cree2x2\';%\Cree2x2_010V_050_light.csv';
% data_path = 'C:\Users\dhstuart\Documents\LT Flicker - 1000 hr Data\test\';
% data_path = uigetdir(' ','Select top directory of files to procecss');

% [subs,fls] = subdir(data_path);
% files = dir([data_path '\*light.csv']);
% fileListAll = {files.name}';

% for i = 1:length(fileListAll)
%% -------------------- open and process files ------------------------
%     fid1 = fopen([data_path fileListAll{i}]);
% tic
% fid1 = fopen(path);
% % fid1 = fopen(pathOpen);
% temp = textscan(fid1,'%s','delimiter','\n');
% fclose(fid1);
% temp2 = regexpi(temp{1,1},',','split');
% temp3=vertcat(temp2{3:end});
% header_titles = temp2{1};
% header_data = temp2{2};
% fid1 = fopen(path);
% tempData = textscan(fid1,'%n','headerlines',2);
% data = tempData{1,1};
% fclose(fid1);
% toc

% tic;
temp = importdata(path,',');
temp2 = regexpi(temp.textdata,',','split');
header_titles = temp2{1};
header_data = temp2{2};
data = temp.data;
% toc;

% data = cellfun(@str2num,temp3);

%% ------- collect data from header -------------
dt = str2num(header_data{strcmp(header_titles,'dt')});
t = 0:dt:dt*(length(data)-1);
model = header_data{strcmp(header_titles,'model')};
dim_level = str2num(header_data{strcmp(header_titles,'dim level')});
dimmer_type = header_data{strcmp(header_titles,'dimmer type')};
% disp(['MODEL: ' model '     DIMMER TYPE: ' dimmer_type '     DIM LEVEL: ' num2str(dim_level)])

if mean(data)<0
    data = -data;
end
%% -----------unfiltered fund freq -------------
[~,metrics.fundFreqUnfilt] = fft_cutoff_analysis(data, dt, norm_freq);

%% -----------filter----------------
[filtered_data, metrics.fundFreqFilt, metrics.SNR] = fft_cutoff_analysis(data, dt, cut_off1);

%% ---------window filtered data -------------
window = t>reductionFactor & t<1-reductionFactor;
dataFilteredWindowed = filtered_data(window);
tWindowed = t(window);

%% -----------find norm-----------
[filtered_data_temp] = fft_cutoff_analysis(data, dt, norm_freq);
norm_level = max(filtered_data_temp(window));

%% ---------- Calculate Percent Flicker ---------
[averageLevel metrics.flickerIndex metrics.percentFlicker] = flicker_metrics(tWindowed, dataFilteredWindowed);
metrics.averageLevel = averageLevel/norm_level;

%% -----------plot----------------
%     name = ['MODEL: ' model '     DIMMER TYPE: ' dimmer_type '     DIM LEVEL: ' num2str(dim_level)];
name = ['MODEL: ' model ];
if printPlot == 1
    
%     flicker_plot(tWindowed, dataFilteredWindowed/norm_level, name, metrics)
    flicker_plot(tWindowed, dataFilteredWindowed, name, metrics)

end

%% -----------save figure --------------
if savePlot == 1
    cd('C:\Users\dhstuart\Box Sync\flicker plots')
    set(gcf,'Color',[1 1 1]);
    export_fig(gcf, [path(end-24:end-17) '_' num2str(hours) '.png']);
    close(gcf)
end


% end
%% -----------save variables to workspace
% export2base
end


function [filtered_data, fund_freq, SNR] = fft_cutoff_analysis(data, dt, cut_off)
fs = 1/dt;
n = length(data);
y = fft(data,n);           % DFT
f = (0:n-1)*(fs/n);     % Frequency range

f_index = find(f>cut_off);
if isempty(f_index)
    f_index = cut_off;
else
    f_index = f_index(1);
end

y2 = [y(1:f_index); zeros(length(y)-f_index,1)];

filtered_data = ifft(y2,n,'symmetric');
temp = flipud(y2(2:(end/2)+1));
y3 = [y2(1:end/2); conj(temp)];
filtered_data2 = ifft(y3,n);

filtered_data(filtered_data<0)=0;       %make all negative values zero

power2 = y2.*conj(y2)/n;   % Power of the DF
t = 0:dt:n*dt-dt;
[power3, power3i]=sort(power2(1:end), 'descend');   %exclude DC (freq=0)
fund_freq = f(power3i(2));
fund_freq_level = power3(1);
dum=1;
while fund_freq > 125000/2*.95
    dum = dum+1;
    fund_freq = f(power3i(dum));
    fund_freq_level = power3(dum);
end
noise_level = 1e-5;
SNR = 10*log10(fund_freq_level/noise_level);

end

function [average_level, flicker_index, percent_flicker] = flicker_metrics(t, data)

total_area = trapz(t,data);
average_level = total_area/(t(end)-t(1));
points_above_curve = (data-average_level).*((data>average_level));
area_above_mean = trapz(t,points_above_curve);
flicker_index = area_above_mean/total_area;

maximum = max(data);

minimum = min(data);
percent_flicker = (maximum-minimum)/(maximum+minimum)*100;
end

function flicker_plot(t, data, name, metrics)
SNR_limit = 30;
figure
hold all
plot(t-t(1),data,'Color',[0 0 1]); %plot middle of data to avoid plotting edge effects

line([0 t(end)-t(1)],[metrics.averageLevel metrics.averageLevel],'LineStyle','--', 'Color', 'r')
xlabel('Time (s)')
ylabel('Normalized Potential (V/V)')
title(name)

filt_fund_freq = sprintf('%0.0f',metrics.fundFreqFilt);
unfilt_fund_freq = sprintf('%0.0f',metrics.fundFreqUnfilt);

hold on
axis square
fill([0 0 0.018 0.018],[1.05 1.35 1.35 1.05], 'w')% %use this for original flicker data

text(0.0003,1.20,{sprintf('percent flicker %0.2f',metrics.percentFlicker),...
    sprintf('flicker index %0.2f',metrics.flickerIndex),...
    ['filt. fund. freq. ' filt_fund_freq],...
    ['unfilt. fund. freq. ' unfilt_fund_freq]},...
    'FontSize', 12) % original flicker data

% axis([0, .2, 0, 1.35]);
xlim([0 0.2])
grid on
hold off
end


function export2base
w = evalin('caller','who');
n = length(w);
for i = 1:n
    assignin('base',w{i},evalin('caller',w{i}))
end
end