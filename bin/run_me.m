% run_me.m - Version minimaliste
fprintf('1 - seuil_anim.m\n');
fprintf('2 - seuil_graph.m\n');
fprintf('3 - escape_anim.m\n');
fprintf('4 - escape_graph.m\n');

choix = input('Entrez 1,2,3 ou 4 : ');

switch choix
    case 1
        seuil_anim();
        
    case 2
        % Compiler et exécuter les fichiers C
        system('cd ../data && gcc -o thresholds_matrix thresholds_matrix.c -lm');
        system('cd ../data && gcc -o state_matrix state_matrix.c -lm');
        system('cd ../data && ./thresholds_matrix');
        system('cd ../data && ./state_matrix');
        
        % Lancer la simulation
        seuil_graph();
        
        % Sauvegarder
        saveas(gcf, '../results/escape_graph.png');
        
    case 3
        escape_anim();
        
    case 4
        escape_graph();
        saveas(gcf, '../results/escape_graph.png');
end