% run_me.m - Version pour exécution depuis bin/
fprintf('1 - seuil_anim.m\n');
fprintf('2 - seuil_graph.m\n');
fprintf('3 - escape_anim.m\n');
fprintf('4 - escape_graph.m\n');

choix = input('Entrez 1,2,3 ou 4 : ');

switch choix
    case 1
        seuil_anim();
    case 2
        mex thresholds_matrix.c;
        mex state_matrix.c;
        seuil_graph();
        saveas(gcf, '../results/escape_graph.png');
    case 3
        escape_anim();
    case 4
        escape_graph();
        saveas(gcf, '../results/escape_graph.png');
end