clc
% clear all
addpath(genpath('C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel'));
% load('C:\Users\shyam\Documents\Courses\CHE 1125 Project\Kinetic Model\kmodel_pname.mat');
%create Metabolic Model from text file
rxfname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\N2mD.txt';
[FBAmodel,parameter,variable,nrxn,nmetab] = modelgen(rxfname);
% load('C:\Users\shyam\Documents\Courses\CHE1125Project\mat_files\KineticModel\N2mD.mat');
nmodels = 1;
[ensb,variable] = sampleMet_parallel(FBAmodel,parameter,nmodels);
load('C:\Users\shyam\Documents\Courses\CHE1125Project\mat_files\KineticModel\N2mD_MC1');
load('C:\Users\shyam\Documents\Courses\CHE1125Project\mat_files\KineticModel\N2mD_parameter1');

inSolution = [];
varname = {'A[c]','B[c]','C[c]','D[c]','E[c]','P[c]'};
[allSolution,allfinalSS,ySample] =...
solveEnsembleMC(FBAmodel,ensb,variable,inSolution,varname,'MC');
clear allSolution allfinalSS ySample
% %create TRN model from text file
trnfname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\TRNModel\N2trn_dnf2.txt';
regfname = '';
% saveData.dirname = 'C:\Users\shyam\Documents\Courses\CHE 1125 Project\Results\TRN Model version 3';
% load('C:\Users\shyam\Documents\Courses\CHE 1125 Project\TRN Model\intmodel_wreg7.mat');
% load('C:\Users\shyam\Documents\Courses\CHE 1125 Project\TRN Model\intmodel_wreg_2.mat');
for imodel = 1:nmodels
    mname = sprintf('model%d',imodel);
    [trnmodel,FBAmodel,parameter,defparval] =...
    Tmodel(trnfname,FBAmodel,ensb.(mname),variable.(mname));  
    ensb.(mname) = parameter;
end
% parameter = ensb.model1;
% variable = variable.model1;
% [trnmodel,FBAmodel,defparval] = Tmodel(trnfname,FBAmodel,parameter,variable);
ng = [trnmodel.nt_gene;...
      trnmodel.nt_prot+trnmodel.nr_cmplx-length(trnmodel.PMind_R)-1;...      
      length(trnmodel.PMind_R);...
      trnmodel.nt_metab-length(trnmodel.PMind_R)-trnmodel.next_metab-length(trnmodel.bm_ind);...
      0;...%length(trnmodel.RegCMPLX);...
      trnmodel.next_metab]; 
% trnmodel.pmeter = ensb.model1;
% [trnmodel,batch,solverP] = initializeModel(trnmodel,5000,parameter,variable);
varname = {'A[c]';'B[c]';'C[c]';'D[c]';'E[c]';'P[c]';'P1';'P5';'P6'};   
saveData.filename = '';%sprintf('ExptCondition_%d',exptnum);
saveData.dirname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\Results\TRN Model version 6';
%Solve Model ODE 
inSolution = [];

% [initval,Solution,~,finalSS] =...
% runSolver(trnmodel,FBAmodel,batch,defparval,ng,...
%                 solverP,initSolution,...
%                 varname,saveData);  
% MC = finalSS.y(ng(1)+ng(2)+2:ng(1)+ng(2)+1+ng(3)+ng(4));
% EC = finalSS.y(ng(1)+1:ng(1)+ng(2)+ng(3)+1)*1e-3;
% flux = calc_flux(trnmodel,trnmodel.pmeter,MC,EC);

pName = {'gmax','','',''};
pScale = [0.2 2];
%Sample initial values multiple times for initial simulation   
[allSolution,allfinalSS,ySample] =...
 solveIntegratedMC(trnmodel,FBAmodel,ng,ensb,defparval,variable,inSolution,varname,'MC');

% fname1 = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\TRNModel\ListExp.txt';
% [allSolution,allfinalSS,trnmodel,conc,flux,petconc] =...
% sampleinitval(fname1,ng,varname,{},trnmodel,trnmodel.pmeter,variable,pName,pScale);
%Group multiple Steady states
% [Rconc,multiSS] = binConcentrations(conc);
%Group Intial Values corresponding to final SS
% [newPIV,newColr] = groupConcentrations(petconc,Rconc,multiSS);
%Compare different cases using plots
% fname1 = 'C:\Users\shyam\Documents\Courses\CHE 1125 Project\TRN Model\ListExp.txt';
% tstart = tic;
% varname = {'M1';'M2';'M3';'G1'};
% [allSolution,allfinalSS,trnmodel,SSplotData,h_subfig] = plotComparison(fname1,ng,varname,{},trnmodel);
% selectData(allSolution,trnmodel,ng);


    