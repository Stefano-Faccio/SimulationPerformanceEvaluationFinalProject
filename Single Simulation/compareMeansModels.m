% This function plots the raw residuals of the iteration means wrt to the continuous, discrete and fitted models
% The long-term beahviour is included


function compareMeansModels(TIME, MeanArray, upCI, downCI, CM, DM, FM)
    
    figure;
    tl = tiledlayout(2,2);
    title(tl, "Comparison of CM, DM, and FM model fitting of \mu(N_i) values through the analysis of raw residuals")
    
    nexttile
    hold on;
    errorbar(TIME, MeanArray, downCI, upCI, ".");
    plot(TIME,CM, Color="#29AB87");
    plot(TIME,DM, ".", Color="#FF8243");
    plot(TIME,FM, "k");
    xlabel("time")
    ylabel("\mu(N_i)")
    legend ("\mu(N_i) 95% CIs", "CM: continuous model", "DM: discrete model", " FM: fitted model", Location="southeast")
    title(["A) Big picture of the CM, DM, and FM fitting of the experimental \mu(N_i) values"]);
    hold off;
    

    nexttile
    hold on;
    plot(TIME,MeanArray-CM, ".",Color="#29AB87", LineWidth=1.5);
    box on;
    yline(0, '-', '\DeltaN=0',Color="#8C92AC",LineWidth=1.25);
    ylabel("\DeltaN");
    xlabel("t (time) - units");
    title(["B) Difference in population (\DeltaN) between \mu(N_i) values"," and continuous logistic growth per time unit;"]);
    legend("CM Raw residuals", Location="southeast");
    hold off;


    nexttile
    hold on;
    plot(TIME,MeanArray-DM, ".", Color="#FF8243", LineWidth=1.5);
    box on;
    yline(0, '-', '\DeltaN=0',Color="#8C92AC" ,LineWidth=1.25);
    ylabel("\DeltaN");
    xlabel("t (time) - units");
    title(["C) Difference in population (\DeltaN) between \mu(N_i) values"," and discrete logistic growth per time unit;"]);
    legend("DM Raw residuals", Location="southeast");
    hold off;


    nexttile
    hold on;
    plot(TIME,MeanArray-FM, ".k", LineWidth=1.5);
    box on;
    yline(0, '-', '\DeltaN=0',Color="#8C92AC",LineWidth=1.25);
    ylabel("\DeltaN");
    xlabel("t (time) - units");
    title(["D) Difference in population (\DeltaN) between \mu(N_i) values"," and continous fitted to discrete logistic growth per time unit;"]);
    legend("FM Raw residuals", Location="southeast");
    hold off;
end