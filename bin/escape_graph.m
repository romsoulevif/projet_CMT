function escape_graph()
% Étude de l'évacuation en fonction du stress collectif
% beta = 1 - alpha

%% Paramètres fixes (imposés)
M = 25; 
N = 25;
density = 0.4;
sigma = 1.0;

target_i = round(M/2);
target_j = M+1;    % sortie à droite

alpha_vals = 0:0.1:1;
N_simulations = 50;
max_steps = 2000;

beta_vals = 1 - alpha_vals;
mean_time = zeros(size(alpha_vals));

%% Boucle sur alpha
for a = 1:length(alpha_vals)
    alpha = alpha_vals(a);
    steps_record = zeros(N_simulations,1);

    for sim = 1:N_simulations

        % --- grille initiale ---
        nb_agents = round(M*N*density);
        stategrid = zeros(M,N);
        idx = randperm(M*N, nb_agents);
        stategrid(idx) = 1;
        grid_w_wall = padarray(stategrid,[1 1],Inf);

        % --- champ de distance ---
        [iGrid, jGrid] = ndgrid(1:M,1:N);
        phi = ((iGrid - target_i).^2 + (jGrid - target_j).^2).^0.25;
        phi = imgaussfilt(phi,sigma);
        phi_w_wall = padarray(phi,[1 1],Inf);
        phi_w_wall(target_i+1,target_j+1) = -10;

        next_grid = grid_w_wall;

        %% Dynamique
        for r = 1:max_steps
            current_grid = next_grid;
            new_grid = current_grid;
            new_grid(target_i+1,target_j+1) = 0;

            localDensity = conv2(double(current_grid==1), ones(3)/9,'same');
            localDensity_w_wall = padarray(localDensity,[1 1],Inf);

            [iCells,jCells] = find(current_grid==1);
            idx_perm = randperm(length(iCells));

            for k = idx_perm
                i = iCells(k); 
                j = jCells(k);

                % Sortie
                if abs(i-(target_i+1))<=1 && abs(j-(target_j+1))<=1
                    new_grid(i,j) = 0;
                    continue;
                end

                % Coût
                subPhi = phi_w_wall(i-1:i+1,j-1:j+1);
                subDensity = localDensity_w_wall(i-1:i+1,j-1:j+1);
                subCost = subPhi + alpha*subDensity;

                minCost = min(subCost(:));
                [ci,cj] = find(subCost==minCost);

                occBlock = new_grid(i-1:i+1,j-1:j+1);
                idx_lin = sub2ind(size(subCost),ci,cj);
                isFree = occBlock(idx_lin)==0;
                ci = ci(isFree); 
                cj = cj(isFree);

                if ~isempty(ci)
                    next_i = i + ci(1) - 2;
                    next_j = j + cj(1) - 2;
                    new_grid(i,j) = 0;
                    new_grid(next_i,next_j) = 1;
                end
            end

            next_grid = new_grid;

            % Fin si évacuation complète
            if sum(next_grid(:)==1)==0
                steps_record(sim) = r;
                break;
            end
        end

        if steps_record(sim)==0
            steps_record(sim) = max_steps;
        end
    end

    mean_time(a) = mean(steps_record);
    fprintf('beta = %.2f - itérations = %.1f\n', beta_vals(a), mean_time(a));
end

%% Tracé final
figure;
plot(beta_vals, mean_time, 'r-o', 'LineWidth', 1.5);
xlabel('\beta = indice de stress (1 - \alpha)');
ylabel("Nombre moyen d'itérations pour évacuation complète");
title("Temps d'évacuation en fonction du stress collectif");
grid on;

end
