% This function compares theoretical continuous and discrete growth models
% in order to check the constitutive difference between them,
% knowing that our stochastic simulation is of discrete logistic growth.

function compareLogFittedGrowths(TIME, continuous_population, discrete_model_real, GROWTH_RATE, CARRYING_CAPACITY, START_POPULATION, INFLECTION_TIME)


tl= tiledlayout(2,1);
title(tl,"Theoretical logistic growth models");
subtitle_ = ["Discrete = continuous growth rate (r = k): " + GROWTH_RATE + "; Carrying capacity (L): "+ CARRYING_CAPACITY + ";", ...
    "Initial population (N_0): " + START_POPULATION + "; Time range: [" + 0 + " - " + TIME(end) + "]; Inflection time (t*): " + INFLECTION_TIME + ";"];
subtitle(tl,subtitle_);


%fontsize(tl, scale=1.4);

nexttile
hold on;
c_1 = plot(TIME,continuous_population,Color = "#29AB87", LineWidth=1.75);
d_1 = plot(TIME,discrete_model_real, ".", Color="#FF8243", LineWidth=1.5);
leg = legend([c_1,d_1], "Continuous", "Discrete");
leg.Location="southeast";
title(leg,'Logistic growth models')
ylabel("N (population) - units");
xlabel("t (time) - units");
title("A) Big picture of the comparison between continuous (CM) and discrete (DM) logistic growth models");

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
title("B) Difference in population (\DeltaN) between DM and CM per time unit");
legend("Raw residuals", Location="southeast")
hold off;
end