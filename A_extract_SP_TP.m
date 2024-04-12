%% Code Example for Extracting snow cover days, snow onset date, and snow end date for 2019 snow season year

% Daily snow cover products from the last year
last_year = 2019;
fileFolder_last_year = fullfile('C: HMRFSTP\',num2str(last_year));
dirOutput_last_year = dir(fullfile(fileFolder_last_year,'*.tif'));
dirOutput_last_year = dirOutput_last_year(244:365,:); % Day of year (DOY) 244-365 in common years, DOY 245-366 in leap years
fileNames_last_year = {dirOutput_last_year.name};
numFrames_last_year = numel(fileNames_last_year);

s_last_year = readgeoraster(['C: HMRFSTP\',num2str(last_year),'\',fileNames_last_year{1}]);
snow_last_year = zeros([size(s_last_year) numFrames_last_year],class(s_last_year));
snow_last_year(:,:,1) = s_last_year;
for p = 2:numFrames_last_year
    snow_last_year(:,:,p) = readgeoraster(['C: HMRFSTP\',num2str(last_year),'\',fileNames_last_year{p}]);
end

% Daily snow cover products from the current year
current_year = 2020;
fileFolder_current_year = fullfile('C: HMRFSTP\',num2str(current_year));
dirOutput_current_year = dir(fullfile(fileFolder_current_year,'*.tif'));
dirOutput_current_year = dirOutput_current_year(1:244,:);
fileNames_current_year = {dirOutput_current_year.name};
numFrames_current_year = numel(fileNames_current_year);

s_current_year = readgeoraster(['C: HMRFSTP\',num2str(current_year),'\',fileNames_current_year{1}]);
snow_current_year= zeros([size(s_current_year) numFrames_current_year],class(s_current_year));
snow_current_year(:,:,1) = s_current_year;
for p = 2:numFrames_current_year
    snow_current_year(:,:,p) = readgeoraster(['C: HMRFSTP\',num2str(current_year),'\',fileNames_current_year{p}]);
end

snow_season = reshape(cat(3,snow_last_year,snow_current_year),3107*5676,numFrames_last_year+numFrames_current_year);

% Identification of snow cover days(SCD)
SCD_2019 = NaN(3107*5676,1);         
parfor i = 1:3107*5676
    snowflag = snow_season(i,:);
    SCD_2019(i) = sum(snowflag == 1);  
end
SCD_2019 = reshape(SCD_2019,3107,5676);

% Identification of snow onset date (SOD)
SOD_2019 = NaN(3107*5676,1);       
parfor i = 1:3107*5676
    snowflag = snow_season(i,:);
    idx = find(snowflag == 1);
    if ~isempty(idx) && length(idx) >= 5
        for j = 1:length(idx)-4
            if idx(j) == idx(j+1)-1 && idx(j+1) == idx(j+2)-1 && idx(j+2) == idx(j+3)-1 && idx(j+3) == idx(j+4)-1
                SOD_2019(i) = idx(j);
                break;
            end
        end
    end
end
SOD_2019 = reshape(SOD_2019,3107,5676);

% Identification of snow end date (SED)
SED_2019 = NaN(3107*5676,1);       
parfor i = 1:3107*5676
    snowflag = snow_season(i,:);
    idx = flip(find(snowflag == 1)); %The flip function reverses the order of the indexes, looking from back to front
    if ~isempty(idx) && length(idx) >= 5
        for j = 1:length(idx)-4
            if idx(j) == idx(j+1)+1 && idx(j+1) == idx(j+2)+1 && idx(j+2) == idx(j+3)+1 && idx(j+3) == idx(j+4)+1
                break
            end
        end
        if j == length(idx)-4 && idx(j) == idx(j+1)+1 && idx(j+1) == idx(j+2)+1 && idx(j+2) == idx(j+3)+1 && idx(j+3) == idx(j+4)+1
            SED_2019(i) = idx(j);
        elseif j < length(idx)-4
            SED_2019(i) = idx(j);
        end
    end
end
SED_2019 = reshape(SED_2019,3107,5676);

% Output the result in tif format
load('R.mat');
filename_SCD = ['SCD_',num2str(last_year),'.tif'];
geotiffwrite(filename_SCD, SCD_2019, R,'CoordRefSysCode',32645);

filename_SOD = ['SOD_',num2str(last_year),'.tif'];
geotiffwrite(filename_SOD, SCD_2019, R,'CoordRefSysCode',32645);
filename_SED = ['SED_',num2str(last_year),'.tif'];
geotiffwrite(filename_SED, SCD_2019, R,'CoordRefSysCode',32645);