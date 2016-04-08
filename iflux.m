function flux = iflux(model,pvec,mc,flux,idx)
[~,nc] = size(mc);
if nargin <5
    idx = [];
else
    idflux = zeros(length(idx),nc);
end
if nargin<4
    flux = zeros(model.nt_rxn,nc);
end
if isfield(model,'rxn_add');
    rxn_add = model.rxn_add;
else
    rxn_add = {};
end
if isfield(model,'rxn_excep')
    rxn_excep = model.rxn_excep;
else
    rxn_excep = {};
end
% Vind = [model.Vind find(strcmpi(model.rxns,'GLCpts'))];
% Vind = [Vind find(strcmpi(model.rxns,'NADH16'))];
% Vind = [Vind find(strcmpi(model.rxns,'ATPS4r'))];
% Vind = [Vind find(strcmpi(model.rxns,'NADTRHD'))];
% Vind = [Vind find(strcmpi(model.rxns,'THD2'))];
% Vind = [Vind find(strcmpi(model.rxns,'CYTBD'))];
% 
% Vind = setdiff(Vind,find(strcmpi(model.rxns,'ATPM')));

Vind = addToVind(model,model.Vind,rxn_add,rxn_excep);

%carbon uptake fluxes
% [flux,~,vcup] = CarbonKinetics(model,pvec,mc,flux);

%redox reaction fluxes in vrem
% [flux,~,vred] = RedoxKinetics(model,pvec,mc,flux);

%transport fluxes
Vex = model.Vex;
Vex = setdiff(Vex,Vind);

%other fixed exchaged fluxes
VFex = model.VFex;

for ic = 1:nc
    if isempty(idx)

        flux(Vind,ic) = CKinetics(model,pvec,mc(:,ic),Vind);
        
        flux = ETCflux(model,mc,flux);

        %transport fluxes    
        flux(Vex,ic) = TKinetics(model,pvec,mc(:,ic),Vex);

        %other fixed exchaged fluxes - currently sets them to 0  
        flux(VFex,ic) = EKinetics(model,pvec,mc(:,ic),VFex,flux(:,ic));

        %biomass
    %     if mc(strcmpi(model.mets,'atp[c]'))>0 &&...
    %        mc(strcmpi(model.mets,'h2o[c]'))>0
    %         flux(strcmpi(model.rxns,'atpm')) = 8.39;
    %     else
    %         flux(strcmpi(model.rxns,'atpm')) = 0;
    %     end
        
        %atp maintanance
        atp = strcmpi(model.mets,'atp[c]');
        if any(atp) && any(strcmpi(model.rxns,'atpm'))
    %     flux(strcmpi(model.rxns,'atpm')) = 8.39;        
%         flux(strcmpi(model.rxns,'atpm'),ic) = 8.39*logical(mc(atp,ic));%*mc(atp)/1e-5/(1+mc(atp)/1e-5);
            flux(strcmpi(model.rxns,'atpm'),ic) =...
            pvec.Vmax(strcmpi(model.rxns,'atpm'))*...
            mc(atp)/1e-5/(1+mc(atp)/1e-5);
        end
        %vatp = 

    %     if all(mc(logical(model.S(:,model.bmrxn)<0))>1e-5)
    %         flux(model.bmrxn) = model.Vss(model.bmrxn);%0.01;
    %     elseif any(mc(logical(model.S(:,model.bmrxn)<0))<1e-5)
    %         flux(model.bmrxn) = 0;
    %     end
        flux(model.bmrxn,ic) = model.Vss(model.bmrxn)/3600;
%         flux(strcmpi('GLCpts',model.rxns),ic) = 10;
    else
        %determine which group idx belongs to
        for id = 1:length(idx)
            if ismemeber(idx(id),Vind)
    %         if ismember(idx(id),vcup) || ismember(idx(id),vred)
    %             idflux(idx(id)) = flux(idx(id));
    %         elseif ismember(idx(id),Vind)
                idflux(idx(id),ic) = CKinetics(model,pvec,mc(:,ic),idx(id));
            elseif ismember(idx(id),Vex)
                idflux(idx(id),ic) = TKinetics(model,pvec,mc(:,ic),idx(id));
            elseif ismember(idx(id),VFex)
                idflux(idx(id),ic) = EKinetics(model,pvec,mc(:,ic),VFex,idflux);
            elseif idx(id)==find(strcmpi(model.rxns,'atpm'))
    %             if mc(strcmpi(model.mets,'atp[c]'))>0 &&...
    %                mc(strcmpi(model.mets,'h2o[c]'))>0
    %                 idflux(idx(id)) = 8.39;
    %             else
    %                 idflux(idx(id)) = 0;
    %             end
                idflux(idx(id),ic) = 0;
            elseif idx(id)==model.bmrxn
                idflux(id,ic) = 0;
            end        
        end        
        idxflux(strcmpi('GLCpts',model.rxns),ic) = 20;        
    end
end

if ~isempty(idx)
    flux = idxflux(idx,:);
end

% if flux(strcmpi(model.rxns,'atpm'))>=1e-5 &&...
%     all(mc(logical(model.S(:,model.bmrxn)>0))>0)
%     flux(model.bmrxn) = 0.1;
% else
%     flux(model.bmrxn) = 0;
% end

