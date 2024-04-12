function [Zc,p,sl,in] = MannKendall_TheilSen(y,n)
% output£º
% Zc£ºtest statistic
% p£ºp value
% sl£ºTrend size (slope)
% in£ºSlope median ordinate

% input£º
% y£ºtime series
% n£ºData sample length

    % Computation of statistics
    S = 0;
    for i = 1:n-1
        for j = i+1:n
            if ~isnan((y(j)-y(i)))
                S = S+sign(y(j)-y(i));
            end
        end
    end
    
    % Calculate variance (no bundled groups)
    Var = (n*(n-1)*(2*n+5))/18;
    
    % test statistic
    if S == 0
        Zc = 0;
    elseif S > 0
        Zc = (S-1)/sqrt(Var);
    else
        Zc = (S+1)/sqrt(Var);
    end
    
    % Critical value test for normal distribution
    p = 2*(1-normcdf(abs(Zc),0,1)); % Bilateral test
    
    % Calculate the slope
    ndash = n*(n-1)/2;
    slope = zeros(ndash,1);
    intercept = zeros(ndash,1);
    a = 1;
    for b = 1:n-1
        for c = b+1:n
            slope(a) = (y(c)-y(b))/(c-b);
            intercept(a) = y(c)-slope(a)*c;
            a = a+1;
        end
    end
    sl = median(slope,'omitnan');
    in = intercept(slope == sl);

end

