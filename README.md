# Propagation of stress and impact on crowds

## Project Description

The purpose of this project is to simulate crowds with simple model and show how stress affect their dynamics.

### Input files

1- Big_matrice.c, Only_state.c : create the matrix used in graph_seuil_V2.m
2- seuil_graph.m plot a curve that shows how many people need to be initially stressed in order to contaminate a whole crowd.
3- seuil_anim.m little animation to understand how the stress propagation model used works.
4- escape_time.m plot a curve that shows the influence of a crowd's stress level on its time to escape a room.
5- escape_anim.m little animation to understand how the crowd's escape model works.
(Located in "data/".)


### Output files

1- curve plotted by graph_seuil_V2.m
2- curve plotted by escape_time.m 
(generated in "results/".)

### Report

The final report is placed in "docs/" as "report.pdf".

## Running the program

### Dependencies

Matlab R2022b + Image processing toolbox (included in recent Matlab versions)

### Build

C programs should be compiled using mex. The executable or shared object file is placed in the "bin/" directory.

### Execute

Open "Run_me" in Matlab in the folder "projet_CMT/src", run it and follow the instructions.

## Contributors

Romain Santiard

### Code

Romain Santiard with the help of deepseek 
