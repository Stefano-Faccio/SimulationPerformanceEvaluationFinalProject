% This function takes the 95% CIs of the iteration means (experimental)
% and checks how many points of the chosen population model (theoretical)
% fall into the corresponding CIs,
% from a global point of view, regardless of the position of the points (percentage-like)
% and from a range point of view, using the inflection time as the batch
% dimension

function [res, all_trues, all_falses, stat_ranges] = isInCI(CImat, PopModel, INFLECTION_TIME)

    res = zeros(1,length(CImat));
    for i=1:length(CImat)
        if PopModel(i) >= CImat(1,i) && PopModel(i) <= CImat(2,i)
            res(i) = true;
        else
            res(i) = false;
        end
    
    end
    all_trues = sum(res,'all'); % global point of view
    all_falses = length(CImat) - all_trues;

    % This part can be generalized better 
    % We assume there is always going to be a rest
    splits = floor(length(CImat) / INFLECTION_TIME);
    rest = mod(length(CImat),INFLECTION_TIME);
    ranges = reshape(res(1:end-rest),splits,[]);
    last_range = [ranges(splits,:) res(end-rest+1:end)];
    ranges(end,:)=[];
    
    stat_ranges = [];
    for i=1:height(ranges)
        trues = sum(ranges(i,:),'all');
        falses = length(ranges) - trues;
        stat_ranges = [stat_ranges [trues;falses]];
    end
    
    trues = sum(last_range,'all');
    falses = length(last_range) - trues;
    stat_ranges = [stat_ranges [trues;falses]]; 
end