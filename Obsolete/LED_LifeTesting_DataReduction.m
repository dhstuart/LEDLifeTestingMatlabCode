%LED life testing Data reduction
%Written by Daniel Stuart
% 2/20/2014

clear all
close all
clc


%% -------------------Grab data ---------------------------------
%look in folder for file names
cd('C:\Users\dhstuart\Documents\CLTC Log Files')
% file_str = cellstr(ls);                                               %list of all files in directory
% file_cell = regexpi(file_str, '\w+(.csv)', 'match');                        %find cells that end in ".csv"
% file_cell(cellfun(@isempty,file_cell)) = [];

files = dir('*.csv');
fileList = {files.name}';

temp = regexp(fileList,'\w+Currents');
currentIndex = find(~cellfun(@isempty,temp));

temp = regexp(fileList,'\w+Photometric');
photometricIndex = find(~cellfun(@isempty,temp));

temp = regexp(fileList,'\w+Temperature');
temperatureIndex = find(~cellfun(@isempty,temp));

temp = regexp(fileList,'\w+Voltages');
voltagesIndex = find(~cellfun(@isempty,temp));

temp = regexp(fileList,'\w+AirVelocity');
airVelocityIndex = find(~cellfun(@isempty,temp));

temp = regexp(fileList,'\w+pwr_relay');
pwrRelayIndex = find(~cellfun(@isempty,temp));

%% -------------------- Reduce Data -------------------
data = [];
time = [];
for i = 1:length(currentIndex)
    i
    %     fid1 = fopen(fileList{currentIndex(i)});
    % temp = textscan(fid1,'%s','delimiter','\n');
    % temp2 = regexpi(temp{1,1},',','split');
    % %     a = csvread(fileList{currentIndex(i)});
    % fclose(fid)
    
    
    filename = fileList{currentIndex(i)};
    
    data_temp = dlmread(filename,',',0,3);
    data = [data;data_temp];
    % fid = fopen(filename, 'r');
    % tline = fgetl(fid);
    % %  Split header
    % A(1,:) = regexp(tline, '\,', 'split');
    % % B(1,:) = str2double(A);
    % %  Parse and read rest of file
    % ctr = 1;
    % while(~feof(fid))
    %     if ischar(tline)
    %         ctr = ctr + 1;
    %         tline = fgetl(fid);
    %         A(ctr,:) = regexp(tline, '\,', 'split');
    % %         B(ctr,:) = str2double(A(ctr,:));
    %     else
    %         break;
    %     end
    % end
    % fclose(fid);
    %
    %
    % fin = cellfun(@(x)regexp(x, '\.', 'split'), A, 'UniformOutput', false);
    %
    %
    % temp = textscan(fid1,'%*%s','delimiter','\n');
    
    
    
    
    %% ------------------
    
    fid = fopen(filename, 'r');
    % temp = textscan(fid, '%f','delimiter',',','CollectOutput',1)
    temp = textscan(fid, '%s %s %s %[^\n]','delimiter',',');%,'CollectOutput',1);
    fclose(fid);

    for j = 1:length(temp{1})
        time_temp(j,1) = datenum([temp{1}{j} ' ' temp{2}{j}]);
    end
    time = [time;time_temp];
    %%
    
    
    
    
    % A = csvread_adv(filename);
    %
    % data_temp = A(:,4:end);
    % % data_temp2 = cellfun(@str2double,data_temp);
    % data_temp2 = str2double(cellstr(data_temp));
    
    % A = csvread(filename);
    % data_temp = A;
    %
    % data = [data;data_temp2];
    % i
end