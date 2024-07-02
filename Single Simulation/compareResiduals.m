% This function plots the normal probabilty plot of the raw residuals of the iteration means wrt to the continuous model
% adding the NRMSE that the experimental iteration means score
% NRMSE is not enough if an analysis of residuals is not performed

function compareResiduals(ITERATIONS,ITERATIONS_TO_SHOW, MeanArray, CM)
    
    
    figure;
    tiledlayout(2,3)
    
    nexttile
    hold on;
    residuals_1 = MeanArray-CM;
    histogram(residuals_1(1:ITERATIONS_TO_SHOW), 20, 'Normalization','pdf');
    box on;
    title(["A.1) CM Histogram plot of the head ","(short-term) raw residuals;"],"time range: [t_0 - 2t* ("+ITERATIONS_TO_SHOW+")]");
    xlabel("CM Raw residuals (x)")
    ylabel("Frequency(x)");
    hold off;

    nexttile
    hold on;
    histogram(residuals_1, 20, 'Normalization','pdf');
    box on;
    title(["B.1) CM Histogram plot of the head+tail ","(long-term) raw residuals;"],"time range: [t_0 - t_{max} ("+ITERATIONS+")]");
    xlabel("CM Raw residuals (x)")
    ylabel("Frequency(x)");
    hold off;
    
    nexttile
    hold on;
    %histogram(residuals_1(ITERATIONS_TO_SHOW:end),20, 'Normalization','pdf');
    h3 = histfit(residuals_1(ITERATIONS_TO_SHOW:end),20);
    h3(2).Color = [.2 .2 .2];
    box on;
    title(["C.1) CM Histogram plot of the tail ","(steady-state only) raw residuals;"],"time range: [2t* - t_{max}]");
    xlabel("CM Raw residuals (x)")
    ylabel("Frequency(x)");
    hold off;

    nexttile
    hold on;
    n1 = normplot(residuals_1(1:ITERATIONS_TO_SHOW));
    props = get(n1,{'marker' 'linestyle' 'color'});
    %set(n1, 'color', "#29AB87");
    legend(["x<Q1 or x> Q3","Q1<x<Q3", "x"], Location="northwest");
    NRMSE_CM = goodnessOfFit(MeanArray(1:ITERATIONS_TO_SHOW)', CM(1:ITERATIONS_TO_SHOW)', 'NRMSE'); %
    xlabel("CM Raw residuals (x)")
    ylabel("Probability(x)")
    title("A.2) CM Normal probability plot;", ["NRMSE: "+NRMSE_CM+";","time range: [t_0 - 2t* ("+ITERATIONS_TO_SHOW+")];"]);
    box on;
    hold off;

    nexttile
    hold on;
    n1 = normplot(residuals_1);
    props = get(n1,{'marker' 'linestyle' 'color'});
    %set(n1, 'color', "#29AB87")
    legend(["x<Q1 or x> Q3","Q1<x<Q3", "x"], Location="northwest");
    NRMSE_CM = goodnessOfFit(MeanArray', CM', 'NRMSE'); %
    xlabel("CM Raw residuals (x)")
    ylabel("Probability(x)")
    title("B.2) CM Normal probability plot;", ["NRMSE: "+NRMSE_CM+";","time range: [t_0 - t_{max} ("+ITERATIONS+")];"]);
    box on;
    hold off;

    nexttile
    hold on;
    n1 = normplot(residuals_1(ITERATIONS_TO_SHOW:end));
    props = get(n1,{'marker' 'linestyle' 'color'});
    %set(n1, 'color', "#29AB87");
    legend(["x<Q1 or x> Q3","Q1<x<Q3", "x"], Location="northwest");
    NRMSE_CM = goodnessOfFit(MeanArray(ITERATIONS_TO_SHOW:end)', CM(ITERATIONS_TO_SHOW:end)', 'NRMSE'); %
    xlabel("CM Raw residuals (x)")
    ylabel("Probability(x)")
    title("C.2) CM Normal probability plot;", ["NRMSE: "+NRMSE_CM+";","time range: [2t* - t_{max}];"]);
    box on;
    hold off;

%%


    

end