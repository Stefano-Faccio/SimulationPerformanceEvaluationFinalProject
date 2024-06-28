%% Output analysis main

rng(1,"twister");

%% Theory of the logistic growth model

%% 
% Plot theoretical graphs for discrete and continuous growth (unbounded)
t = 1:1:50;
N_0 = 5;
%k =log(1+r);
compareExpGrowths(1,0.6931,N_0,t)
compareExpGrowths(0.5,0.4055,N_0,t)
compareExpGrowths(0.1,0.0953,N_0,t)
% Closest approximation of continuous growth by discrete growth
compareExpGrowths(0.05,0.0488,N_0,t)

%%
% PLot slope field (SF) for logistic equation or logistic curve (Curve)
tmax = 100;
Nmax = 60;
Nmin = -10;
N_0 = 4;
k = 0.05;
C = 0.001;

plotLogSForCurve(tmax,Nmax,Nmin,k,C,N_0,"curve");
%plotLogSForCurve(tmax,Nmax,Nmin,k,C,N_0,"sf")

%% 
% Phase plot for logistic equation
L=k/C;
t=0:1:100;
xlimit=L+5;
phasePlot(k,C,N_0,t,xlimit);

%%
% Comparison of continuous and discrete plots for theoretical logistic
% growth (bounded)
% inflection time formula
coeff =(L/N_0)-1;
tmax=400;
inflection_t = ceil((-1/k)*log(1/coeff));
compareLogGrowths(k,N_0,L,inflection_t, tmax);


%% Simulation Output data load & formatting

clear;
close all;
clc;

rng(1,"twister");
path_header = 'header.txt';
path_data = 'data.txt';

% read header
my_header = readtable(path_header);

NSIMULATIONS = my_header.(1);
ITERATIONS = my_header.(2);
START_POPULATION = my_header.(3);
CROWDING_COEFFICIENT = my_header.(4);
REPRODUCTION_PROBABILITY = my_header.(5);
DEATH_PROBABILITY = my_header.(6);
GROWTH_RATE = REPRODUCTION_PROBABILITY - DEATH_PROBABILITY;
CARRYING_CAPACITY = GROWTH_RATE/CROWDING_COEFFICIENT;
% inflection time
INFLECTION_TIME = ceil(log((CARRYING_CAPACITY - START_POPULATION)/START_POPULATION)/GROWTH_RATE);
ITERATIONS_TO_SHOW = 2*INFLECTION_TIME;
INFLECTION_POPULATION = CARRYING_CAPACITY/2;
TIME = 0:1:ITERATIONS-1;

% System (with chosen parameters) output data
% Table: simulations x iterations (10000 x 501)
% Each column contains all population values at the same iteration (time)
all_my_data = readtable(path_data);

% Table transpose: iterations x simulations
% Each column contains a whole simulation 
all_my_data_t = rows2vars(all_my_data);
all_my_data_t = all_my_data_t(:,2:end);

%%

%% Theoretical assessment of the logistic growth model corresponding to the simulation parameter setting

% Fitting of continuous model to discrete model of logistic growth
% in order to adjust for the constitutive difference between the two.

% Discrete model (x:N -> y:R)
discrete_model_real = zeros(1,ITERATIONS);
discrete_model_real(1) = START_POPULATION;
for i = 2:ITERATIONS
    discrete_model_real(i) = discrete_model_real(i-1) + (discrete_model_real(i-1)*GROWTH_RATE)*(1 - discrete_model_real(i-1)/CARRYING_CAPACITY);
end

% Continuous model (x:R -> y:R) 
continuous_model = @(b,x) (b(1) * START_POPULATION) ./ ( (b(1) - START_POPULATION) .* exp((-b(2)) .* x) + START_POPULATION );
continuous_population =  continuous_model([CARRYING_CAPACITY GROWTH_RATE],TIME);


% Continuous model (x:R -> y:R) fitted on discrete model (x:N -> y:R)
% is a continuous fitted on discrete model (x:R -> y:R)
fitted_continuous_model = fitnlm(0:ITERATIONS-1, discrete_model_real(1:ITERATIONS), continuous_model, [4000, 0.04]);

FITTED_POPULATION = fitted_continuous_model.Fitted';
FITTED_CARRYING_CAPACITY = table2array(fitted_continuous_model.Coefficients(1,1));
FITTED_GROWTH_RATE = table2array(fitted_continuous_model.Coefficients(2,1));
FITTED_RMSE = fitted_continuous_model.RMSE;
FITTED_NRMSE = goodnessOfFit(FITTED_POPULATION', continuous_population', 'NRMSE'); % 0.0173

% What are the constitutive differences between these three models?
compareLogFittedGrowths(TIME, continuous_population, FITTED_POPULATION, discrete_model_real, GROWTH_RATE, FITTED_GROWTH_RATE, CARRYING_CAPACITY, FITTED_CARRYING_CAPACITY, START_POPULATION, INFLECTION_TIME, FITTED_NRMSE)

%% Simulation

colors = ["#C0C0C0" "#E6194B" "#008080" "#3CB44B" "#FFE119" "#4363D8" "#F58231" "#911EB4" "#46F0F0" "#F032E6" "#BCF60C" "#FABEBE" "#42D4F4"  "#AAFFC3" "#A9A9A9" "#DCBEFF" "#473A4E"]; 

% qualitative evaluation (all iterations) 
% - simulation means
% - Grand mean of the simulation means -> Simulation grand mean
[simulationGrandMean, simulationMean]  = plotLogSimulation(all_my_data_t, NSIMULATIONS , ITERATIONS, ITERATIONS, 0, colors, "", INFLECTION_POPULATION, INFLECTION_TIME);

% qualitative evaluation (for a chosen number of first n iterations) 
% iteration cut at 2* inflection time

[nSimulationGrandMean, nSimulationMean]  = plotLogSimulation(all_my_data_t, NSIMULATIONS ,ITERATIONS, ITERATIONS_TO_SHOW, 0, colors, "", INFLECTION_POPULATION, INFLECTION_TIME);

%% Iteration

% Plot of the experimental logistic growths against the theoretical one (for all iterations) 
% - Iteration means 
% - Grand mean of the iteration means -> Iteration grand mean

exponential_population = START_POPULATION*exp(GROWTH_RATE.*TIME);
ymin=0;
ymax=CARRYING_CAPACITY+400;
[iterationGrandMean,iterationMean, iterationVar]  = plotLogIteration(all_my_data_t, exponential_population, continuous_population, NSIMULATIONS, ITERATIONS, ITERATIONS, 0, colors,ymin,ymax, CROWDING_COEFFICIENT,REPRODUCTION_PROBABILITY,DEATH_PROBABILITY,START_POPULATION,INFLECTION_POPULATION, INFLECTION_TIME);

% Plot of the experimental logistic growths against the theoretical one (for first n iterations)
% iteration cut at 2* inflection time
[nIterationGrandMean,nIterationMean]  = plotLogIteration(all_my_data_t, exponential_population, continuous_population, NSIMULATIONS, ITERATIONS, ITERATIONS_TO_SHOW, 0, colors,ymin,ymax, CROWDING_COEFFICIENT,REPRODUCTION_PROBABILITY,DEATH_PROBABILITY,START_POPULATION, INFLECTION_POPULATION, INFLECTION_TIME);

% Iteration grand mean = Simulation grand mean

% Matlab built-in Bootstrap method to obtain 95% CI for each iteration mean
ci95_iterationMean = bootci(NSIMULATIONS, {@mean, table2array(all_my_data)});
ci95_iterationMean_down = iterationMean - ci95_iterationMean(1, :);
ci95_iterationMean_up = ci95_iterationMean(2, :) - iterationMean;

% Matlab built-in Bootstrap method to obtain 95% CI for each iteration
% variance
ci95_iterationVar = bootci(NSIMULATIONS, {@var, table2array(all_my_data)});
ci95_iterationVar_down = iterationVar - ci95_iterationVar(1, :);
ci95_iterationVar_up = ci95_iterationVar(2, :) - iterationVar;

%%
% Compare iteration mean and variance with the iteration mean and
% variance cut before long term behaviour to assess heterosckedasticity (unequal variance)

tiledlayout(1,2)
nexttile
b1 = boxchart([iterationMean', iterationVar'],'Notch','on', 'MarkerStyle','.', 'JitterOutliers','on','BoxFaceColor', "k",'MarkerColor', "#6E7F80");
ax = gca;
xticklabels(ax,{"\mu(N_i)", "\sigma^2(N_i)"});
fontsize(ax, scale=1.2);
xlabel(["Population (N) values"," time range: t_0 - t_{max}"])
title("A) Box plot of iteration means \mu(N_i) and variances sigma^2(N_i)", "Long-term behaviour included")
box on;

iterationMeanOutliers = isoutlier(iterationMean, 'quartiles');
nMeanOutliers = histcounts(iterationMeanOutliers);
disp("The number of outliers for the iteration means is " + nMeanOutliers(1,2) + " out of "+ ITERATIONS+ " data points: " + (nMeanOutliers(1,2)/ITERATIONS).*100 + "%");

iterationVarOutliers = isoutlier(iterationVar, 'quartiles');
nVarOutliers = histcounts(iterationVarOutliers);
disp("The number of outliers for the iteration variances is " + nVarOutliers(1,2) + " out of "+ ITERATIONS+ " data points: " + (nVarOutliers(1,2)/ITERATIONS).*100 + "%");

nexttile
b2 = boxchart([iterationMean(1:ITERATIONS_TO_SHOW)', iterationVar(1:ITERATIONS_TO_SHOW)'],'Notch','on','MarkerStyle','.', 'BoxFaceColor', "k" , 'MarkerColor', "#6E7F80");
ax = gca;
xticklabels(ax,{"\mu(N_i)", "\sigma^2(N_i)"});
xlabel(["Population (N) values"," time range: t_0 - 2t*"])
title("B) Box plot of iteration means \mu(N_i) and variances sigma^2(N_i)", "Long-term behaviour excluded")
fontsize(ax, scale=1.2);
box on;

%%
%%
compareMeansModels(TIME, iterationMean,ci95_iterationMean_down ,ci95_iterationMean_down, continuous_population,...
    discrete_model_real, FITTED_POPULATION)

%%
%% 
% Analysis of the head, where normality can be tested

NRMSE_CM = goodnessOfFit(iterationMean(1:ITERATIONS_TO_SHOW)', continuous_population(1:ITERATIONS_TO_SHOW)', 'NRMSE'); %
NRMSE_DM = goodnessOfFit(iterationMean(1:ITERATIONS_TO_SHOW)', discrete_model_real(1:ITERATIONS_TO_SHOW)', 'NRMSE'); %
NRMSE_FM = goodnessOfFit(iterationMean(1:ITERATIONS_TO_SHOW)', FITTED_POPULATION(1:ITERATIONS_TO_SHOW)', 'NRMSE'); %


%%
%iterationMean = table2array(all_my_data(242,:));

compareResidualsModels(ITERATIONS_TO_SHOW,iterationMean,continuous_population,discrete_model_real,FITTED_POPULATION, ...
    NRMSE_CM,NRMSE_DM,NRMSE_FM)
%%
% Which of the 3 models fits the iteration means better? theory vs practice

% CM: continuous model
% DM: discrete model (best candidate, but not continuous)
% FM: continuous model fitted on discrete

[resCM, trueCM, falseCM, stat_rangesCM] = isInCI(ci95_iterationMean, continuous_population, INFLECTION_TIME);
[resDM, trueDM, falseDM, stat_rangesDM]= isInCI(ci95_iterationMean, discrete_model_real, INFLECTION_TIME);
[resFM, trueFM, falseFM, stat_rangesFM]= isInCI(ci95_iterationMean, FITTED_POPULATION, INFLECTION_TIME);

%%
%tiledlayout("vertical")
figure;
hold on;
tl = tiledlayout(2,2);
title(tl,["Number of model population values that (do not) fall into the corresponding \mu(N_i) 95% CIs", ...
    '[ Population values belonging to \mu(N_i) 95% CIs: True; Otherwise: False ]']);
nexttile
plotBarCI(["A) Global comparison of the three models: ","CM (continuous), DM (discrete) and FM (continuous fitted on discrete)"], ...
        "Number of true and false population (N) values per logistic growth model", { 'CM','DM','FM', '', '','', '',}, ...
        [trueCM, falseCM; trueDM, falseDM; trueFM, falseFM]);
nexttile
plotBarCI(["B) Comparison within the CM model;", "t* (inflection time): "+INFLECTION_TIME+";"], ...
        "Number of true and false population (N) values per time range", {'t_{0} - t*','t* - 2t*','2t* - 3t*', '3t* - 4t*', '4t* - t_{end}', "",''}, ...
        stat_rangesCM');
nexttile
plotBarCI(["C) Comparison within the DM model;", "t* (inflection time): "+INFLECTION_TIME+";" ], ...
        "Number of true and false population (N) values per time range", {'t_{0} - t*','t* - 2t*','2t* - 3t*', '3t* - 4t*', '4t* - t_{end}',"", ''}, ...
        stat_rangesDM');
nexttile
plotBarCI(["D) Comparison within the FM model;", "t* (inflection time): "+INFLECTION_TIME+";" ], ...
        "Number of true and false population (N) values per time range", {'t_{0} - t*','t* - 2t*','2t* - 3t*', '3t* - 4t*', '4t* - t_{end}',"", ''}, ...
        stat_rangesFM');
hold off;



%%