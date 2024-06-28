% This function plots the normal probabilty plot of the raw residuals of the iteration means wrt to the continuous, discrete and fitted models
% adding the NRMSE that the experimental iteration means score for each of the models
% NRMSE is not enough if an analysis of residuals is not performed
% The long-term beahviour is not included to adjust for heteroskedasticity



%%
% lbqtest(residuals_1,"Lags",ceil(log(ITERATIONS_TO_SHOW)))
% The value of the Lags argument L affects the power of the test.
% If L is too small, the test does not detect high-order autocorrelations.
% If L is too large, the test loses power when a significant correlation at one lag is washed out by insignificant correlations at other lags.
% Box, Jenkins, and Reinsel suggest the default setting Lags=min[20,T-1] [1].
% Tsay cites simulation evidence showing better test power performance when L is approximately log(T) [5].
% lbqtest does not directly test for serial dependencies other than autocorrelation. 
% However, you can use it to identify conditional heteroscedasticity (ARCH effects) by testing squared residuals [4].
% Engle's test assesses the significance of ARCH effects directly. For details, see archtest.




function compareResidualsModels(ITERATIONS_TO_SHOW, MeanArray, CM, DM, FM, NRMSE_CM,NRMSE_DM,NRMSE_FM)
    
    figure;
    tiledlayout(2,3)

    nexttile
    hold on;
    residuals_1 = MeanArray-CM;
    %archtest(residuals_1)
    %lbqtest(residuals_1,"Lags",ceil(log(ITERATIONS_TO_SHOW)))
    h1 = histogram(residuals_1(1:ITERATIONS_TO_SHOW), 'Normalization','pdf',FaceColor="#29AB87");
    box on;
    title("CM Histogram plot of the raw residuals;","time range: [t0 - 2t* (" + ITERATIONS_TO_SHOW+")]");
    xlabel("CM Raw residuals (x)")
    ylabel("Frequency(x)");
    hold off;

    nexttile
    hold on;
    residuals_2 = MeanArray-DM;
    %archtest(residuals_2)
    %lbqtest(residuals_2,"Lags", ceil(log(ITERATIONS_TO_SHOW)))
    h2 = histogram(residuals_2(1:ITERATIONS_TO_SHOW), 'Normalization','pdf', FaceColor="#FF8243");
    title("DM Histogram plot of the raw residuals;","time range: [t0 - 2t* (" + ITERATIONS_TO_SHOW+")]");
    xlabel("DM Raw residuals (x)")
    ylabel("Frequency(x)");
    box on;
    hold off;

    nexttile
    hold on;
    residuals_3 = MeanArray-FM;
    %archtest(residuals_3)
    %lbqtest(residuals_3,"Lags",ceil(log(ITERATIONS_TO_SHOW)))
    h3 = histogram(residuals_3(1:ITERATIONS_TO_SHOW), 'Normalization','pdf',FaceColor="k" );
    title("FM Histogram plot of the raw residuals;","time range: [t0 - 2t* (" + ITERATIONS_TO_SHOW+")]");
    xlabel("FM Raw residuals (x)")
    ylabel("Frequency(x)");
    box on;
    hold off;
    
    nexttile
    hold on;
    n1 = normplot(residuals_1(1:ITERATIONS_TO_SHOW));
    props = get(n1,{'marker' 'linestyle' 'color'});
    set(n1, 'color', "#29AB87");
    %qqplot(residuals_1(1:ITERATIONS_TO_SHOW));
    legend(["x<Q1 or x> Q3","Q1<x<Q3", "x"], Location="northwest");
    xlabel("CM Raw residuals (x)")
    ylabel("Probability(x)")
    title("CM Normal probability plot; NRMSE: "+NRMSE_CM+";","time range: [t0 - 2t* (" + ITERATIONS_TO_SHOW+")];");
    box on;
    hold off;

    nexttile
    hold on;
    n2 = normplot(residuals_2(1:ITERATIONS_TO_SHOW));
    props = get(n2,{'marker' 'linestyle' 'color'});
    set(n2, 'color', "#FF8243");
    %qqplot(residuals_2(1:ITERATIONS_TO_SHOW));
    legend(["x<Q1 or x> Q3","Q1<x<Q3", "x"],Location="northwest");
    xlabel("DM Raw residuals (x)")
    ylabel("Probability(x)")
    title("DM Normal probability plot; NRMSE: "+NRMSE_DM+";","time range: [t0 - 2t* (" + ITERATIONS_TO_SHOW+")];");
    box on;
    hold off;

    nexttile
    hold on;
    n3 = normplot(residuals_3(1:ITERATIONS_TO_SHOW));
    %qqplot(residuals_3(1:ITERATIONS_TO_SHOW));
    props = get(n3,{'marker' 'linestyle' 'color'});
    set(n3, 'color', "k");
    legend(["x<Q1 or x> Q3","Q1<x<Q3", "x"], Location="northwest");
    xlabel("FM Raw residuals (x)")
    ylabel("Probability(x)")
    title("FM Normal probability plot;  NRMSE: "+NRMSE_FM+";","time range: [t0 - 2t* (" + ITERATIONS_TO_SHOW+")];");
    box on;
    hold off;

    

end