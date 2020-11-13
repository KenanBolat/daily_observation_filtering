%% Read all daily data from the awos/spa observation data 
% from 10 minutes datafor analysis

% Be sure that the data is sorted by station id and date!!!!!!!!

clc; clear;
cd('E:\temp\Ground Station Data\2019-2020_analiz_1\spa');
tenminutesData = dlmread('spa.txt','\t');

tic
%% Eliminate unexpected data:
% Remove null(9999) values from the measurements 
null_data = tenminutesData((tenminutesData(:,10) == 9999),:);
csvwrite('spa_null.csv',null_data);
null_eliminated_data = tenminutesData((tenminutesData(:,10) ~= 9999),:);

% % Remove blank values from the measurements (awos'ta format? hatal? veriler var)
% format_error_data = tenminutesData(isnan(tenminutesData(:,10)),:);
% csvwrite('awos_format_error.csv',format_error_data);
% eliminated_data = eliminated_data(~isnan(tenminutesData(:,10)),:);

% Remove values larger than 300 from the measurements
great_than_300data = tenminutesData((null_eliminated_data(:,10) > 300),:);
csvwrite('spa_gt_300.csv',great_than_300data);
eliminated_data = null_eliminated_data((null_eliminated_data(:,10) <= 300),:);

% Add column for full date as datenum
eliminated_data(:,end+1)= datenum(eliminated_data(:,5),eliminated_data(:,6),eliminated_data(:,7));
minimum_date = datestr(min(eliminated_data(:,end)));
maximum_date = datestr(max(eliminated_data(:,end)));

% Find all stations 
all_available_stations = unique(eliminated_data(:,1));

%% Filtering the Outliers: for the AWOS and SPA data only !!!
outlier_frame = 10 ;
filtered_data = [];
ignored_data = [];

for st=1:size(all_available_stations)
     (st/size(all_available_stations,1)*100)
    station_data = eliminated_data((eliminated_data(:,1) == all_available_stations(st)),:);
    if(size(station_data,1) >= outlier_frame)
        tmp_filt = []; tmp_not_filt = [];
        for out = outlier_frame:(size(station_data,1)-outlier_frame)
            mean_value = mean(station_data([out - outlier_frame+1:out-1 out+1:out+outlier_frame-1],10));
            if (station_data(out,10) <= mean_value)
                tmp_filt = [tmp_filt ; station_data(out,:)];
            elseif (station_data(out,10)-mean_value<50)
                tmp_filt = [tmp_filt ; station_data(out,:)];
            else
                tmp_not_filt = [tmp_not_filt ; station_data(out,:)];
            end
        end  
        %figure; plot(tmp_filt(:,10));
    end
    filtered_data =  [filtered_data; tmp_filt];
    ignored_data = [ignored_data ; tmp_not_filt];
end
csvwrite('spa_ignored.csv',ignored_data);
csvwrite('spa_filtered.csv',filtered_data);

%% Interpolation: for the AWOS and SPA data only !!!
interpolated_data = [];
for st=1:size(all_available_stations)
   
    station_data = filtered_data((filtered_data(:,1) == all_available_stations(st)),:);
    all_available_dates = unique(station_data(:,end));
    for dt=1:size(all_available_dates)
        date_data = station_data((station_data(:,end) == all_available_dates(dt)),:);
        mean_date_data = mean(date_data(:,10));
        one_row_data =  date_data(1,:);
        one_row_data(:,10) = mean_date_data;
        interpolated_data = [interpolated_data ; one_row_data];
    end  
end
csvwrite('spa_interpolated.csv',interpolated_data);

%% Plot by snow dept for each day (assumption: a day includes one value)

set(0,'DefaultFigureVisible','off')

plot_data = null_eliminated_data;
for st=1:size(all_available_stations)
    station_data = plot_data((plot_data(:,1) == all_available_stations(st)),:);

    if(size(station_data)>1)
        ts = timeseries(station_data(:,10),datestr(station_data(:,end)));
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
%     print(strcat(mat2str(all_available_stations(st)),'_spa_org.png'),'-dpng');
    close all;
end

%% Plot by snow dept for each day (assumption: a day includes one value)

set(0,'DefaultFigureVisible','off')

plot_data = interpolated_data;
for st=1:size(all_available_stations)
    station_data = plot_data((plot_data(:,1) == all_available_stations(st)),:);

    if(size(station_data)>1)
        ts = timeseries(station_data(:,10),datestr(station_data(:,end)));
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
    print(strcat(mat2str(all_available_stations(st)),'_spa_filt.png'),'-dpng');
    close all;
end
toc