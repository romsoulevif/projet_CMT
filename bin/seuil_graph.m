function seuil_graph()
    %% Paramètres
    M = 100;
    N = 100;
    kernel = ones(5,5); 
    N_steps = 300;
    nb_k = 20;
    nb_sim = 300;
    nb_declencheurs_vec = 1:1:nb_k;
    resultats = zeros(size(nb_declencheurs_vec));

    %% Chargement Fichiers Binaires
    file1 = '../data/thresholds_matrix.bin';
    file2 = '../data/state_matrix.bin');

    fidS = fopen(file1, "rb");
    big_thresh = fread(fidS, inf, "int32");
    fclose(fidS);

    fidE = fopen(file2, "rb");
    big_state = fread(fidE, inf, "int32");
    fclose(fidE);

    %% Boucle principale sur k
    for k = 1:length(nb_declencheurs_vec)
        count_full_panic = 0;
        nb_declencheur = nb_declencheurs_vec(k);

        for sim = 1:nb_sim
            idx0 = ( (k-1)*nb_sim + (sim-1) ) * M*N;
            blockT = big_thresh(idx0+1 : idx0+M*N);
            stress_idx_grid = reshape(blockT, [N M]).';
            blockS = big_state(idx0+1 : idx0+M*N);
            state = reshape(blockS, [N M]).';

            no_change_count = 0;

            for t = 1:N_steps
                num_stressed = conv2(state, kernel, 'same');
                new_state = state;
                new_state(state==0 & num_stressed >= stress_idx_grid) = 1;

                if isequal(new_state, state)
                    no_change_count = no_change_count + 1;
                else
                    no_change_count = 0;
                end

                state = new_state;

                if all(state(2:M-1,2:N-1)==1)
                    count_full_panic = count_full_panic + 1;
                    break;
                end

                if no_change_count >= 10
                    break;
                end
            end
        end

        resultats(k) = count_full_panic;
    end

    %% Affichage
    figure;
    plot(nb_declencheurs_vec, resultats/nb_sim*100, 'r-o','LineWidth',1.5);
    xlabel('Nombre initial de stressés');
    ylabel('Probabilité de panique totale (%)');
    title('Probabilité de panique totale selon nb déclencheurs (données pré-calculées)');
    grid on;
end