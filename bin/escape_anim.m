function escape_anim()
    %% Lance 3 animations côte à côte avec beta = 0.2, 0.5, 0.8
    
    %% Paramètres fixes pour toutes les animations
    M = 25; N = 25;
    density = 0.4;
    sigma = 1.0;
    target_i = 15; target_j = 26;
    target_i_w = target_i + 1;
    target_j_w = target_j + 1;
    N_steps = 1000;
    
    %% Valeurs de beta (alpha = 1 - beta)
    betas = [0.2, 0.5, 0.8];
    alphas = 1 - betas;
    
    %% Titres pour chaque sous-graphique
    titles_en = {
        'beta = 0.2, low-stress crowd';
        'beta = 0.5, medium-stress crowd';
        'beta = 0.8, high-stress crowd'
    };
    
    %% Création de la figure avec 3 subplots
    figure('Position', [50, 50, 1400, 500]);
    
    %% Initialisation des grilles pour chaque beta
    grids = cell(1, 3);
    phi_w_walls = cell(1, 3);
    next_grids = cell(1, 3);
    
    for b_idx = 1:3
        beta = betas(b_idx);
        alpha = alphas(b_idx);
        
        % Création de la grille
        nb_agents = round(M*N*density);
        grid = zeros(M,N);
        idx = randperm(M*N, nb_agents);
        grid(idx) = 1;
        grid_w_wall = padarray(grid, [1 1], Inf);
        grids{b_idx} = grid_w_wall;
        next_grids{b_idx} = grid_w_wall;
        
        % Champ de distance + lissage
        [iGrid, jGrid] = ndgrid(1:M, 1:N);
        phi = ((iGrid - target_i).^2 + (jGrid - target_j).^2).^0.25;
        phi = imgaussfilt(phi, sigma);
        phi_w_wall = padarray(phi, [1 1], Inf);
        phi_w_wall(target_i_w, target_j_w) = -10;
        phi_w_walls{b_idx} = phi_w_wall;
        
        % Affichage initial pour chaque subplot
        subplot(1, 3, b_idx);
        imagesc(grid_w_wall);
        axis equal tight;
        colormap([1 1 1; 0 0 1; 0 0 0]);
        caxis([0 2]);
        title(titles_en{b_idx});
        xlabel('Columns'); 
        ylabel('Rows');
        
        hold on; 
        plot(target_j_w, target_i_w, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 10); 
        hold off;
    end
    
    %% Boucle principale d'animation simultanée
    for r = 1:N_steps
        for b_idx = 1:3
            beta = betas(b_idx);
            alpha = alphas(b_idx);
            current_grid = next_grids{b_idx};
            phi_w_wall = phi_w_walls{b_idx};
            
            % Mise à jour de la grille
            new_grid = current_grid;
            new_grid(target_i_w, target_j_w) = 0;
            
            % Calcul densité locale
            localDensity = conv2(double(current_grid == 1), ones(3)/9, 'same');
            localDensity_w_wall = padarray(localDensity, [1 1], Inf);
            
            % Agents en mouvement
            [iCells, jCells] = find(current_grid == 1);
            idx_perm = randperm(length(iCells));
            
            for k = idx_perm
                i = iCells(k); 
                j = jCells(k);
                
                % Si agent proche sortie → sort
                if abs(i - target_i_w) <= 1 && abs(j - target_j_w) <= 1
                    new_grid(i, j) = 0;
                    continue;
                end
                
                % Calcul coût local
                subPhi = phi_w_wall(i-1:i+1, j-1:j+1);
                subDensity = localDensity_w_wall(i-1:i+1, j-1:j+1);
                subCost = subPhi + alpha * subDensity;
                
                % Positions minimales
                minCost = min(subCost(:));
                [ci, cj] = find(subCost == minCost);
                
                % Vérifier cases libres
                occBlock = new_grid(i-1:i+1, j-1:j+1);
                idx_lin = sub2ind(size(subCost), ci, cj);
                isFree = (occBlock(idx_lin) == 0);
                ci = ci(isFree); 
                cj = cj(isFree);
                
                if ~isempty(ci)
                    next_i = i + ci(1) - 2;
                    next_j = j + cj(1) - 2;
                    new_grid(i, j) = 0;
                    new_grid(next_i, next_j) = 1;
                end
            end
            
            next_grids{b_idx} = new_grid;
            
            % Mise à jour affichage
            subplot(1, 3, b_idx);
            imagesc(new_grid);
            axis equal tight;
            colormap([1 1 1; 0 0 1; 0 0 0]);
            caxis([0 2]);
            
            hold on; 
            plot(target_j_w, target_i_w, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 10); 
            hold off;
            
            agents_left = sum(new_grid(:) == 1);
            title(sprintf('%s | Agents: %d', titles_en{b_idx}, agents_left));
        end
        
        drawnow;
        pause(0.05);
        
        % Arrêt si toutes les animations ont terminé
        agents_left_total = sum(cellfun(@(g) sum(g(:) == 1), next_grids));
        if agents_left_total == 0
            break;
        end
    end
end