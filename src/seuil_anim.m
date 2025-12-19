function seuil_anim()
    %% Paramètres
    M = 100;
    N = 100;
    mu = 7;
    sigma = 0.5;
    N_steps = 400;
    nb_declencheur = 10;
    kernel = ones(5,5);
    R = 3;

    %% Initialisation
    stress_idx_grid = round(mu + sigma * randn(M,N));
    stress_idx_grid = max(1, min(24, stress_idx_grid));

    cx = randi([R+1, M-R-1]);
    cy = randi([R+1, N-R-1]);
    [X, Y] = meshgrid(1:N, 1:M);
    dist = sqrt((X-cy).^2 + (Y-cx).^2);
    p = exp(-(dist/R).^2);
    p = p / sum(p(:));

    cdf = cumsum(p(:));
    idx_declencheur = zeros(nb_declencheur,1);
    for n = 1:nb_declencheur
        r = rand;
        idx = find(cdf >= r, 1, 'first');
        idx_declencheur(n) = idx;
    end

    state = zeros(M,N);
    state(idx_declencheur) = 1;

    %% Animation
    figure;
    for t = 1:N_steps
        num_stressed = conv2(state, kernel, 'same');
        new_state = state;
        new_state(state==0 & num_stressed >= stress_idx_grid) = 1;

        imagesc(new_state);
        colormap([1 1 1; 1 0 0]);
        axis equal tight;
        title(sprintf("Evolution of the stress propagation. Try again several times, sometimes the stress spreads, sometimes not..."));
        drawnow;

        if isequal(new_state, state)
            break;
        end
        state = new_state;
    end
end