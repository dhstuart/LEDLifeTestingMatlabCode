% LED_life_testing_data_reduction.m

clear all
close all
clc

% cd('photometric data')
load Data\LEDLifeTestingData2.mat
%
properties = {
    %     'percentFlicker'
    %     'luminousFlux'
    'CCT'
    %     'Duv'
    %     'Ra'
    %     'power'
    %     'powerFactor'
    };

ylabelText = {
    %     'Percent Flicker'
    %     'Lumens'
    'Kelvin'
    %     'Duv'
    %     'Ra'
    %     'Watts'
    %     'Power Factor'
    };
titleText = {
    %         'Percent Flicker'
    %     'Luminous Flux'
    'Color Correlated Temperature'
    %     'Duv'
    %     'Color Rendering Index'
    %     'Power'
    %     'Power Factor'
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
pseudoTransparentColors = [
    1 .75 .75
    .75 .95 .75
    .75 .75 1
    ];
opConditionsNames = {
    'Manufacturer Rated Value'
    'Base-Up, Open Air, 100%'
    'Base-Down, Open Air, 100%'
    'Base-Horizontal, Open Air, 100%'
    'Base-Up, Enclosed, 100%'
    'Base-Up, Open Air, 50%'
    'Base-Down, Open Air, 50%'
    'Base-Horizontal, Open Air, 50%'
    'Base-Up, Enclosed, 50%'
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

lineWidth = [2 1];
markerSize = 8;

ylimTollerance.luminousFlux = [0 1100];
ylimTollerance.CCT = 200;
% ylimit.Duv = [2500 3200];
% ylimit.Ra = [2500 3200];

for modelIndex = 1:20
    for iProperties = 1:length(properties)
        tic
        tempProperty = vertcat(data(modelIndex,:).(properties{iProperties}))';
        hours = vertcat(data(modelIndex,:).hours)';
        orientation = vertcat(data(modelIndex,:).orientation);
        housing = vertcat(data(modelIndex,:).housing);
        dimming = vertcat(data(modelIndex,:).dimming);
        
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
        
        
        % %% -----------Determine when lamps burned out ------------------------
        offInd = zeros(1,31);
        for dum = 1:31
            photometricLamps(dum) = data(modelIndex,dum).rack==1 & (data(modelIndex,dum).branch==2|data(modelIndex,dum).branch==3|data(modelIndex,dum).branch==4); %photometric lamps don't have interim measurements so are marked by NaN,but not dead
            temp = find(isnan(data(modelIndex,dum).luminousFlux) &~ photometricLamps(dum));
            if ~isempty(temp)
                offInd(dum) = temp(1);
            end
        end
        
        
        
        for iFigure = 1:2    %split subplots between two pages
            len = length(opConditions);
            figureCoordinates = [10 10 1000 1100];
            fig = figure('Position',figureCoordinates,'Color',[1 1 1]);
            for iSubPlot = 1:len/2
                iOpConditionHighlighted = (iFigure-1)*len/2+iSubPlot;
                subPlotHandle(iSubPlot) = subplot(2,2,iSubPlot);
                
                
                
                %----------plot data---------------------
                initialIndexAll = tempProperty(1,:);
                finalIndexAll = tempProperty(end,:);
                initialMeanAll(modelIndex) = mean(initialIndexAll(~isnan(initialIndexAll)));
                initialStdAll(modelIndex) = std(initialIndexAll(~isnan(initialIndexAll)));
                finalMeanAll(modelIndex) = mean(finalIndexAll(~isnan(finalIndexAll)));
                finalStdAll(modelIndex) = std(finalIndexAll(~isnan(finalIndexAll)));
                
                tempIndex = 1:length(opConditions);
                opConditionsOrder = [tempIndex(tempIndex~=iOpConditionHighlighted) iOpConditionHighlighted]; %plot highlighted condition last so it's on top
                for iOpConditions = opConditionsOrder
                    if iOpConditions == length(opConditions)
                        %----------plot manufactured rated value--------------
                        spec_color = [.5 .5 .5];
                        ratedPropertyName = ['rated_' properties{iProperties}];
                        if isfield(data(modelIndex,1),ratedPropertyName)&&~isnan(data(modelIndex,1).(ratedPropertyName)(1))
                            ratedValue = data(modelIndex,1).(ratedPropertyName);
                            handleVector{1,1} = plot([hours(1,1) hours(end,1)],[ratedValue ratedValue],...
                                'Color',spec_color,...
                                'LineWidth', 3,...
                                'LineStyle','--');
                            hold all
                        else
                            ratedValue = NaN;
                        end
                    end
                    if ~isempty(opConditions{iOpConditions})
                        y = tempProperty(:,opConditions{iOpConditions});
                        x = hours(:,opConditions{iOpConditions});
                        %get statistics on delta on properties
                        iInitial = y(1,:);
                        iFinal = y(end,:);
                        initialMean(modelIndex,iOpConditions) = mean(iInitial(~isnan(iInitial)));
                        initialStd(modelIndex,iOpConditions) = std(iInitial(~isnan(iInitial)));
                        finalMean(modelIndex,iOpConditions) = mean(iFinal(~isnan(iFinal)));
                        finalStd(modelIndex,iOpConditions) = std(iFinal(~isnan(iFinal)));
                        
                        for iHours = 1:size(y,2)
                            if iOpConditions == opConditionsOrder(1) && iHours == 1      %no min max on first itteration
                                minMax = [min(y(:,iHours)) max(y(:,iHours))];
                            else
                                minMax = [min([y(:,iHours); minMax(1)]) max([y(:,iHours); minMax(2)])];   %set the limits as symmetric about the rated value
                            end
                            
                            %mirror x and y points to create patch line instead of polygon
                            if iOpConditions == iOpConditionHighlighted

                                handleVector{iOpConditions+1,iHours} = plot(x, y,...
                                    'Marker', markerType(plotStyle(iOpConditions,3)), ...
                                    'MarkerSize',markerSize, ...
                                    'LineStyle',lineStyle{plotStyle(iOpConditions,1)}, ...
                                    'Color',colors(plotStyle(iOpConditions,2),:), ...
                                    'LineWidth', lineWidth(1));
                                
                                %-------------- mark failures -----------------
                                whenSamplesFailed = offInd(opConditions{iOpConditions});
                                samplesFailed = find(whenSamplesFailed~=0);
                                
                                if ~isempty(samplesFailed)
                                    for iHours = 1:length(samplesFailed)
                                        plot(x(whenSamplesFailed(samplesFailed(iHours))-1,samplesFailed(iHours)),...
                                            y(whenSamplesFailed(samplesFailed(iHours))-1,samplesFailed(iHours)),...
                                            'Color',colors(plotStyle(iOpConditions,2),:),...
                                            'LineWidth', lineWidth(1),...
                                            'Marker','o',...
                                            'MarkerSize',16); %plot an X at the previous good point
                                    end
                                end
                            else
                                handleVector{iOpConditions+1,iHours} = plot(x, y, ...
                                    'Marker', 'none',... 
                                    'MarkerSize',markerSize, ...
                                    'LineStyle',lineStyle{plotStyle(iOpConditions,1)}, ...
                                    'Color',pseudoTransparentColors(plotStyle(iOpConditions,2),:), ...
                                    'LineWidth', lineWidth(2));
                            end
                            hold all
                        end
                    end
                end
                xlimit = xlim;
                p = -100;
                %--------------build array of linetypes for legend----------------
                xlim([0 xlimit(2)])
                ylimTollerance = max(abs(ratedValue-minMax))*1.1;
                if isnan(ratedValue) && diff(minMax)~=0    %change plot configuration if rated values were not given
                    ylim([minMax(1)-abs(0.05*minMax(1)) minMax(2)+abs(0.05*minMax(2))])
                elseif diff(minMax)==0
                else
                    ylim([ratedValue-ylimTollerance ratedValue+ylimTollerance])
                end
                %             set(gca,'Position', [0.13 0.11 0.5 0.8])    %ensures that axes box is the same size regardless of legend content
                xlabel('Hours')
                ylabel(ylabelText{iProperties})
                %             title(['Product ' num2str(modelIndex) ' - ' properties{i}])
                title(['Product ' num2str(modelIndex) ' - ' opConditionsNames{iOpConditionHighlighted+1}])
            end
            h(1) = plot(p,p,'Color',spec_color, 'LineWidth',3,'LineStyle','--');
            h(2) = plot(p,p,'Color', colors(1,:),'LineWidth', lineWidth(1));
            h(3) = plot(p,p,'Color', colors(2,:),'LineWidth', lineWidth(1));
            h(4) = plot(p,p,'Color', colors(3,:),'LineWidth', lineWidth(1));
            h(5) = plot(p,p,'k', 'LineStyle', lineStyle{plotStyle(1,1)},'LineWidth', lineWidth(1));
            h(6) = plot(p,p,'k', 'LineStyle', lineStyle{plotStyle(end,1)},'LineWidth', lineWidth(1));
            h(7) = plot(p,p,'k', 'Marker', markerType(plotStyle(1,3)),'MarkerSize',markerSize,'LineStyle','none');
            h(8) = plot(p,p,'k', 'Marker', markerType(plotStyle(end,3)),'MarkerSize',markerSize,'LineStyle','none');
            h(9) = plot(p,p,'k', 'Marker', 'o','MarkerSize',16,'LineStyle','none');
            
            if isnan(ratedValue)    %change plot configuration if rated values were not given
                legendHandle = legend(h(2:9),{'Base-Up','Base-Down','Base-Horizontal','Open-Air','Enclosed','No Dim','50% Dim','Failure'},...
                    'Location','SouthEastOutside');
            else
                legendHandle = legend(h,{'Manufacturer Rated Value','Base-Up','Base-Down','Base-Horizontal','Open-Air','Enclosed','No Dim',...
                    '50% Dim','failure'},...
                    'Location','SouthOutside');
            end
            legendPosition = get(legendHandle,'Position');
            subPlotSize = [.335 .286];
            set(subPlotHandle(1),'Position',[0.094 0.642 subPlotSize])
            set(subPlotHandle(2),'Position',[0.094 0.271 subPlotSize])
            set(subPlotHandle(3),'Position',[0.595 0.642 subPlotSize])
            set(subPlotHandle(4),'Position',[0.595 0.271 subPlotSize])
            
            set(legendHandle,'Position',[0.400 0.052 legendPosition(3) legendPosition(4)])
            annotation('textbox',[0.282 0.962 0.457 0.029],...
                'String', [titleText{iProperties}, ' - Product ', num2str(modelIndex)],...
                'LineStyle','none',...
                'HorizontalAlignment', 'center',...
                'FontSize', 16)
            export_fig(gcf,[pwd '\Plots\product ' num2str(modelIndex) ' - ' num2str(iFigure) ' ' properties{iProperties} '.pdf']);%,'-r500')
            close(gcf)
        end
        elapsedTime = toc;
        itterationsLeft = (20*length(properties)*2) - ((modelIndex-1)*length(properties)*2+(iProperties-1)*2);
        timeLeft = itterationsLeft*toc/60;
        disp(['time left is ' num2str(timeLeft) ' minutes'])
    end
end