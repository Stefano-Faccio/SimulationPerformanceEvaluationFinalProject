using System.Globalization;
using System;
using System.Collections;
using System.Linq;

namespace LogisticSimulation
{
    internal class Program
    {
        const int START_POPULATION = 50;
        const double CROWDING_COEFFICIENT = 0.0001;
        const double REPRODUCTION_PROBABILITY = 0.1;
        const double DEATH_PROBABILITY = 0.05;
        static int NSIMULATIONS = 10000;
        static int ITERATIONS = 300;

        static void Main(string[] args)
        {
            //Settaggi iniziali
            Thread.CurrentThread.CurrentCulture = CultureInfo.InvariantCulture; // Decimal numbers are printed with dot and not comma
            string path_data = "../../../data.txt";
            string path_header = "../../../header.txt";
            //if it is not a win environment i change the path_data where i save the data
            if (!Environment.OSVersion.Platform.ToString().Trim().ToLower().Contains("win"))
            {
                path_data = "data.txt";
                path_header = "header.txt";
            }

            //----------------------//

            //Simulazioni
            string[] results = MultipleSimulations();

            //----------------------//

            //Scrivo a file
            File.Delete(path_header);
            File.Delete(path_data);

            StreamWriter file_header = File.AppendText(path_header);
            StreamWriter file_data = File.AppendText(path_data);

            file_header.WriteLine("NSIMULATIONS ITERATIONS START_POPULATION CROWDING_COEFFICIENT REPRODUCTION_PROBABILITY DEATH_PROBABILITY");
            file_header.Write($"{NSIMULATIONS} {ITERATIONS+1} {START_POPULATION} {CROWDING_COEFFICIENT} {REPRODUCTION_PROBABILITY} {DEATH_PROBABILITY}");
            file_header.Close();

            foreach (var item in results)
                file_data.WriteLine(item);

            file_data.Close();
        }

        static string[] MultipleSimulations()
        {
            List<short>[] results = new List<short>[NSIMULATIONS];
            string[] _results = new string[NSIMULATIONS];

            Parallel.For(0, NSIMULATIONS, (i) =>
            {
                List<short> simulationInfo = new(ITERATIONS+1);
                Simulation sim = new(START_POPULATION, REPRODUCTION_PROBABILITY, DEATH_PROBABILITY, CROWDING_COEFFICIENT, Prime.GetNextPrime());

                simulationInfo.Add(START_POPULATION);
                for (int j = 1; j < ITERATIONS + 1; j++)
                    simulationInfo.Add(sim.NextIteration());

                results[i] = simulationInfo;
            });

            Console.WriteLine("Done");
            for (int i = 0; i < NSIMULATIONS; i++)
                _results[i] = String.Join(" ", results[i]);

            return _results;
        }
    }
}