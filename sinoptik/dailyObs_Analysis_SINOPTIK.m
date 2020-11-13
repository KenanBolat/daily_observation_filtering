%% Read all daily data from the awos observation data 
% from 10 minutes datafor analysis

% Be sure that the data is sorted by station id and date!!!!!!!!

clc; clear;
cd('E:\temp\Ground Station Data\2019-2020_analiz_1\sinoptik');
tenminutesData = dlmread('sinoptik.txt','\t');

tic
%% Eliminate unexpected data:
% Remove null(9999) values from the measurements
null_data = tenminutesData((tenminutesData(:,9) == 9999),:);
csvwrite('sinop_null.csv',null_data);
eliminated_data = tenminutesData((tenminutesData(:,9) ~= 9999),:);

% Remove values larger than 300 from the measurements
great_than_300data = eliminated_data((eliminated_data(:,9) > 300),:);
csvwrite('sinop_gt_300.csv',great_than_300data);
eliminated_data = eliminated_data((eliminated_data(:,9) <= 300),:);

% Add column for full date as datenum
eliminated_data(:,end+1)= datenum(eliminated_data(:,5),eliminated_data(:,6),eliminated_data(:,7));
minimum_date = datestr(min(eliminated_data(:,end)));
maximum_date = datestr(max(eliminated_data(:,end)));

csvwrite('sinop_eliminated.csv',eliminated_data);

% Find all stations 
all_available_stations = unique(eliminated_data(:,1));

%% Plot by snow dept for each day (assumption: a day includes one value)
plot_data = eliminated_data;
for st=1:size(all_available_stations)
    station_data = plot_data((plot_data(:,1) == all_available_stations(st)),:);

    if(size(station_data)>1)
        ts = timeseries(station_data(:,9),datestr(station_data(:,end)));
        ts.Name = 'Snow Depth Value (cm)';
        %ts.TimeInfo.Units = 'days';
        %min_date = datestr(min(station_data(:,end)));
        %ts.TimeInfo.StartDate = min_date;    % Set start date.
        ts.TimeInfo.Format = 'dd-mmm-yyyy';   % Set format for display on x-axis.
        %ts.Time = ts.Time - ts.Time(1);      % Express time relative to the start date.
        hFig = figure(1);
        set(hFig, 'Position', [0 0 3000 3000]);
        %figure; 
        plot(ts,'b-*'); 
        xlabel('Date');
    else
        hFig = figure(1);
        set(hFig, 'Position', [0 0 3000 3000]);
        %figure;
        plot(station_data(:,10),'b-*');
        ylabel('Snow Depth Value (cm)');
        xlabel(datestr(station_data(:,end)));
    end
    
    ax = gca;
    rotateXLabels(ax,45);
    title (all_available_stations(st));
    print(strcat(mat2str(all_available_stations(st)),'_sinop_filt.png'),'-dpng');
    close all;
end
toc