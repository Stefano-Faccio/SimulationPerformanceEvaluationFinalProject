% This function compares theoretical continuous and discrete growth models
% with a continuous model fitted to the discrete model
% in order to see if its is possible to shorten the constitutive difference between continuous and
% discrete logistic growth and use this third option as a comparison curve
% for our stochastic simulation of discrete logistic growth.


function compareLogFittedGrowths(TIME, continuous_population, FITTED_POPULATION, discrete_model_real, GROWTH_RATE, FITTED_GROWTH_RATE, CARRYING_CAPACITY, FITTED_CARRYING_CAPACITY, START_POPULATION, INFLECTION_TIME,FITTED_NRMSE)


tl= tiledlayout(3,1);
title(tl,["Theoretical logistic growth models", "[Fitting the continuous model to the discrete model to shorten their constitutive difference]"]);
subtitle_ = ["Discrete = continuous growth rate (r = k): " + GROWTH_RATE + "; Fitted k: "+ FITTED_GROWTH_RATE + ";", ...
    "Carrying capacity (L): "+ CARRYING_CAPACITY + "; Fitted L: "+FITTED_CARRYING_CAPACITY + "; Fitted NRMSE: " + FITTED_NRMSE + ";", ...
    "Initial population (N_0): " + START_POPULATION + "; Time range: [" + 0 + " - " + TIME(end) + "]; Inflection time (t*): " + INFLECTION_TIME + ";"];
subtitle(tl,subtitle_);


%fontsize(tl, scale=1.4);

nexttile
hold on;
c_1 = plot(TIME,continuous_population,Color = "#29AB87", LineWidth=1.75);
cd_1= plot(TIME,FITTED_POPULATION, "k", LineWidth=1.5);
d_1 = plot(TIME,discrete_model_real, ".", Color="#FF8243", LineWidth=1.5);
leg = legend([c_1,cd_1,d_1], "Continuous", "Fitted", "Discrete");
leg.Location="southeast";
title(leg,'Logistic growth models')
ylabel("N (population) - units");
xlabel("t (time) - units");
title(["A) Big picture of the comparison between continuous (CM), discrete (DM) and continuous fitted on discrete (FM) logistic growth models"]);

box on;
%ax = gca;
%fontsize(ax, scale=1.4);
hold off;

nexttile
hold on;
plot(TIME,discrete_model_real-continuous_population, ".r", LineWidth=1.5);
box on;
yline(0, '-', '\DeltaN=0', Color="#8C92AC",LineWidth=1.25);
ylabel("\DeltaN");
xlabel("t (time) - units");
title(["B) Difference in population (\DeltaN) between DM and CM per time unit"]);
legend("Raw residuals", Location="southeast")
hold off;


nexttile
hold on;
plot(TIME,FITTED_POPULATION-continuous_population,".r", LineWidth=1.5);
box on;
yline(0, '-', '\DeltaN=0', Color="#8C92AC",LineWidth=1.25);
title(["C) Difference in population (\DeltaN) between FM and CM per time unit"]);
ylabel("\DeltaN");
xlabel("t (time) - units");
legend("Raw residuals", Location="southeast")
hold off;

%{
nexttile
hold on;
plot(TIME,FITTED_POPULATION-discrete_model_real,".r", LineWidth=1.5);
box on;
yline(0, '-', '\DeltaN=0', Color="#8C92AC",LineWidth=1.25);
ylabel("\DeltaN");
xlabel("t (time) - units");
title(["D) Difference in population (\DeltaN) between discrete"," and continuous fitted to discrete logistic growth per time unit"]);
hold off;
%}

end