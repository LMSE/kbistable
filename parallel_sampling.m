function [mc,pvec,smp] = parallel_sampling(model,pvec,funName,met,mc,rxn_add,nsample)
if nargin<7
    nsample = 500;
end
if nargin<6
    rxn_add = {};
end
if nargin<5
    mc = [];
end
if nargin<4 || isempty(met)
    met = struct([]);
end

% generate one metabolite concentration for parameter estimation
% get one set of concentrations and coresponding delGr

% [mc,assignFlag,delGr,model,vCorrectFlag] = getiConEstimate(model,funName,mc,rxn_add);
% [mc,assignFlag] = iconcentration(model,met,mc,assignFlag);
% %M to mM
% mc = mc*1000;
% pvec.delGr = delGr;

% fprintf('Generating %d concentration samples using ACHR\n',nsample);
%sample met using ACHR
%get more than one set of concentrations using ACHR sampling
clear assignFlag
pts = [];
ptsdelGr = [];
[pts,assignFlag,ptsdelGr,vCorrectFlag] =...
ACHRmetSampling(model,funName,mc,rxn_add,1,nsample,200);

% pts = iconcentration(model,met,pts,assignFlag);

if ~isempty(pts)
    smp = cell(nsample,1);
    for ism = 1:nsample    
        %extracellular metabolites in M moles/L
        %from M to mM
        smp{ism,1} = pts(:,ism)*1000;
        smp{ism,2} = pvec;
        smp{ism,2}.delGr = ptsdelGr(:,ism);

        %details in structure format
    %     if nsample>1
    %         mid = sprintf('model%s',ism);
    %         variable.(mid) = smp{ism,1};
    %         pvec.(mid).delGr = ptsdelGr(:,ism); 
    %     else
    %         variable = mc;
    %         pvec.delGr = delGr;
    %     end
    end
else
    smp = {};
end

% if nsample > 1
%     mc = struct();
%     newpvec = struct();    
%     for ism = 1:nsample
%         mid = sprintf('model%s',ism);
%         mc.(mid) = smp{ism};
%         newpvec.(mid) = pvec;
%         newpvec.(mid).delGr = smp{ism,2};
%     end
% else
%     mc = smp{1,1};
%     pvec.delGr = smp{1,2};
% end
% load('C:\Users\shyam\Documents\Courses\CHE1125Project\mat_files\KineticModel\ecoliN1_MC1.mat');
% load('C:\Users\shyam\Documents\Courses\CHE1125Project\mat_files\KineticModel\ecoliN1_pvec1.mat');
