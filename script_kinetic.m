clc
clear all
addpath(genpath('C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel'));
rxfname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\ecoliN1.txt';

%create model structure
[FBAmodel,parameter,variable,nrxn,nmetab] = modelgen(rxfname);

%sample initial metabolite concentrations for estimating kientic parameters
mc = parallel_sampling(FBAmodel);

%estimate kinetic parameters in an ensemble
ensb = parallel_ensemble
