#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define M 100
#define N 100
#define R 3
#define N_SIM 300
#define MAX_K 20

int main() {
    srand(time(NULL));

    FILE *f = fopen("../bin/state_matrix.bin", "wb");
    if (!f) {
        printf("Erreur : impossible d’ouvrir state_matrix.bin\n");
        return 1;
    }

    int state[M][N];
    double *p   = malloc(M*N*sizeof(double));
    double *cdf = malloc(M*N*sizeof(double));

    int mat_index = 0;

    for (int k = 1; k <= MAX_K; k++) {
        for (int sim = 1; sim <= N_SIM; sim++) {

            // --- 1) Choix du centre ---
            int cx = R + rand() % (M - 2*R);
            int cy = R + rand() % (N - 2*R);

            // --- 2) Calcul des poids p(i,j) ---
            double sumP = 0.0;
            int idx = 0;

            for (int i = 0; i < M; i++) {
                for (int j = 0; j < N; j++) {
                    double dx = j - cy;
                    double dy = i - cx;
                    double dist = sqrt(dx*dx + dy*dy);
                    p[idx] = exp(-(dist/R)*(dist/R));
                    sumP += p[idx];
                    idx++;
                }
            }

            for (int i = 0; i < M*N; i++)
                p[i] /= sumP;

            // --- 3) CDF ---
            cdf[0] = p[0];
            for (int i = 1; i < M*N; i++)
                cdf[i] = cdf[i-1] + p[i];

            // --- 4) Etat initial = matrice M×N ---
            for (int i = 0; i < M; i++)
                for (int j = 0; j < N; j++)
                    state[i][j] = 0;

            for (int d = 0; d < k; ) {   // d n'est pas incrémenté automatiquement
                double r = (rand() + 1.0) / (RAND_MAX + 1.0);
                int pos = 0;
                while (cdf[pos] < r) pos++;
                    int x = pos / N;
                    int y = pos % N;

            if (state[x][y] == 0) {  // ne place que si la case est vide
                state[x][y] = 1;
                d++;  // on incrémente d seulement si un nouveau déclencheur est placé
            }
}


            // --- 5) Écriture de la matrice state ---
            fwrite(state, sizeof(int), M*N, f);

            mat_index++;
        }
    }

    fclose(f);
    free(p);
    free(cdf);

    printf("Nombre total de matrices state écrites : %d\n", mat_index);
    return 0;
}
