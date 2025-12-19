#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <stdint.h>

#define M 100
#define N 100
#define MU 7.0
#define SIGMA 0.5
#define MIN_T 1
#define MAX_T 24
#define N_SIM 300
#define MAX_K 20 // nombre max de déclencheurs initiaux

/* Génération d'un entier depuis une normale N(mu,sigma^2) tronquée entre MIN_T et MAX_T */
int gaussian_truncated(double mu, double sigma) {
    double u1 = (rand() + 1.0) / (RAND_MAX + 1.0); // RAND_MAX est une constante propre au système d'exploitation associée à rand
    double u2 = (rand() + 1.0) / (RAND_MAX + 1.0); // u1 et u2 sont deux nb aléatoires entre ]0;1]
    double z = sqrt(-2.0 * log(u1)) * cos(2.0 * M_PI * u2); // transformation Box-Muller
    int val = (int)lround(mu + sigma * z); // val suit ~N(mu, sigma^2)
    if (val < MIN_T) val = MIN_T; // on clamp val pour qu'il reste [1;24]
    if (val > MAX_T) val = MAX_T;
    return val;
}

int main(void) {
    srand((unsigned)time(NULL)); // on utilise le temps en secondes depuis une certaine date comme noyau pour générer les nb aléatoires

    const long total_mats = (long)N_SIM * (long)MAX_K;
    const long elements_per_mat = (long)M * (long)N;

    FILE *f = fopen("../bin/thresholds_matrix.bin", "wb");
    if (!f) {
        perror("Erreur ouverture fichier thresholds_matrix.bin");
        return 1;
    }

    int32_t stress[M][N]; // matrice temporaire, remplie puis ajoutée d'un coup ds le fichier final, puis écrasée par la suivante

    for (long mat = 0; mat < total_mats; ++mat) {// boucle répétant ce qu'il y a dedans le (nb de matrice qu'on veut) fois
        /* Remplir la matrice avec tirages indépendants */
        for (int i = 0; i < M; ++i) {
            for (int j = 0; j < N; ++j) {
                stress[i][j] = (int32_t)gaussian_truncated(MU, SIGMA);
            }
        }

        /* Écrire la matrice (M*N int32) et vérifier */
        fwrite(stress, sizeof(int32_t), elements_per_mat, f);

    }

    printf("Nombre total de matrices thresholds écrites : %d\n", total_mats);
    fclose(f);
}
