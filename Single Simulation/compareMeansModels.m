% This function plots the raw residuals of the iteration means wrt to the
% continuous and discrete models
% The long-term beahviour is included


function compareMeansModels(TIME, INFLECTION_TIME, MeanArray, MeanArrayCIs, upCI, downCI, CM, DM)

    % Which of the 2 models fits the iteration means better? theory vs practice

    % CM: continuous model
    % DM: discrete model (best candidate, but not continuous)
    [resCM, trueCM, falseCM, stat_rangesCM] = isInCI(MeanArrayCIs, CM, INFLECTION_TIME);
    [resDM, trueDM, falseDM, stat_rangesDM]= isInCI(MeanArrayCIs, DM, INFLECTION_TIME);
        
    figure;
    tl = tiledlayout(2,3);
    title(tl, ["A) B) C) Comparison of CM and DM fitting of \mu(N_i) values through the analysis of raw residuals", ...
        "D) E) F) Number of model population values that (do not) fall into the corresponding \mu(N_i) 95% CIs", ...
        "[ Population values belonging to \mu(N_i) 95% CIs: True; Otherwise: False ]"])
    
    nexttile
    hold on;
    errorbar(TIME, MeanArray, downCI, upCI, ".");
    plot(TIME,CM, Color="#29AB87");
    plot(TIME,DM, ".", Color="#FF8243");
    xlabel("time")
    ylabel("\mu(N_i)")
    legend ("\mu(N_i) 95% CIs", "CM: continuous model", "DM: discrete model", Location="southeast")
    title(["A) Big picture of the CM and DM fitting","of the experimental \mu(N_i) values"]);
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
    plotBarCI(["D) Global comparison of the CM (continuous)","and DM (discrete) models"], ...
            "Number of true and false population (N) values per logistic growth model", { 'CM','DM','FM', '', '','', '',}, ...
            [trueCM, falseCM; trueDM, falseDM]);
    nexttile
    plotBarCI(["E) Comparison within the CM model;", "t* (inflection time): "+INFLECTION_TIME+";"], ...
            "Number of true and false population (N) values per time range", {'t_{0} - t*','t* - 2t*','2t* - 3t*', '3t* - 4t*', '4t* - t_{end}', "",''}, ...
            stat_rangesCM');
    nexttile
    plotBarCI(["F) Comparison within the DM model;", "t* (inflection time): "+INFLECTION_TIME+";" ], ...
            "Number of true and false population (N) values per time range", {'t_{0} - t*','t* - 2t*','2t* - 3t*', '3t* - 4t*', '4t* - t_{end}',"", ''}, ...
            stat_rangesDM');
    hold off;
end