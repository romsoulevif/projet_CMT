% run_me.m
fprintf('1 - seuil_anim.m\n');
fprintf('2 - seuil_graph.m\n');
fprintf('3 - escape_anim.m\n');
fprintf('4 - escape_graph.m\n');

choix = input('Entrez 1,2,3 ou 4 : ');

switch choix
    case 1
        seuil_anim();
        
    case 2
        % 1: Compiler les fichiers C vers bin/
        fprintf('Compilation des fichiers C...\n');
        system('gcc -o ../bin/thresholds_matrix thresholds_matrix.c -lm');
        system('gcc -o ../bin/state_matrix state_matrix.c -lm');
        
        % 2: Exécuter depuis bin/
        fprintf('Génération des fichiers binaires...\n');
        system('cd ../bin && ./thresholds_matrix');
        system('cd ../bin && ./state_matrix');
        
        % 3: Lancer la simulation
        seuil_graph();
        
        % 4: Sauvegarder dans results/
        saveas(gcf, '../results/escape_graph.png');
        fprintf('Graphique sauvegardé dans results/escape_graph.png\n');
        
    case 3
        escape_anim();
        
    case 4
        escape_graph();
        saveas(gcf, '../results/escape_graph.png');
end