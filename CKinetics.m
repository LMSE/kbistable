function [flux,vflux] = CKinetics(model,pvec,mc,Vind)
S = model.S;
nrxn = model.nt_rxn;
K = pvec.K;
kfwd = pvec.kcat_fwd;
kbkw = pvec.kcat_bkw;
Vmax = pvec.Vmax;

vflux = zeros(nrxn,1); 
flux = zeros(nrxn,1);

%eliminate consideration for excess cofators
%pi[c],pi[e],h[c],h[e],h2o[c]
pic = find(strcmpi(model.mets,'pi[c]'));
pie = find(strcmpi(model.mets,'pi[e]'));
hc = find(strcmpi(model.mets,'h[c]'));
he = find(strcmpi(model.mets,'h[e]'));
h2o = find(strcmpi(model.mets,'h2o[c]'));


for irxn = 1:length(Vind)
    sbid = S(:,Vind(irxn))<0;
    prid = S(:,Vind(irxn))>0; 
    
    if any(sbid) && any(prid)
        
        %Numerator - 1.6
        if model.rev(Vind(irxn))%reversible
            if all(mc(sbid)>0)&&all(mc(prid)>0)
                sbid([pic pie hc he h2o]) = 0;
                prid([pic pie hc he h2o]) = 0;
                Sb = S(sbid,Vind(irxn));
                Sp = -S(prid,Vind(irxn));
                nr_flux = kfwd(Vind(irxn))*prod(mc(sbid)./K(sbid,Vind(irxn)))...
                          -kbkw(Vind(irxn))*prod(mc(prid)./K(prid,Vind(irxn)));
            elseif all(mc(sbid)>0)
                sbid([pic pie hc he h2o]) = 0;
                prid([pic pie hc he h2o]) = 0;
                Sb = S(sbid,Vind(irxn));
                Sp = -S(prid,Vind(irxn));
                %Numerator - 1.6
                nr_flux = kfwd(Vind(irxn))*prod(mc(sbid)./K(sbid,Vind(irxn)));
            elseif all(mc(prid)>0)
                sbid([pic pie hc he h2o]) = 0;
                prid([pic pie hc he h2o]) = 0;
                Sb = S(sbid,Vind(irxn));
                Sp = -S(prid,Vind(irxn));
                nr_flux = -kbkw(Vind(irxn))*prod(mc(prid)./K(prid,Vind(irxn)));
            else
                sbid([pic pie hc he h2o]) = 0;
                prid([pic pie hc he h2o]) = 0;
                Sb = S(sbid,Vind(irxn));
                Sp = -S(prid,Vind(irxn));
                nr_flux = 0;
            end
        elseif ~model.rev(Vind(irxn))%irreversible
            if all(mc(sbid)>0)
                sbid([pic pie hc he h2o]) = 0;
                prid([pic pie hc he h2o]) = 0;
                Sb = S(sbid,Vind(irxn));    
                Sp = -S(prid,Vind(irxn));
                nr_flux = kfwd(Vind(irxn))*prod(mc(sbid)./K(sbid,Vind(irxn)));
            else
                sbid([pic pie hc he h2o]) = 0;
                prid([pic pie hc he h2o]) = 0;
                Sb = S(sbid,Vind(irxn));
                Sp = -S(prid,Vind(irxn));
                nr_flux = 0;
            end
        end
        
        %Denominator - 1.6
        %dr_sb
        dr_sb = 1+mc(sbid)./K(sbid,Vind(irxn));
        for j = 1:length(find(sbid))
            for si = 2:Sb(j)
                dr_sb(j) = dr_sb(j) + dr_sb(j)^si;                
            end
        end
        
        %dr_pr
        dr_pr = 1+mc(prid)./K(prid,Vind(irxn));
        for j = 1:length(find(prid))
            for si = 2:Sp(j)
                dr_pr(j) = dr_pr(j)+dr_pr(j)^si;
            end
        end
        
        if model.rev(Vind(irxn))
            dr_flux = prod(dr_sb)+prod(dr_pr)-1;
        elseif ~model.rev(Vind(irxn))
            dr_flux = prod(dr_sb);
        end
        vflux(Vind(irxn)) = scale_flux(nr_flux/dr_flux);
    else
        vflux(Vind(irxn)) = 0;
    end
    flux(Vind(irxn)) = Vmax(Vind(irxn))*vflux(Vind(irxn));
end
flux = flux(Vind);
vflux = vflux(Vind);