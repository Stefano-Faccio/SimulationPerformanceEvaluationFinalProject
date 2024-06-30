using MathNet.Numerics.Random;
using System;
using System.Globalization;

namespace MersenneTwistertest
{
    internal class Program
    {
        static string path = "../../../data.txt";
        static int NSEED = 10;
        static int NSAMPLE = 1000000;
        static void Main(string[] args)
        {
            Thread.CurrentThread.CurrentCulture = CultureInfo.InvariantCulture;
            if (!System.Environment.OSVersion.Platform.ToString().ToLower().Contains("win"))
                path = "data.txt";

            //Se ho dei parametri validi da riga di comando
            if(args.Length == 2 && Int32.TryParse(args[0], out int nseed) && Int32.TryParse(args[1], out int nsampe)) 
            {
                NSEED = nseed;
                NSAMPLE = nsampe;

                Console.WriteLine($"N of seeds: {NSEED}, N of samples: {NSAMPLE}");
            }

            //Cancello e apro il file dove salvo i dati
            File.Delete(path);
            StreamWriter file = File.AppendText(path);

            //Sampo sul file i dati iniziali
            //file.WriteLine($"{NSEED} {NSAMPLE}");

            List<int> seeds = new(NSEED);
            List<Double[]> samples = new(NSEED);

            //Prendo i dati
            for (int i = 0; i < NSEED; i++)
            {
                //Prendo il seed
                seeds.Add(Prime.GetNextPrime());
                //Nuovo mersenne twister
                MersenneTwister mst = new(seeds[i]);
                //Campiono
                samples.Add(mst.NextDoubles(NSAMPLE));

                Console.Write(".");
            }

            //Stampo i dati a file
            //Prima tutti i seed
            file.WriteLine(string.Join(" ", seeds));
            for (int i = 0; i < NSAMPLE; i++)
            {
                string str = "";
                for(int u = 0; u < NSEED; u++)
                {
                    str += $"{samples[u][i]} ";
                }
                file.WriteLine(str);
                Console.Write(".");
            }

            file.Close();
        }
    }
}