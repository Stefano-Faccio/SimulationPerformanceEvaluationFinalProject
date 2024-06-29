function [Gillespie_Model_Times, Gillespie_Model_Values] = gillespie(START_POPULATION_, GROWTH_RATE_, CARRYING_CAPACITY_, CROWDING_COEFFICIENT_, ITERATIONS_GILLEPSIE_, NSIMULATIONS_GILLEPSIE_)
    filename = "gillespie_datasave.mat";
    % Se ho già l'esecuzione salvata, non la ricomputo
    compute_algoritm = true;
    % Controllo se il file esiste
    if isfile(filename)
        % Carico il file
        load(filename);
        % Controllo se le variabili sono state definite
        if exist('Gillespie_Model','var') && exist("START_POPULATION",'var') && exist("GROWTH_RATE",'var') && exist("CARRYING_CAPACITY",'var') && exist("CROWDING_COEFFICIENT",'var') && exist("ITERATIONS_GILLEPSIE",'var') && exist("NSIMULATIONS_GILLEPSIE",'var')
             % Controllo se i parametri sono uguali
            if START_POPULATION == START_POPULATION_ && GROWTH_RATE == GROWTH_RATE_ && CARRYING_CAPACITY == CARRYING_CAPACITY_ && CROWDING_COEFFICIENT == CROWDING_COEFFICIENT_ && ITERATIONS_GILLEPSIE == ITERATIONS_GILLEPSIE_ && NSIMULATIONS_GILLEPSIE == NSIMULATIONS_GILLEPSIE_
                % Ho l'esecuzione salvata
                compute_algoritm = false;
                fprintf("Gillespie already computed \n");
            end
        end
    end

    % Salvo/Sovrascrivo i parametri 
    START_POPULATION = START_POPULATION_;
    GROWTH_RATE = GROWTH_RATE_;
    CARRYING_CAPACITY = CARRYING_CAPACITY_;
    CROWDING_COEFFICIENT = CROWDING_COEFFICIENT_;
    ITERATIONS_GILLEPSIE = ITERATIONS_GILLEPSIE_;
    NSIMULATIONS_GILLEPSIE = NSIMULATIONS_GILLEPSIE_;
    
    % Se devo calcolare l'algoritmo
    if compute_algoritm == true
        [Gillespie_Model_Times, Gillespie_Model_Values] = Compute_Multiple_Simulations(START_POPULATION, GROWTH_RATE, CARRYING_CAPACITY, CROWDING_COEFFICIENT, ITERATIONS_GILLEPSIE, NSIMULATIONS_GILLEPSIE);
        Gillespie_Model = [Gillespie_Model_Times; Gillespie_Model_Values];
        %Salvo il modello e tutti i parametri
        save(filename, 'Gillespie_Model', 'START_POPULATION', 'GROWTH_RATE', 'CARRYING_CAPACITY', 'CROWDING_COEFFICIENT', 'ITERATIONS_GILLEPSIE', 'NSIMULATIONS_GILLEPSIE');
    end    

    Gillespie_Model_Times = Gillespie_Model(1, :);
    Gillespie_Model_Values = Gillespie_Model(2, :);
end

function [Gillespie_Model_Times, Gillespie_Model_Values] = Compute_Multiple_Simulations(START_POPULATION, GROWTH_RATE, CARRYING_CAPACITY, CROWDING_COEFFICIENT, ITERATIONS_GILLEPSIE, NSIMULATIONS_GILLEPSIE)
    tmp_array_times = zeros(NSIMULATIONS_GILLEPSIE, ITERATIONS_GILLEPSIE);
    tmp_array_dt = zeros(NSIMULATIONS_GILLEPSIE, ITERATIONS_GILLEPSIE);
    tmp_array_values = zeros(NSIMULATIONS_GILLEPSIE, ITERATIONS_GILLEPSIE);
    Gillespie_Model_Values = zeros(1, ITERATIONS_GILLEPSIE);
    Gillespie_Model_Times = zeros(1, ITERATIONS_GILLEPSIE);

    %Puliso i vecchi seed
    clear seed;

    for i = 1:NSIMULATIONS_GILLEPSIE
        SEED = seed();
        [times, dt, values] = Execute_Gillespie_Algorithm(START_POPULATION, GROWTH_RATE, CARRYING_CAPACITY, CROWDING_COEFFICIENT, ITERATIONS_GILLEPSIE, SEED);
        tmp_array_times(i, :) = times;
        tmp_array_dt(i, :) = dt;
        tmp_array_values(i, :) = values;
    end

    %Effettuo la media
    parfor i = 1:ITERATIONS_GILLEPSIE
        Gillespie_Model_Values(i) = sum(tmp_array_values(:, i) .* tmp_array_dt(:, i)) ./ sum(tmp_array_dt(:, i));
        Gillespie_Model_Times(i) = mean(tmp_array_times(:, i));
    end
end


function [Time, Dt, Population] = Execute_Gillespie_Algorithm(START_POPULATION, GROWTH_RATE, CARRYING_CAPACITY, CROWDING_COEFFICIENT, ITERATIONS, SEED)
    rng(SEED)
    Population = zeros(1, ITERATIONS);
    Population(1) = START_POPULATION;
    Time = zeros(1, ITERATIONS);
    Time(1) = 1;
    Dt = zeros(1, ITERATIONS);
    Dt(1) = 1;
    %Genero i numeri casuali
    random_numbers = rand(1, ITERATIONS);

    for i = 2:ITERATIONS
        %Calcolo i tassi
        growth_rate = GROWTH_RATE * Population(i-1);
        death_rate = Population(i-1) * Population(i-1) * CROWDING_COEFFICIENT;
        %Calcolo il nuovo tempo di arrivo campionando una distribuzione esponenziale
        tau = exprnd(1/(growth_rate + death_rate));
        %Scelgo l'evento
        if random_numbers(i) * (growth_rate + death_rate) < growth_rate
            Population(i) = Population(i-1) + 1;
        else
            Population(i) = Population(i-1) - 1;
        end
        Time(i) = Time(i-1) + tau;
        Dt(i) = tau;    
    end
end