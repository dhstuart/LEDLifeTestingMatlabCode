% LED_life_testing_data_reduction.m

% clear all
close all
clc

% cd('photometric data')
load Data\LEDLifeTestingData2.mat

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

lineWidth = [2 2];
markerSize = 8;

ylimTollerance.luminousFlux = [0 1100];
ylimTollerance.CCT = 200;
% ylimit.Duv = [2500 3200];
% ylimit.Ra = [2500 3200];

for modelIndex = 15%1:20
    %     for i = 1:length(properties)
    tempProperty = [];
    for collectSPD = 1:30
        tempProperty = [tempProperty (data(modelIndex,collectSPD).SPD(:,1))];
    end
    %         tempProperty = vertcat(data(modelIndex,:).SPD(:,1))';
    nm = repmat((360:1000)',1,30);
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
    
    %         % %% -----------Determine when lamps burned out ------------------------
    %         offInd = zeros(1,30);
    %         for dum= 1:30
    %             temp = find(isnan(data(modelIndex,dum).(properties{i})));
    %             if ~isempty(temp)
    %                 offInd(dum) = temp(1);
    %             end
    %         end
    
    
    
    for twofig = 1:2
        len = length(opConditions);
        
        for opCond = 1:len/2
            jj = (twofig-1)*len/2+opCond;
            jj=4
            %             subPlotHandle(opCond) = subplot(2,2,opCond);
            figureCoordinates = [100 100 1000 500];
            fig = figure('Position',figureCoordinates,'Color',[1 1 1]);
            
            %                 %----------plot manufactured rated value--------------
            spec_color = [.5 .5 .5];
            %                 ratedPropertyName = ['rated_' properties{i}];
            %                 if isfield(data(modelIndex,1),ratedPropertyName)&&~isnan(data(modelIndex,1).(ratedPropertyName)(1))
            %                     ratedValue = data(modelIndex,1).(ratedPropertyName);
            %                     handleVector{1,1} = plot([hours(1,1) hours(end,1)],[ratedValue ratedValue],...
            %                         'Color',spec_color,...
            %                         'LineWidth', 3,...
            %                         'LineStyle','--');
            %                     hold all
            %                 else
            ratedValue = NaN;
            %                 end
            
            %----------plot data---------------------
            
            for j = 1:length(opConditions)
                if ~isempty(opConditions{j})
                    y = tempProperty(:,opConditions{j});
                    x = nm;
                    for k = 1:size(y,2)
                        if j==1 && k == 1       %no min max on first itteration
                            minMax = [min(y(:,k)) max(y(:,k))];
                        else
                            minMax = [min([y(:,k); minMax(1)]) max([y(:,k); minMax(2)])];   %set the limits as symmetric about the rated value
                        end
                        
                        xflip = [x(1 : end - 1,k); flipud(x(:,k))];
                        yflip = [y(1 : end - 1,k); flipud(y(:,k))];
                        if j == jj
                            handleVector{j+1,k} = patch(xflip, yflip, 'r', ...
                                'EdgeAlpha', 1, ...
                                'FaceColor', 'none', ...
                                'Marker', markerType(plotStyle(j,3)), ...
                                'Marker','none',...
                                'MarkerSize',markerSize, ...
                                'LineStyle',lineStyle{plotStyle(j,1)}, ...
                                'EdgeColor',colors(plotStyle(j,2),:), ...
                                'LineWidth', lineWidth(1));
                            
                            %-------------- mark failures -----------------
                            %                             whenSamplesFailed = offInd(opConditions{j});
                            %                             samplesFailed = find(whenSamplesFailed~=0);
                            %
                            %                             if ~isempty(samplesFailed)
                            %                                 for k = 1:length(samplesFailed)
                            %                                     plot(x(whenSamplesFailed(samplesFailed(k))-1,samplesFailed(k)), y(whenSamplesFailed(samplesFailed(k))-1,samplesFailed(k)),...
                            %                                         'Color',colors(plotStyle(j,2),:),...
                            %                                         'LineWidth', lineWidth(1),...
                            %                                         'Marker','o',...
                            %                                         'MarkerSize',16); %plot an X at the previous good point
                            %                                 end
                            %                             end
                        else
                            handleVector{j+1,k} = patch(xflip, yflip, 'r', ...
                                'EdgeAlpha', 0.05, ...
                                'FaceColor', 'none', ...
                                'Marker', 'none',... markerType(plotStyle(j,3)), ...
                                'MarkerSize',markerSize, ...
                                'LineStyle',lineStyle{plotStyle(j,1)}, ...
                                'EdgeColor',colors(plotStyle(j,2),:), ...
                                'LineWidth', lineWidth(1));
                        end
                        hold all
                    end
                end
            end
            xlimit = xlim;
            p = -100;
            %--------------build array of linetypes for legend----------------
            xlim([360 800])
            ylimTollerance = max(abs(ratedValue-minMax))*1.1;
            if isnan(ratedValue)    %change plot configuration if rated values were not given
                ylim(minMax*1.05)
            else
                ylim([ratedValue-ylimTollerance ratedValue+ylimTollerance])
                
            end
            %             set(gca,'Position', [0.13 0.11 0.5 0.8])    %ensures that axes box is the same size regardless of legend content
            xlabel('nm')
            ylabel('uW')
            grid on
            %             title(['Product ' num2str(modelIndex) ' - ' properties{i}])
            title(['Spectral Power Distribution - Product ' num2str(modelIndex) ' - ' opConditionsNames{jj+1}])
            h(1) = plot(p,p,'Color',spec_color, 'LineWidth',3,'LineStyle','--');
            h(2) = plot(p,p,'Color', colors(1,:),'LineWidth', lineWidth(1));
            h(3) = plot(p,p,'Color', colors(2,:),'LineWidth', lineWidth(1));
            h(4) = plot(p,p,'Color', colors(3,:),'LineWidth', lineWidth(1));
            h(5) = plot(p,p,'k', 'LineStyle', lineStyle{plotStyle(1,1)},'LineWidth', lineWidth(1));
            h(6) = plot(p,p,'k', 'LineStyle', lineStyle{plotStyle(end,1)},'LineWidth', lineWidth(1));
%             h(7) = plot(p,p,'k', 'Marker', markerType(plotStyle(1,3)),'MarkerSize',markerSize,'LineStyle','none');
%             h(8) = plot(p,p,'k', 'Marker', markerType(plotStyle(end,3)),'MarkerSize',markerSize,'LineStyle','none');
%             h(9) = plot(p,p,'k', 'Marker', 'o','MarkerSize',16,'LineStyle','none');
            
            if isnan(ratedValue)    %change plot configuration if rated values were not given
                leg = legend(h(2:6),{'Base-Up','Base-Down','Base-Horizontal','Open-Air','Enclosed','No Dim','50% Dim','Failure'},...
                    'Location','SouthEastOutside');
            else
                leg = legend(h,{'Manufacturer Rated Value','Base-Up','Base-Down','Base-Horizontal','Open-Air','Enclosed','No Dim',...
                    '50% Dim','failure'},...
                    'Location','SouthOutside');
            end
            export_fig(gcf,[pwd '\Plots\product ' num2str(modelIndex) ' - ' opConditionsNames{jj+1} ' SPD']);%,'-r500')
%                     close(gcf)
        end
        
        %         legPos = get(leg,'Position');
        %         subPlotSize = [.335 .286];
        %         set(subPlotHandle(1),'Position',[0.094 0.642 subPlotSize])
        %         set(subPlotHandle(2),'Position',[0.094 0.271 subPlotSize])
        %         set(subPlotHandle(3),'Position',[0.595 0.642 subPlotSize])
        %         set(subPlotHandle(4),'Position',[0.595 0.271 subPlotSize])
        %
        %         set(leg,'Position',[0.400 0.052 legPos(3) legPos(4)])
                    
    end
    %     end
end