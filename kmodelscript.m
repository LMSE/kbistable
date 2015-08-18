clc
% clear all
addpath(genpath('C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel'));
% load('C:\Users\shyam\Documents\Courses\CHE 1125 Project\Kinetic Model\kmodel_pname.mat');
rxfname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\ecoliN1.txt';
[FBAmodel,parameter,variable,nrxn,nmetab] = modelgen(rxfname);
% % % sample metabolites 
% variable.MC = sampleMetabolites(FBAmodel);
%Obtain Vss from FBA
% load('C:\Users\shyam\Documents\Courses\CHE1125Project\mat_files\KineticModel\FBAmodel.mat');
% load('C:\Users\shyam\Documents\Courses\CHE1125Project\mat_files\KineticModel\FBAsol.mat');

% for ienz = 1:length(FBAmodel.rxns)
%     tfe = strcmpi(FBAmodel.rxns{ienz},oldFBAmodel.rxns);
%     if any(tfe)
%         FBAmodel.Vss(ienz) = FBAsolution.x(tfe);
% %         FBAmodel.delG(ienz) = model.dGo(tfe);
% %         FBAmodel.Keq(ienz) = exp(-FBAmodel.delG(ienz)/(0.008314*298.15));
%     end
% end

% variable.MC = sampleMet(FBAmodel);

% viol = delGaconsistent(FBAmodel,variable);
% Sol = cell(1000,1);
% fSol = cell(1000,1);
% MC = zeros(0,1000);
% for j = 1:1
%     sam_name = sprintf('samp_%d',j);
%     data.(sam_name).variable = variable;
%     data.(sam_name).variable.MC = sampleMet(FBAmodel,j);
% end
% % if isempty(gcp('nocreate'))
% %     parpool(4);
% % end
% for i = 1:1  
%     fprintf('Sample #%d of 1000\n',i);
%     sam_name = sprintf('samp_%d',i);
%     variable = data.(sam_name).variable;
   
nmodels = 1;
[ensb,variable] = sampleMet_parallel(FBAmodel,parameter,nmodels);

% load('C:\Users\shyam\Documents\Courses\CHE1125Project\mat_files\KineticModel\N2m_ensb1');
% load('C:\Users\shyam\Documents\Courses\CHE1125Project\mat_files\KineticModel\N2m_variable1');
%     load('C:\Users\shyam\Documents\Courses\CHE1125Project\mat_files\KineticModel\ecoliT4_MC_1.mat');
inSolution = [];
varname = {'A[c]','B[c]','C[c]','D[c]','E[c]','P[c]','S[c]'};
% varname = {'glc[e]','g6p[c]','pep[c]','pyr[c]',...
%                'g3p[c]'};%,'fdp[c]','atp[c]','adp[c]','h[c]'};%,...
%                'pi[c]','g3p[c]'};

[allSolution,allfinalSS,ySample] =...
solveEnsembleMC(FBAmodel,ensb,variable,inSolution,varname,'MC');
    
%     Sol{i} = allSolution;
%     fSol{i} = allfinalSS;
% end
% [allSolution,allfinalSS,FBAmodel,conc] =...
% MCMetabolicModel(FBAmodel,ensb,variable);
%Model initialization
% FBAmodel.Vuptake = 20;%mmole/h ->still confused!
% FBAmodel.gmax = 0.8;%h-1
% Check Model Stability of ensemble
% Use jacobians and their Eigen values
%define perturbations
pertb.pertb1.enzname = 'P2';
pertb.pertb1.change = 'increase';
pertb.pertb1.percent = 0;
% pertb.pertb2.enzname = 'Protein2';
% pertb.pertb2.change = 'decrease';
% pertb.pertb2.percent = 100;
% pertb.pertb3.enzname = 'Protein2';
% pertb.pertb3.change = 'increase';
% pertb.pertb3.percent = 100;
% pertb.pertb4.enzname = 'Protein5';
% pertb.pertb4.change = 'increase';
% pertb.pertb4.percent = 100;
% [inSolution,enSolution] =  solveEnsemble(ensb,FBAmodel,variable,pertb);

