clear;
close all;
clc;

%-----------------------------------------------------------------------------
%Read data
path_header = 'header.txt';
path_data = 'data.txt';

%Leggo l'header
my_header = readtable(path_header);

NSIMULATIONS = my_header.(1);
ITERATIONS = my_header.(2);
START_POPULATION = my_header.(3);
CROWDING_COEFFICIENT = my_header.(4);
REPRODUCTION_PROBABILITY = my_header.(5);
DEATH_PROBABILITY = my_header.(6);
GROWTH_RATE = REPRODUCTION_PROBABILITY - DEATH_PROBABILITY;
CARRYING_CAPACITY = GROWTH_RATE/CROWDING_COEFFICIENT;
ITERAZIONI_DA_VISUALIZZARE = 300;
NSIMULATIONS_GILLEPSIE = 10000;
ITERATIONS_GILLEPSIE = 200000;

%Leggo tutti i dati
all_my_data = readmatrix(path_data);

clear path_header path_data my_header;

fprintf('Computing Models... \n');
%-----------------------------------------------------------------------------
%Computo il modello discreto

Discrete_Model = zeros(1,ITERATIONS);
Discrete_Model(1) = START_POPULATION;
% Calcolo della crescita logistica discreta
for i = 2:ITERATIONS
    Discrete_Model(i) = Discrete_Model(i-1) + (Discrete_Model(i-1)*GROWTH_RATE)*(1 - Discrete_Model(i-1)/CARRYING_CAPACITY);
end

%-----------------------------------------------------------------------------
%Computo il modello teorico

Continuos_Model = @(x) (CARRYING_CAPACITY * START_POPULATION) ./ ( (CARRYING_CAPACITY - START_POPULATION) .* exp((-GROWTH_RATE) .* x) + START_POPULATION );

%-----------------------------------------------------------------------------
%Computo il modello stocastico Gillespie

[Gillespie_Model_Times, Gillespie_Model_Values] = gillespie(START_POPULATION, GROWTH_RATE, CARRYING_CAPACITY, CROWDING_COEFFICIENT, ITERATIONS_GILLEPSIE, NSIMULATIONS_GILLEPSIE);
Gillespie_Model = [Gillespie_Model_Times; Gillespie_Model_Values];
fprintf('DONE \n');

%-----------------------------------------------------------------------------
%Elaboro i dati: Media, Std, CI, ecc

Mean = mean(all_my_data, 1);
Std = std(all_my_data, 1);

%Controllo se ci sono simulazioni "morte"
numero_simulazioni_a_zero = 0;
for i = 1 : NSIMULATIONS
    if all_my_data(i, ITERATIONS) == 0
        numero_simulazioni_a_zero = numero_simulazioni_a_zero + 1;
    end
end

%Computo gli intervalli di confidenza con la normale
ci_norm = tinv(0.975, NSIMULATIONS-1) * (Std/sqrt(NSIMULATIONS));

Simulation = [Mean; ci_norm; ci_norm];

clear all_my_data i;

%-----------------------------------------------------------------------------
%Output

%Stampo un po' di info utili
fprintf("Numero di simulazioni: %d Numero di iterazioni %d\n", NSIMULATIONS, ITERATIONS);
fprintf("Popolazione iniziale: %d\n", START_POPULATION);
fprintf("Capacità di carico: %f\n", CARRYING_CAPACITY);
fprintf("Probabilità di riproduzione: %f\n", REPRODUCTION_PROBABILITY);
fprintf("Crescita: %f\n", GROWTH_RATE);
if numero_simulazioni_a_zero ~= 0
    fprintf("Numero di simulazioni a zero: %d\n", numero_simulazioni_a_zero);
end

Plot_With_Discrete(Simulation, Discrete_Model, Continuos_Model, Gillespie_Model, ITERATIONS, ITERAZIONI_DA_VISUALIZZARE);

%-----------------------------------------------------------------------------



function Plot_With_Discrete(Simulation, Discrete_Model, Continuos_Model, Gillespie_Model, ITERATIONS, ITERATIONS_TO_SHOW)

    figure
    subplot(2,1,1);
    hold on;
    grid on;
    
    %Discrete Model
    stairs(Discrete_Model, '- o', 'DisplayName', 'Modello discreto', LineWidth=0.5, MarkerFaceColor='#ff6666', MarkerEdgeColor='#ff6666', Color='#ffcccc');
    %Continuos Model
    %plot(1:ITERATIONS, Continuos_Model(1:ITERATIONS),'-k', 'DisplayName', 'Modello continuo', LineWidth=2);
    %Simulation
    %errorbar(1:ITERATIONS, Simulation(1, :), Simulation(2, :), Simulation(3, :), '.', 'DisplayName', 'Simulation', 'Color', '#0072BD');
    %Gillespie
    tims = Gillespie_Model(1, :);
    t_values = Gillespie_Model(2, :);
    plot(Gillespie_Model(1, :), Gillespie_Model(2, :), '-g', 'DisplayName', 'Modello Gillespie', LineWidth=2);

    xlabel('Iterazioni')
    ylabel('Popolazione')
    legend
    xlim([0 ITERATIONS_TO_SHOW]);
    hold off;

    subplot(2,1,2);
    hold on;
    grid on;
    %Smoot Gillespie_Model
    %errorbar(1:ITERATIONS, Discrete_Model-Continuos_Model, ci_down, ci_up, ".");
    plot(1:ITERATIONS, Simulation(1, :) - Discrete_Model, 'DisplayName', 'Errore Gillespie', LineWidth=2);
    xlabel("Time")
    ylabel("Error")
    xlim([0 ITERATIONS_TO_SHOW]);
    legend
    hold off;
end

%ci_norm = tinv(0.995, NSIMULATIONS-1) * (Std/sqrt(NSIMULATIONS));

%Con bootstrap
%{
fprintf('Computing Boostrap\n');
Options=statset(UseParallel=true);
ci99_bootstrap = bootci(1000, {@mean, all_my_data}, 'Alpha', 0.01, 'Options', Options);
ci99_bootstrap_down = Mean - ci99_bootstrap(1, :);
ci99_bootstrap_up = ci99_bootstrap(2, :) - Mean;
fprintf('[OK]\n');
%}

%{
Model = Continuos_Model;
foo_1 = goodnessOfFit((Mean(2:ITERATIONS))', (Model(2:ITERATIONS))', 'NRMSE');
foo_3 = sqrt(mean((Mean(2:ITERATIONS) - Model(2:ITERATIONS)).^2));
fprintf("NRMSE: %f\n", foo_1);
fprintf("foo3: %f\n", foo_3);
Model = Discrete_Model_Real;
foo_1 = goodnessOfFit((Mean(2:ITERATIONS))', (Model(2:ITERATIONS))', 'NRMSE');
foo_3 = sqrt(mean((Mean(2:ITERATIONS) - Model(2:ITERATIONS)).^2));
fprintf("NRMSE: %f\n", foo_1);
fprintf("foo3: %f\n", foo_3);
%}