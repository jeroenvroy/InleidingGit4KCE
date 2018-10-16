%% Reset all
cd C:\Users\u0085535\Documents\Projecten\Lightman\Data-analyse
clear all
close all
clc

%% Loading data

dblData = xlsread('lichtgegevensBron.xlsx');
idx = dblData(:,1);
dtTime = datetime(dblData(:,2), 'convertFrom','excel');     % Get the time in datetime-format (data of each hour)
dtDayTime = dateshift(dtTime,'start','day','current');
dtDay = unique(dtDayTime);  % Get every unique day in the time serries
dblSunlight = dblData(:,3);
dblSunlightMol = dblSunlight*2.22*10^-2;
dblDataLettuce = xlsread('Oak Green.xlsx');
dtHarvest = datetime(2018,dblDataLettuce(:,2),dblDataLettuce(:,1));
dtPlant = dtHarvest - dblDataLettuce(:,3);
intDay = day(dtDay,'dayofyear');
intHarvest = day(dtHarvest, 'dayofyear');
intPlant = day(dtPlant, 'dayofyear');

% clear dblData dblDataLettuce
%% Settings greenhouse

intTrans = 70; % Light tranmission of the greenhouse in percentage 
intInstP = 45; %Installed power of the illumination in the greenhouse [µmol/m²s]
dblEff = 2.1;  % Efficiency of the illumination [µmol/J]
dblIllTime = 17; % Total time per day of illumination [h]

%% Preparing data for analysis

dblSunlightInGreenhouseMol = dblSunlightMol*intTrans/100; % Calculate sunlight in the greenhouse
for ii = 1:length(dtDay)
    dblDLISunlight(ii,1) = sum(dblSunlightInGreenhouseMol(find(dtDayTime==dtDay(ii,1)))); % calculate DLI (Daily Light Integral)
end

idx = find(dblDLISunlight == 0); % Remove DLI=0 from dataset (probably wrong measurements)
dblDLISunlight(idx) = [];
intDay(idx) = [];

for ii = 1:365
    dblAverageYear(ii,1) = mean(dblDLISunlight(intDay==ii));    % Take average DLI for each day
end

% Smooth average with chosen windowsize
intWindowSize = 5;
for ii = 1:365
    if ii < intWindowSize+1
        dblSmoothedYear(ii,1) = mean(dblAverageYear(1:ii+intWindowSize));
    else if ii > 365-intWindowSize
            dblSmoothedYear(ii,1) = mean(dblAverageYear(ii-intWindowSize:end));
        else
            dblSmoothedYear(ii,1) = mean(dblAverageYear(ii-intWindowSize:ii+intWindowSize));
        end
    end
end
% 
dblDLIIllumination = (dblIllTime*intInstP*3600)/10^6; % Calculate the DLI originating from the illumination

for ii = 1:length(intHarvest)
    if intHarvest(ii)<intPlant(ii)
        dblDLIPlantPeriod(ii,1) = sum(dblSmoothedYear(intPlant(ii):end))+sum(dblSmoothedYear(1:intHarvest(ii)));
    else
        dblDLIPlantPeriod(ii,1) = sum(dblSmoothedYear(intPlant(ii):intHarvest(ii)));
    end
end
%     
counterDouble = 0;
for ii = 1: 100
    counterDouble = ii*2;
    print(counterDouble)
end
%% 