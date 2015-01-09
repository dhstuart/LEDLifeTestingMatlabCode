%LED life testing Data reduction
%Written by Daniel Stuart
% 2/20/2014

clear all
close all
clc

loadData = 1;

%% -------------------Grab data ---------------------------------
%look in folder for file names
cd('C:\Users\dhstuart\Documents\CLTC Log Files\New Folder')
% file_str = cellstr(ls);                                               %list of all files in directory
% file_cell = regexpi(file_str, '\w+(.csv)', 'match');                        %find cells that end in ".csv"
% file_cell(cellfun(@isempty,file_cell)) = [];

files = dir('*.csv');
fileList = {files.name}';

temp = regexp(fileList,'\w+Currents');
index.current = find(~cellfun(@isempty,temp));

temp = regexp(fileList,'\w+Photometric');
index.photometric = find(~cellfun(@isempty,temp));

temp = regexp(fileList,'\w+Temperature');
index.temperature = find(~cellfun(@isempty,temp));

temp = regexp(fileList,'\w+Voltages');
index.voltage = find(~cellfun(@isempty,temp));

temp = regexp(fileList,'\w+AirVelocity');
index.airVelocity = find(~cellfun(@isempty,temp));

temp = regexp(fileList,'\w+pwr_relay');
index.pwrRelay = find(~cellfun(@isempty,temp));

%% -------------------- Reduce Data -------------------
data = [];
time = [];
% measurements = fieldnames(index)
% measurement = 'temperature';
measurement = 'current';
if loadData ==1
    disp('Loading new data')
    for i = 1:length(index.(measurement)) %loop over
        disp([num2str(i) ' / ' num2str(length(index.(measurement)))])
        
        filename = fileList{index.(measurement)(i)};
        %% ----------------- read data and time ------------------------------
        data_temp = dlmread(filename,',',0,3);
        data = catpad(1,data,data_temp);  %varying number of sensors monitored.
        
        fid = fopen(filename, 'r');
        temp = textscan(fid, '%s %s %s %[^\n]','delimiter',',');%,'CollectOutput',1);
        fclose(fid);
        clear time_temp
        for j = 1:length(temp{1})
            time_temp(j,1) = datenum([temp{1}{j} ' ' temp{2}{j}]);
        end
        time = [time;time_temp];
        
    end
    save('tempData.mat', 'time', 'data')
else
    disp('Not loading new data')
    load('tempData.mat')
end
%%
clear onData onTime
onThreshold = 0.1;
onBool = abs(data)>onThreshold & abs(data)<10; %anything over 10 is an open circuit
% determine drop threshold to indicate that light turned off
%need to determine drop based on light for entire on periods. Data is too
%spikey to determine from instantaneous time


dt = diff(time);
for i = 1:size(data,2)      %Split matrix up into different cells because different on times
    onData{i} = data(find(onBool(:,i)),i);
    onTime{i} = time(onBool(:,i));
    offDataInd{i} = find(~onBool(:,i));
    offData{i} = data(offDataInd{i},i);
    offTimeInd{i} = find(~onBool(:,i));
    offTime{i} = time(offTimeInd{i});
    timeElapsed(i) = sum(onBool(:,i));
    
    %     metrics(i).onData = data(find(onBool(:,i)),i);
    %     metrics(i).onTime = time(onBool(:,i));
    %     metrics(i).offData = data(find(~onBool(:,i)),i);
    %     metrics(i).offTime = time(~onBool(:,i));
    %     metrics(i).timeElapsed = sum(onBool(:,i));
end
timeElapsed = timeElapsed/60;
[temp, k] = sort(timeElapsed);
% timeElapsed(64)
for i = 1:length(onData)
    diffData{i} = diff(onData{i});
    

    tempMinDiff = min(diffData{i});

    if isempty(tempMinDiff)
        maxDiff(i) = 0;
    else
        maxDiff(i) = tempMinDiff;
    end
end

for i =1:length(offTime)
    diffOffTime{i} = diff(offTime{i});
    EndOffTimeIndex{i} = find(diffOffTime{i}>3/60/24); %any time when it is not off for >3 min indicates the time index for each group
end

% loop over on times
clear noted
threshold=0.055;
threshold2=0.15;
numPoints = 5;
for i = 1:length(offTime)
    for j = 1:length(EndOffTimeIndex{i})-1
        %average values for the on times
        %convert from offtime indicies to all indices
        indices{i,j} = offTimeInd{i}(EndOffTimeIndex{i}(j)):offTimeInd{i}(EndOffTimeIndex{i}(j+1))-5;
        onTimeMean(i,j) = mean(data(indices{i,j},i));

    end
%     dum=0;
%     for j = 1:size(onTimeMean,2)-2
%         if (onTimeMean(i,j) > onTimeMean(i,j+1)+ threshold) && (onTimeMean(i,j) > onTimeMean(i,j+2)+ threshold) % next two points below threshold difference
%             if onTimeMean(i,j) - onTimeMean(i,j+1)< threshold2                                                  % next point is a drop less than threshold2
%                 dum=dum+1;
%                 noted{i,dum}= j;
%             end
%         end
%     end
end
for i = 1:length(offTime)
    temp2(i,:) = medfilt1(onTimeMean(i,:),numPoints);
    dum=0;
    for j = 1:length(temp2)-2
        if (temp2(i,j) > temp2(i,j+1)+ threshold) && (temp2(i,j) > temp2(i,j+2)+ threshold) % next two points below threshold difference
            if (temp2(i,j) - temp2(i,j+1)< threshold2) && (temp2(i,j) - temp2(i,j+2)< threshold2)    % next point is a drop less than threshold2
                if temp2(i,j)>0.2       %kludge to make sure it doesn't pick up values when being turned off
                    dum=dum+1;
                    noted{i,dum}= j;
                end
            end
        end
    end
end


%%
for i = 1:size(data,2)
    %     figure;plot(onTime{i},abs(onData{i}))
    %     title(i)
    %     datetick('x','mm/dd')
    %     mean_temp(i) = mean(onData(:,i));
    tempo = data(:,i)<300;
    mean_temp(i) = max(data(tempo,i));
end

%% ------------------determine burn out time------------------------
% % save
% % initialLevel =
% % i=33;
% % difference = diff(onData{i});
% % tempCurrentDropIndex = find(difference>diffThresh)
% % tempData= onData{i};
% 
% %----------moving average filter ------------
% window = 7;
% spread = floor(window/2);
% for i = spread:length(tempData)-spread-1
%     disp([num2str(i-spread+1) ' ' num2str(i+spread+1)])
%     smoothed(i-spread+1) = mean(tempData(i-spread+1:i+spread+1))
%     
% end

%see if found index is a
% figure;plot(onTime{i},onData{i})
% figure;plot(onTime{i}(1:end-1),difference)
%------------------
figure;plot(time,data(:,58),'b.');ylim([0,2])
hold on
plot(onTime{58},onData{58},'r.');ylim([0,2])

figure;plot(offTime{58},offData{58},'r.');ylim([0,2])
%%
index = 10;
figure;plot(time,data(:,index),'b');%ylim([0,2])
hold on
for i = 1:size(indices,2)
    plot(time(indices{index,i}), data(indices{index,i},index),'rx')
end
plot(offTime{index}(EndOffTimeIndex{index}),offData{index}(EndOffTimeIndex{index}),'gx')

figure;plot(onTimeMean(index,:),'.');title(index)
% figure;plot(diff(onTimeMean(index,:)),'.');title(index)
% numPoints = 3;
temp = medfilt1(onTimeMean(index,:),numPoints);
figure;plot(temp,'.');title(numPoints)

% figure;plot(time,data(:,33));ylim([0 2]);title('33');datetick('x','mm/dd')
% index = 36;
%%
for index= 45
h1 = figure;plot(time,data(:,index));ylim([0 2]);title(index);datetick('x','mm/dd')
end
dcm_obj = datacursormode(h1);
cd('C:\Users\dhstuart\Dropbox\CLTC\LED life testing')
set(dcm_obj,'UpdateFcn',@myupdatefcn)

% hold on
figure
index = 36
for i = size(noted(index,:))
    tempInd = indices{index,noted{index,i}}(end);
    plot(time(tempInd),data(tempInd,index),'rx')
end
%%
lastMeanValues = zeros(size(onTimeMean,1),1);
for i = 1:size(onTimeMean,1)
    tempIndices = find(onTimeMean(i,:)~=0);
    if i>=2 && i <=4
        lastMeanValues(i) = NaN;
    else
    lastMeanValues(i) = onTimeMean(i,tempIndices(end-1));
    end
end