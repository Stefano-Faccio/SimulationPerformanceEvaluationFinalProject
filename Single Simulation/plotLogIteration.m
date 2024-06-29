% This function takes as input the following arguments:
% 1) table of simulations,
% 2) theoretical exponential function population (y) values given simulation time (x) values
% 3) theoretical logistic function population (y) values given the simulation time (x) values
% 4) number of simulations (table columns), 
% 5) number of iterations (table rows), 
% 6) chosen number of first n interations to check (number of table rows otherwise)
% 7) window for the moving average of each simulation data (population evolution),
% 8) array of colors to visually detect simulations
% 9) ymin boundary for plot
% 10) ymax boundary for plot
% 11) crowding coefficient (C)
% 12) theoretical reproduction probability (R)
% 13) theoretical death probability (D)
% 14) initial population (N_0)
% 15) INFLECTION_POPULATION
% 16) INFLECTION_TIME

% This function returns as output the following arguments:
% 3) each time mean array of simulation values (TimeWiseGrandMean)
% 4) the array resulting from calculating the mean of y (population) values (of all simulations) for each x (time) value, referred to as timeWiseMean
% 5) the plot of all simulation data (with moving average to smooth data for visualisation)
% 5) overlapping with the corresponding plot of the theoretical exponential and logistic plots


function [popTGrandMean,popTMean, popTVar] = plotLogIteration(T, arrayE, arrayL, nSim, nIter, timeCut, movMeanWindow, colors,ymin,ymax, C,R,D,N_0, INFLECTION_POPULATION, INFLECTION_TIME)
    t = 0:nIter-1;
    t = t(1:end-(end-timeCut));
    colorCount = 0;
    
    figure; %
    hold on;
    popMean = [];
    
    for i=1:nSim
        pop = table2array(T(1:end-(end-timeCut),i));
        window = movMeanWindow;
        if window==0
            popMovMean = plot(t, pop, 'Color', colors(mod(colorCount,length(colors))+1), 'LineWidth', 1);
        else
            popMovMean = plot(t, movmean(pop, window), 'Color', colors(mod(colorCount,length(colors))+1), 'LineWidth', 1);
        end
        %colorCount = colorCount + 1; 
    end
    
    popTMean = [];
    popTVar = [];
    for i=1:nIter-(nIter-timeCut)
        popT = table2array(T(i,:));
        popTMean = [popTMean mean(popT)];
        popTVar = [popTVar var(popT)];
    end
    
    popTGrandMean = mean(popTMean);
   
    popTGrandMeanY = yline(popTGrandMean, 'k', 'LineWidth', 1.5, 'LineStyle','-.');
    pEm = plot(t, arrayE(1:end-(end-timeCut)), '*', Color ="#0093AF");
    pLm = plot(t, arrayL(1:end-(end-timeCut)), 'o', Color ="#3CB44B",LineWidth=1.5 );
    timeWiseMean = plot(t,popTMean, 'k', 'LineWidth', 1.5);
    inflectionPopY = yline(INFLECTION_POPULATION,"r:", "N*",  'LineWidth', 1.5);
    inflectionTimeX = xline(INFLECTION_TIME,  "b:","t*",'LineWidth', 1.5);
    xlabel("t (time) - iterations");
    ylabel('N (Population)');
    legend([pEm pLm timeWiseMean popTGrandMeanY inflectionPopY inflectionTimeX], 'Exponential growth', 'Logistic growth','Iteration means \mu(N_i)', 'Iteration grand mean', 'N*', 't*', Location='southeast');
    ylim([ymin ymax]);
    title_="Logistic growth: simulation vs theory";
    if window==0
        subtitle_ = ["Simulations: " + nSim + ", Iterations:  " + timeCut + "; Iteration grand mean: " + round(popTGrandMean,2) + ";", ...
        "Theoretical inflection population (N*): "+INFLECTION_POPULATION+"; Theoretical inflection time (t*): "+INFLECTION_TIME+ ";", ...
        "R: " + R + "; D: " + D + "; c: " +  C + "; N_0: " + N_0 + ";"];
    else
        subtitle_ = ["Moving average of population per simulation with a window of " + window + ";", ...
        "Simulations: " + nSim + ", Iterations:  " + timeCut + "; Simulation grand mean: " + round(popTGrandMean,2) + ";", ...
        "Theoretical inflection population (N*): "+INFLECTION_POPULATION+"; Theoretical inflection time (t*): "+INFLECTION_TIME+ ";",...
        "R: " + R + "; D: " + D + "; c: " +  C + "; N_0: " + N_0 + ";"];
    end
    title(title_);
    subtitle(subtitle_);
    ax = gca;
    fontsize(ax, scale=1.6);
    xlim('tight');
    hold off;
    
end