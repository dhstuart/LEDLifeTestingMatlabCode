% LED_life_testing_data_reduction.m

% clear all
close all
clc

cd('photometric data')
load LEDLifeTestingData.mat
%
properties = {
%         'luminousFlux'
%         'CCT'
                    'Duv'
%     'Ra'
    %spd
    %CIE
    %         'voltage'
    %         'current'
    %         'power'
    %power factor
%         'VTHD'
    %     'ITHD'
    };

ylabelText = {
%     'Lumens'
%             'Degrees Kelvin'
            'Duv'
%             'Ra'
    %
    %
    %         'Volts'
    %         'Amps'
    %         'Watts'
    %     '% Total Harmonic Distortion'
    %     '% Total Harmonic Distortion'
    };

markerType = [
    'x' %open air
    's' %enclosed
    'o'
    'd'
    '.'
    '+'
    'p'
    '>'];

lineStyle = {
    '-'	% Solid line (default) (u)
    '--'	% Dashed line (d)
    ':'	% Dotted line (h)
    '-.'	% Dash-dot line
    };
colors = [
    1 0 0  %base up
    0 .8 0 %base down
    0 0 1 %base horizontal
    ];

opConditionsNames = {
    'Manufacturer rated value'
    'Base-up, Open Air, 100%'
    'Base-Down, Open Air ,100%'
    'Base-Horizontal, Open Air, 100%'
    'Base-up, Enclosed,100%'
    'Base-up, Open Air ,50%'
    'Base-Down ,Open Air ,50%'
    'Base-Horizontal, Open Air, 50%'
    'Base-up, Enclosed, 50%'
    };

plotStyle = [ %(markerTypeList) (lineStyle)
    1 1 1% 1	5	Base-up	Open Air	30 on / 5 off	100%
    1 2 1 % 2	5	Base-Down	Open Air	30 on / 5 off	100%
    1 3 1 % 3	5	Base-Horizontal	Open Air	30 on / 5 off	100%
    2 1 1% 4	5	Base-up	Enclosed	30 on / 5 off	100%
    1 1 2% 5	3	Base-up	Open Air	30 on / 5 off	50%
    1 2 2% 6	2	Base-Down	Open Air	30 on / 5 off	50%
    1 3 2% 7	2	Base-Horizontal	Open Air	30 on / 5 off	50%
    2 1 2% 8	3	Base-up	Enclosed	30 on / 5 off	50%
    % 9	1	Base-up	Open Air	always on	100%%
    ];

lineWidth = 2;
markerSize = 8;

ylimTollerance.luminousFlux = [0 1100];
ylimTollerance.CCT = 200;
% ylimit.Duv = [2500 3200];
% ylimit.Ra = [2500 3200];

for modelIndex = 8%1:10
    for i = 1:length(properties)
        tempProperty = vertcat(data(modelIndex,:).(properties{i}))';
        hours = vertcat(data(modelIndex,:).hours)';
        orientation = vertcat(data(modelIndex,:).orientation);
        housing = vertcat(data(modelIndex,:).housing);
        dimming = vertcat(data(modelIndex,:).dimming);
        
        %         orientation = cellfun(@(x) (x(1)),{data(modelIndex,:).orientation});
        %         housing = cellfun(@(x) (x(1)),{data(modelIndex,:).housing});
        %         dimming = cellfun(@(x) (x(1)),{data(modelIndex,:).dimming});
        % index.baseDown = orientation,'d');
        % index.baseUp = strfind(orientation,'u');
        % index.baseHorizontal = strfind(orientation,'h');
        % index.housing = find(housing==1);
        % index.openAir = find(housing==0);
        % index.dimming = find(dimming==1);
        % index.noDimming = find(dimming==0);
        
        opConditions = { %(markerTypeList) (lineStyle)
            find(orientation=='u' & housing==0 & dimming==0),... % 1	5	Base-up	Open Air	30 on / 5 off	100%
            find(orientation=='d' & housing==0 & dimming==0),...% 2	5	Base-Down	Open Air	30 on / 5 off	100%
            find(orientation=='h' & housing==0 & dimming==0),...% 3	5	Base-Horizontal	Open Air	30 on / 5 off	100%
            find(orientation=='u' & housing==1 & dimming==0),...% 4	5	Base-up	Enclosed	30 on / 5 off	100%
            find(orientation=='u' & housing==0 & dimming==1),...% 5	3	Base-up	Open Air	30 on / 5 off	50%
            find(orientation=='d' & housing==0 & dimming==1),...% 6	2	Base-Down	Open Air	30 on / 5 off	50%
            find(orientation=='h' & housing==0 & dimming==1),...% 7	2	Base-Horizontal	Open Air	30 on / 5 off	50%
            find(orientation=='u' & housing==1 & dimming==1),...% 8	3	Base-up	Enclosed	30 on / 5 off	50%
            % 9	1	Base-up	Open Air	always on	100%%
            };
        
        %         colors = distinguishable_colors(length(opConditions));
        
        % %% -----------Determine when lamps burned out ------------------------
        offInd = zeros(1,30);
        for dum= 1:30
            temp = find(isnan(data(modelIndex,dum).(properties{i})));
            if ~isempty(temp)
                offInd(dum) = temp(1);
            end
        end
        
        %
        figure('Position',[300 300 800 300])
        %----------plot manufactured rated value--------------
        spec_color = [.5 .5 .5];
        ratedPropertyName = ['rated_' properties{i}];
        if isfield(data(modelIndex,1),ratedPropertyName)&&~isnan(data(modelIndex,1).(ratedPropertyName)(1))
                  ratedValue = data(modelIndex,1).(ratedPropertyName);  
            handleVector{1,1} = plot([hours(1,1) hours(end,1)],[ratedValue ratedValue],...
                'Color',spec_color,...
                'LineWidth', 5,...
                'LineStyle','--');
            hold all
        else
            ratedValue = NaN;
        end
        %----------plot data---------------------
        for j = 1:length(opConditions)
            if ~isempty(opConditions{j})
                y = tempProperty(:,opConditions{j});
                x = hours(:,opConditions{j});
                for k = 1:size(y,2)
                    if j == 1       %no min max on first itteration
                        minMax = [min(y(:,k)) max(y(:,k))];
                    else
                        minMax = [min([y(:,k); minMax(1)]) max([y(:,k); minMax(2)])];   %set the limits as symmetric about the rated value
                    end
                    
                    handleVector{j+1,k} = plot(x(:,k),y(:,k), ...
                        'Marker', markerType(plotStyle(j,3)), ...
                        'MarkerSize',markerSize, ...
                        'LineStyle',lineStyle{plotStyle(j,1)}, ...
                        'Color',colors(plotStyle(j,2),:), ...s
                        'LineWidth', lineWidth);
                    hold all
                end
                
                whenSamplesFailed = offInd(opConditions{j});
                samplesFailed = find(whenSamplesFailed~=0);
                
                %-------------- mark failures -----------------
                if ~isempty(samplesFailed)
                    for k = 1:length(samplesFailed)
                        plot(x(whenSamplesFailed(samplesFailed(k))-1,samplesFailed(k)), y(whenSamplesFailed(samplesFailed(k))-1,samplesFailed(k)),...
                            'Color',colors(plotStyle(j,2),:),...
                            'LineWidth', lineWidth,...
                            'Marker','o',...
                            'MarkerSize',16); %plot an X at the previous good point
                    end
                end
            end
        end
        %         ylimit = ylim;
        xlimit = xlim;
        p = -100;
        %--------------build array of linetypes for legend----------------
        h(1) = plot(p,p,'Color',spec_color, 'LineWidth',5,'LineStyle','--');
        h(2) = plot(p,p,'Color', colors(1,:),'LineWidth', lineWidth);
        h(3) = plot(p,p,'Color', colors(2,:),'LineWidth', lineWidth);
        h(4) = plot(p,p,'Color', colors(3,:),'LineWidth', lineWidth);
        h(5) = plot(p,p,'k', 'LineStyle', lineStyle{plotStyle(1,1)},'LineWidth', lineWidth);
        h(6) = plot(p,p,'k', 'LineStyle', lineStyle{plotStyle(end,1)},'LineWidth', lineWidth);
        h(7) = plot(p,p,'k', 'Marker', markerType(plotStyle(1,3)),'MarkerSize',markerSize,'LineStyle','none');
        h(8) = plot(p,p,'k', 'Marker', markerType(plotStyle(end,3)),'MarkerSize',markerSize,'LineStyle','none');
        h(9) = plot(p,p,'k', 'Marker', 'o','MarkerSize',16,'LineStyle','none');      
        
        xlim(xlimit)
        ylimTollerance = max(abs(ratedValue-minMax));
        if isnan(ratedValue)    %change plot configuration if rated values were not given
            ylim(minMax)
            legend(h(2:9),{'Base-up','Base-down','Base-horizontal','open-air','enclosed','no dim','50% dim','failure'},...
                'Location','SouthEastOutside')
        else
            ylim([ratedValue-ylimTollerance ratedValue+ylimTollerance])
            legend(h,{'Manufacturer rated value','Base-up','Base-down','Base-horizontal','open-air','enclosed','no dim','50% dim','failure'},...
                'Location','SouthEastOutside')
        end
        set(gca,'Position', [0.13 0.11 0.5 0.8])    %ensures that axes box is the same size regardless of legend content
        xlabel('Hours')
        ylabel(ylabelText{i})
        title(['Product ' num2str(modelIndex) ' - ' properties{i}])
        %             legend(num2str([1:30]'))
        %         legend([handleVector{:,1}],opConditionsNames)
    end
end