% This function takes as input the following arguments : 
% 1) table of simulations, 
% 2) number of simulations (table columns), 
% 3) number of iterations (table rows), 
% 4) chosen number of first n interations to check (number of table rows otherwise)
% 5) window for the moving average of each simulation data (population evolution),
% 6) array of colors to visually detect simulations
% 7) INFLECTION_POPULATION to visualize the theoretical inflection population
% 8) INFLECTION_TIME to visualize the corresponding theoretical inflection

% This function returns as output the following arguments:
% 1) each simulation mean array
% 2) the grand mean of all simulations
% 3) the plot of all simulation data (with moving average to smooth data for visualisation)

function [popGrandMean, popMean] = plotLogSimulation(T, nSim, nIter, timeCut, movMeanWindow, colors, string, INFLECTION_POPULATION, INFLECTION_TIME)
    t = 0:nIter-1;
    t = t(1:end-(end-timeCut));
    colorCount = 0;
    figure;
    hold on;
    popMean = [];
    for i=1:nSim
        pop = table2array(T(1:end-(end-timeCut),i));
        %sample mean for each replication
        popMean = [popMean mean(pop)];
        window = movMeanWindow;
        if window==0
            popMovMean = plot(t, pop,  'Color', colors(mod(colorCount,length(colors))+1), 'LineWidth', 1);
        else
            popMovMean= plot(t, movmean(pop, window),  'Color', colors(mod(colorCount,length(colors))+1), 'LineWidth', 1);
        end
        colorCount = colorCount + 1;
        
    end
    %sample grand mean
    popGrandMean = mean(popMean);
    popGrandMeanY = yline(popGrandMean, 'k-.', 'LineWidth', 1.5);
    inflectionPopY = yline(INFLECTION_POPULATION,"r:", "N*",  'LineWidth', 1.5);
    inflectionTimeX = xline(INFLECTION_TIME,  "b:","t*",'LineWidth', 1.5);
    title_ = "" + string + "Population evolution over time"; 
    tl = title(title_);
    %fontsize(tl, scale=1.4);
    if window==0
        subtitle_ = ["Simulations: " + nSim + ", Iterations:  " + timeCut + "; Simulation grand mean: " + round(popGrandMean,2) + ";", ...
        "Theoretical inflection population (N*): "+INFLECTION_POPULATION+"; Theoretical inflection time (t*): "+INFLECTION_TIME+ ";"];
    else
        subtitle_ = ["Moving average of population per simulation with a window of " + window + ";", ...
        "Simulations: " + nSim + ", Iterations:  " + timeCut + "; Simulation grand mean: " + round(popGrandMean,2) + ";", ...
        "Theoretical inflection population (N*): "+INFLECTION_POPULATION+"; Theoretical inflection time (t*): "+INFLECTION_TIME+ ";"];
    end
    subtitle(subtitle_);
    legend([popGrandMeanY, inflectionPopY inflectionTimeX], " Simulation grand mean", " N*", " t*", Location="southeast");
    xlabel("t (time) - iterations");
    ylabel('N (Population)');
    box on;
    ax = gca;
    axis tight;
    ax = gca;
    fontsize(ax, scale=1.6);
    
    hold off;
end