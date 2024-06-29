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

% Discrete model (x:N -> y:R)
discrete_model_real = zeros(1,ITERATIONS);
discrete_model_real(1) = START_POPULATION;
for i = 2:ITERATIONS
    discrete_model_real(i) = discrete_model_real(i-1) + (discrete_model_real(i-1)*GROWTH_RATE)*(1 - discrete_model_real(i-1)/CARRYING_CAPACITY);
end

% Continuous model (x:R -> y:R) 
continuous_model = @(b,x) (b(1) * START_POPULATION) ./ ( (b(1) - START_POPULATION) .* exp((-b(2)) .* x) + START_POPULATION );
continuous_population =  continuous_model([CARRYING_CAPACITY GROWTH_RATE],TIME);

% What are the constitutive differences between these 2 models?
compareLogFittedGrowths(TIME, continuous_population, discrete_model_real, GROWTH_RATE, CARRYING_CAPACITY, START_POPULATION, INFLECTION_TIME)

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

%figure;
%tiledlayout(2,1)
%nexttile
[iterationGrandMean,iterationMean, iterationVar]  = plotLogIteration(all_my_data_t, exponential_population, continuous_population, NSIMULATIONS, ITERATIONS, ITERATIONS, 0, colors,ymin,ymax, CROWDING_COEFFICIENT,REPRODUCTION_PROBABILITY,DEATH_PROBABILITY,START_POPULATION,INFLECTION_POPULATION, INFLECTION_TIME);

%nexttile
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
% variance cut before long term behaviour

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
% Compare residuals between iteration means and continuous (CM) model
% Compare residuals between iteration means and discrete (DM) model
% Assess heteroskedasticity of residuals (unequal variance) between head
% and tail
% Check which model between CM and DM fits better in the 95% CIs of the
% corresponding iteraion means
compareMeansModels(TIME, INFLECTION_TIME, iterationMean, ci95_iterationMean, ci95_iterationMean_down ,ci95_iterationMean_down, continuous_population,discrete_model_real)
%% 

% Analysis of the head, trying to remove heteroskedasticity, where normality of residuals can be tested
% Assess the non-normality of residuals
% consistent with the costitutive difference between discrete and
% continuous model

NRMSE_CM = goodnessOfFit(iterationMean(1:ITERATIONS_TO_SHOW)', continuous_population(1:ITERATIONS_TO_SHOW)', 'NRMSE'); %
NRMSE_DM = goodnessOfFit(iterationMean(1:ITERATIONS_TO_SHOW)', discrete_model_real(1:ITERATIONS_TO_SHOW)', 'NRMSE'); %

% Conclude that a linear or non-linear fitting is pointless? the
% assumptions do not hold. We already have theoretical curve and possibly
% line.

%%

%iterationMean = table2array(all_my_data(242,:));
compareResidualsModels(ITERATIONS_TO_SHOW,iterationMean,continuous_population,discrete_model_real,NRMSE_CM,NRMSE_DM)

%%
% How does the constitutive difference impact stochastic simulations?
% Is our simulation the only one that behaves like this?
% Let us implement the state of the art Gillespie algorithm for logistic
% growth simulation

NSIMULATIONS_GILLEPSIE = 1000;
ITERATIONS_GILLEPSIE = 200000;

[Gillespie_Model_Times, Gillespie_Model_Values] = gillespie(START_POPULATION, GROWTH_RATE, CARRYING_CAPACITY, CROWDING_COEFFICIENT, ITERATIONS_GILLEPSIE, NSIMULATIONS_GILLEPSIE);
Gillespie_Model = [Gillespie_Model_Times; Gillespie_Model_Values];
fprintf('DONE \n');

%%

gillespie_continuous_population =  continuous_model([CARRYING_CAPACITY GROWTH_RATE],Gillespie_Model_Times-1);

figure;
tl = tiledlayout(2,1);
nexttile
hold on;
box on;
plot(Gillespie_Model_Times-1,Gillespie_Model_Values, ".", Color="#EC3B83");
plot(Gillespie_Model_Times-1,gillespie_continuous_population, Color="#29AB87", LineWidth=2);
xlabel("time")
ylabel("\mu(N_i)")
axis tight;
hold off;

nexttile
plot(Gillespie_Model_Times,Gillespie_Model_Values-gillespie_continuous_population, ".",Color="#29AB87", LineWidth=1.5);
box on;
yline(0, '-', '\DeltaN=0',Color="#8C92AC",LineWidth=1.25);
ylabel("\DeltaN");
xlabel("t (time) - units");
title(["B) Difference in population (\DeltaN) between Gillespie \mu(N_i) values"," and continuous logistic growth per time unit;"]);
legend("CM Raw residuals", Location="southeast");
axis tight;

%%