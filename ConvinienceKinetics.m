%function [flux,vcontr] = ConvinienceKinetics(model,pmeter,MC,bm_ind)
%**************************************************************************
%September 2014
%Changed parameters to sparse matrices
%January 2015 
%**************************************************************************
function [flux,vcontr,varargout] = ConvinienceKinetics(model,pmeter,MC,Vind,EC)

if nargin < 6
    useVmax = 1;    
else
    useVmax = 0;
end

%Convinience Kinetics for intracellular fluxes in Metabolism
S = model.S;
SI = model.SI;
[~,n_rxn] = size(S);
Km = pmeter.K;
KIact = pmeter.KIact;
KIihb = pmeter.KIihb;
% kcat_ratio = pmeter.kcat_ratio;
kcat_fwd = pmeter.kcat_fwd;
kcat_bkw = pmeter.kcat_bkw;
Vmax = pmeter.Vmax;

vthermo_ = zeros(n_rxn,1);
vsat_ = zeros(n_rxn,1);
vact_ = zeros(n_rxn,1);
vihb_ = zeros(n_rxn,1);
vreg_ = zeros(n_rxn,1);
flux = zeros(n_rxn,1);

% vcontr = zeros(nt_rxn,1);
h2oid = strcmpi(model.mets,'h2o[c]');

for irxn = 1:length(Vind)
    subid = S(:,Vind(irxn)) < 0;%substrate
    prdid = S(:,Vind(irxn)) > 0;
    %Remove h2o from consideration of kinetics - Non limiting
%     if any(subid(h2oid)) || any(prdid(h2oid))
%         subid(h2oid) = 0;
%         prdid(h2oid) = 0;
%     end
    if any(subid) || any(prdid)
        sub = MC(subid);
        prd = MC(prdid);
        s_sub = -(S(subid, Vind(irxn)));
        s_prd = S(prdid, Vind(irxn));
        Ksubs = Km(subid,Vind(irxn));
        Kprod = Km(prdid,Vind(irxn));  
        %Check reaction reversibility
        if model.rev(Vind(irxn))
            %reversibile
            %thermodynamics
            if prod(sub.^s_sub) ~= 0 && kcat_fwd(Vind(irxn))~=0
                %avoid divide by zero error
                vthermo_(Vind(irxn)) = 1 - (kcat_bkw(Vind(irxn))/kcat_fwd(Vind(irxn)))*...
                                       prod(prd.^s_prd)/prod(sub.^s_sub);
            else
                vthermo_(Vind(irxn)) = 0;
            end    
            
            %saturation    
            numr = prod(sub.^s_sub);            
            denr = prod((1 + sub./Ksubs).^s_sub)*...
                   prod((1 + prd./Kprod).^s_prd)-1;   
            vsat_(Vind(irxn)) = numr/denr;            
        else
            %irreversible
            %thermodynamics
            vthermo_(Vind(irxn)) = 1;
            
            %saturation
            numr = prod(sub.^s_sub);            
            denr = prod((1 + sub./Ksubs).^s_sub);
            vsat_(Vind(irxn)) = numr/denr;            
        end
        
        %regulation
        %activation
        if any(SI(:,Vind(irxn))>0)
            actmid = SI(:,Vind(irxn))>0;
            actM = MC(actmid);
            s_act = SI(actmid,Vind(irxn));
            KIactM = KIact(actmid,Vind(irxn));
            vact_(Vind(irxn)) = prod(((actM./KIactM).^s_act)./(1+(actM./KIactM).^s_act));
        else
            vact_(Vind(irxn)) = 1;
        end
        
        %inhibition
        if any(SI(:,Vind(irxn))<0)
            ihbmid = SI(:,Vind(irxn))<0;
            ihbM = MC(ihbmid);
            s_ihb = -SI(ihbmid,Vind(irxn));
            KIihbM = KIihb(ihbmid,Vind(irxn));
            vihb_(Vind(irxn)) = prod(1./(1 + (ihbM./KIihbM).^s_ihb));  
        else
            vihb_(Vind(irxn)) = 1;
        end
        vreg_(Vind(irxn)) = vact_(Vind(irxn)).*vihb_(Vind(irxn));  
    else
        vthermo_(Vind(irxn)) = 1;
        vsat_(Vind(irxn)) = 1;        
        vreg_(Vind(irxn)) = 1;
    end
end
if useVmax
    if ~any(isnan(Vmax(Vind))) && ~any(isnan(kcat_fwd(Vind)))
        flux(Vind) = Vmax(Vind).*kcat_fwd(Vind).*vthermo_(Vind).*vsat_(Vind).*vreg_(Vind);
    else
        flux(Vind) = 0;
    end
else
    if ~isnan(kcat_fwd(Vind))
        flux(Vind) = EC(Vind).*kcat_fwd(Vind).*vthermo_(Vind).*vsat_(Vind).*vreg_(Vind);
    else
        flux(Vind) = 0;
    end
end
flux = flux(Vind);
     
%build ensemble use
vcontr = vthermo_.*vsat_.*vreg_;
varargout{1} = vthermo_;
varargout{2} = vsat_;
varargout{3} = vreg_;

%Net Flux - Intracellular
% model.Kcat(1:n_rxn) = 3000;%s-1


%Exchange Fluxes are determined outside in the ODE based on
%1. Material balance
%2. Kinetics
%3. Thermodynamics

% [mindx,rindx] = find(model.S);
% Jtherm = sparse(rindx,mindx,ones(length(rindx),1),nrxn,nmetab);
% Jsat = sparse(rindx,mindx,ones(length(rindx),1),nrxn,nmetab);
% relJtherm = sparse(rindx,mindx,ones(length(rindx),1),nrxn,nmetab);
% relJsat = sparse(rindx,mindx,ones(length(rindx),1),nrxn,nmetab);

% [regind,regrind] = find(model.SI);
% Jreg = sparse(regrind,regind,ones(length(regrind),1),nrxn,nmetab);
% relJreg = sparse(regrind,regind,ones(length(regrind),1),nrxn,nmetab);

%Notes: numrsat, drsat, vact and vinhib are declared as arrays just for debugging. They
%will evetually be double scalars that are calculated for each reaction

for irxn = 1:n_rxn
% Initialization
    %indices for each reaction j
%     subsind = model.S(:,irxn) < 0;%substrate
%     prodind = model.S(:,irxn) > 0;%product
%     actind = model.SI(:,irxn) > 0;%activator
%     inhibind = model.SI(:,irxn) < 0;%inhibitor
%     
%     nsubs = length(find(subsind));
%     nprod = length(find(prodind));
%     nact = length(find(actind));
%     ninb = length(find(inhibind));  
%     
%     if ~isempty(biomassind)
%         if irxn ~= find(biomassind)
%             %Substrates & Products

%             %Activators/Inhibitors
    
  
    %Calculate Jacobian (called for each reaction)
    %Inputs: Ksubs, Kprod, KIact, KIinb, s_subs, s_prod, s_act, s_inhib,
    %        subs, pruds
    %Outputs: Jthermo, Jsat, Jreg
    %Jacobian = Jthermo + Jsat + Jreg
    
      
%     [Jsatrx,Jthermrx,Jregrx,...
%      relJsatrx,relJthermrx,relJregrx] = calcJacobian(subs,pruds,act,inhib,...
%                                           Ksubs,Kprod,KIact,KIinb,...
%                                           s_subs,s_prod,s_act,s_inhib,...
%                                           numrsat(irxn),drsatsubs,drsatprod,...
%                                           vact(irxn),vinhib(irxn),...
%                                           gamma(irxn));                          



end
% J = Jsat + Jtherm + Jreg;   


end