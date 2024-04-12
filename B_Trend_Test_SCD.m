%% Code Example for trend analysis and M-K test for snow cover days

% Enter the SCD: [line (all pixels), year]
SCDall=load('SCDall_20.mat');  %SCD data can be exchanged for SOD and SED
series = reshape(SCDall.SCDall,3107*5676,20);

trend_sig_series = NaN(3107*5676,1);
trend_slope_series = NaN(3107*5676,1);
n = size(series,2); % year

parfor k = 1:3107*5676
    y = series(k,:);
    if numel(find(~isnan(y)&y ~=0)) >=10 % At least 6 years of recorded data
        [~,p,s,~] = MannKendall_TheilSen(y,n);
        if p < 0.1
            trend_sig_series(k) = 0.1;
            if p < 0.05
                trend_sig_series(k) = 0.05;
                if p < 0.01
                    trend_sig_series(k) = 0.01;
                end
            end
        end
        trend_slope_series(k) = s;
    end
end

trend_sig_series = reshape(trend_sig_series,3107,5676);
trend_slope_series = reshape(trend_slope_series,3107,5676);

load('R.mat');
geotiffwrite('trend_sig_SCD.tif',trend_sig_series,R,'CoordRefSysCode',32645);
geotiffwrite('trend_slope_SCD.tif',trend_slope_series,R,'CoordRefSysCode',32645);


