
clear all
close all
clc

cd('photometric data')
load LEDLifeTestingData3.mat


opConditionsNames = {
    'Manufacturer rated value'
    'Base-Up, Open Air, 100%'
    'Base-Down, Open Air ,100%'
    'Base-Horizontal, Open Air, 100%'
    'Base-Up, Enclosed,100%'
    'Base-Up, Open Air ,50%'
    'Base-Down ,Open Air ,50%'
    'Base-Horizontal, Open Air, 50%'
    'Base-Up, Enclosed, 50%'
    };

colors = [
    1 0 0  %base up
    0 .8 0 %base down
    0 0 1 %base horizontal
    ];

markerType = [
    'v' %open air
    'o' %enclosed
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
borderColors = [
    .9 .9 .9
    .4 .4 .4];

lineWidth = [2 1.5];
markerSize = 8;

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


% openfig('CIE_1931_zoom.fig')


for modelIndex = 1:20
    %     for i = 1:length(properties)
    CIEx = vertcat(data(modelIndex,:).CIEx)';
    CIEy = vertcat(data(modelIndex,:).CIEy)';
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
        temp = find(isnan(data(modelIndex,dum).CIEx));
        if ~isempty(temp)
            offInd(dum) = temp(1);
        end
    end
    
    
    
    %----------plot data---------------------
    openfig('C:\Users\dhstuart\Dropbox\CLTC\Chromaticity Files\CIE_1931_zoom.fig')
    set(gcf,'Position',[300 300 800 380],'Color',[1 1 1])
    for j = 1:length(opConditions)
        if ~isempty(opConditions{j})
            x = CIEx(1,opConditions{j});
            y = CIEy(1,opConditions{j});
            for k = 1:size(y,2)
                if j == 1       %no min max on first itteration
                    %                     minMaxX = [min(x(:,k)) max(x(:,k))];
                    %                     minMaxY = [min(y(:,k)) max(y(:,k))];
                    minMaxX = [min(x) max(x)];
                    minMaxY = [min(y) max(y)];
                else
                    %                     minMaxX = [min([x(:,k); minMaxX(1)]) max([x(:,k); minMaxX(2)])];   %set the limits as symmetric about the rated value
                    %                     minMaxY = [min([y(:,k); minMaxY(1)]) max([y(:,k); minMaxY(2)])];   %set the limits as symmetric about the rated value
                    minMaxX = [min([x minMaxX(1)]) max([x minMaxX(2)])];   %set the limits as symmetric about the rated value
                    minMaxY = [min([y minMaxY(1)]) max([y minMaxY(2)])];   %set the limits as symmetric about the rated value
                end
                
                %                     xflip = [x(1 : end - 1,k); flipud(x(:,k))];
                %                     yflip = [y(1 : end - 1,k); flipud(y(:,k))];
                %                     if j == jj
                handleVector{j+1,k} = scatter(x, y,50,...
                    'Marker', markerType(plotStyle(j,3)), ...
                    ...'MarkerSize',markerSize, ...
                    ...'LineStyle',lineStyle{plotStyle(j,1)}, ...
                    'LineWidth', lineWidth(2),...
                    'MarkerFaceColor',borderColors(plotStyle(j,3),:),...
                    'MarkerEdgeColor',colors(plotStyle(j,2),:));
                
                %-------------- mark failures -----------------
                whenSamplesFailed = offInd(opConditions{j});
                samplesFailed = find(whenSamplesFailed~=0);
                
                if ~isempty(samplesFailed)
                    %                     for k = 1:length(samplesFailed)
                    %                         plot(x(whenSamplesFailed(samplesFailed(k))-1,samplesFailed(k)), y(whenSamplesFailed(samplesFailed(k))-1,samplesFailed(k)),...
                    %                             'Color',colors(plotStyle(j,2),:),...
                    %                             'LineWidth', lineWidth(1),...
                    %                             'Marker','o',...
                    %                             'MarkerSize',16); %plot an X at the previous good point
                    %                     end
                end
                %                     else
                %                         handleVector{j+1,k} = patch(xflip, yflip, 'r', ...
                %                             'EdgeAlpha', 0.05, ...
                %                             'FaceColor', 'none', ...
                %                             'Marker', 'none',... markerType(plotStyle(j,3)), ...
                %                             'MarkerSize',markerSize, ...
                %                             'LineStyle',lineStyle{plotStyle(j,1)}, ...
                %                             'EdgeColor',colors(plotStyle(j,2),:), ...
                %                             'LineWidth', lineWidth(1));
                %                     end
                hold all
            end
        end
    end
    p = -1;
    spec_color = [.5 .5 .5];
    %     h(1) = plot(p,p,'Color',spec_color, 'LineWidth',3,'LineStyle','--');
    h(1) = plot(p,p,'Color', [0 0 0],'LineWidth', 1);
    h(2) = plot(p,p,'Color', [.5 .5 .5],'LineWidth', 1);
    h(3) = plot(p,p,'Color', [0 0 1],'LineWidth', 1);
    h(4) = plot(p,p,'Color', colors(1,:),'LineWidth', lineWidth(1));
    h(5) = plot(p,p,'Color', colors(2,:),'LineWidth', lineWidth(1));
    h(6) = plot(p,p,'Color', colors(3,:),'LineWidth', lineWidth(1));
    h(7) = plot(p,p,'k', 'Marker', markerType(plotStyle(1,3)),'MarkerSize',markerSize,'LineStyle','none', 'LineWidth', lineWidth(2),...
        'MarkerFaceColor','none',...
        'MarkerEdgeColor','k');
    h(8) = plot(p,p,'k', 'Marker', markerType(plotStyle(end,3)),'MarkerSize',markerSize,'LineStyle','none', 'LineWidth', lineWidth(2),...
        'MarkerFaceColor','none',...
        'MarkerEdgeColor','k');
    h(9) = plot(p,p,'Color', borderColors(1,:),'LineWidth', lineWidth(1));
    h(10) = plot(p,p,'Color', borderColors(2,:),'LineWidth', lineWidth(1));

    
    %     if isnan(ratedValue)    %change plot configuration if rated values were not given
    legend(h,{'Blackbody Locus','7-Step MacAdam','4-step MacAdam','Base-Up','Base-Down','Base-Horizontal','Open-Air','Enclosed','No Dim','50% Dim','Failure'},...
        'Location','EastOutside')
    %     else
    %         legend(h,{'Manufacturer rated value','Base-up','Base-down','Base-horizontal','open-air','enclosed','no dim','50% dim','failure'},...
    %             'Location','SouthOutside')
    %     end
    axis equal
    axis([0.42 0.48 0.380 0.440])
    title(['CIE 1931 Chromaticity Diagram - Product ' num2str(modelIndex)])
    export_fig(gcf,['model ' num2str(modelIndex) 'chromaticity.png'],'-r300')%,opts)
    
    %     h1=gcf;
    %         h2=figure('Position',[300 300 800 380]);
    %         objects=allchild(h1);
    %         copyobj(get(h1,'children'),h2);
    
    bufferX = diff(minMaxX)*.1;
    bufferY = diff(minMaxY)*.1;
    if bufferX >= bufferY
        xlim([minMaxX(1)-bufferX minMaxX(2)+bufferX])

        ylim([mean(minMaxY)-bufferX*6 mean(minMaxY)+bufferX*6]) %make axis equal
    else
        xlim([mean(minMaxX)-bufferY*6 mean(minMaxX)+bufferY*6]) %make axis equal
        ylim([minMaxY(1)-bufferY minMaxY(2)+bufferY])
    end
    
    axis square
    title(['CIE 1931 Chromaticity Diagram - Product ' num2str(modelIndex) ' (zoomed)'])
    export_fig(gcf,['model ' num2str(modelIndex) 'chromaticity_zoom.png'],'-r300')%,opts)
    
end
