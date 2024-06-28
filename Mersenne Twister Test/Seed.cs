using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MersenneTwistertest
{
    internal class Seed
    {
        //private static int currentSeed = 1;
        public static int GetNextSeed()
        {
            //return currentSeed++;
            return Prime.GetNextPrime();
        }
    }

    internal class Prime
    {
        private static int currentPrime = 1;
        public static int GetNextPrime()
        {
            int tmp = currentPrime;
            double sqrt;
            bool trovato = false;

            while (!trovato)
            {
                tmp += 2;

                sqrt = Math.Sqrt(tmp);

                trovato = true;
                //Controllo se il numero è primo
                for (int i = 3; i <= sqrt && trovato; i += 2)
                    if (tmp % i == 0)
                        trovato = false;

                if (trovato)
                    currentPrime = tmp;
            }

            return currentPrime;
        }
    }
}
