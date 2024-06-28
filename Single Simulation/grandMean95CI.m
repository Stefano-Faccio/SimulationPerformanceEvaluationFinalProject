function [ci95_1, ci95_2]  = grandMean95CI(Mean, grandMean, dimension) 
    squaredDiff = (Mean - grandMean).^2;
    var = (1/(dimension-1)) * sum(squaredDiff);
    %gamma = 0.95; 
    %tS_column = (1+gamma)/2;
    if dimension>100 && dimension < 1000 % iterations (501)
        tS_1 = 1.984; % one tail
        tS_2 = 2.276; % two tail
    elseif dimension >= 1000 % simulations (1000)
        tS_1 = 1.962;% one tail
        tS_2 = 2.245;% two tail
    end
    bound_1 = tS_1 * sqrt(var/dimension);
    bound_2 = tS_2 * sqrt(var/dimension);
    ci95_1 = [grandMean-bound_1 grandMean+bound_1];
    ci95_2 = [grandMean-bound_2 grandMean+bound_2];
end
