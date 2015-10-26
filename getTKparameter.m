function [] = getTKparameter(model,pvec,mc,Vex)


h2o = find(strcmpi(model.mets,'h2o[c]'));
pic = find(strcmpi(model.mets,'pi[c]'));
pie = find(strcmpi(model.mets,'pi[e]'));
hc = find(strcmpi(model.mets,'h[c]'));
he = find(strcmpi(model.mets,'h[e]'));

for irxn = 1:length(Vex)
    if model.Vss(Vex(irxn))~=0
        %kinetics - substrate and product
        sbid = logical(model.S(:,Vex(irxn))<0);
        prid = logical(model.S(:,Vex(irxn))>0);
        if any(sbid) && any(prid)
            if ~strcmpi(model.rxns{Vex(irxn)},'h2ot')
                sbid(h2o) = 0;
            end
            if ~strcmpi(model.rxns{Vex(irxn)},'PIt2r')
                sbid([pic pie hc he]) = 0;
                prid([pic pie hc he]) = 0;
            else
                sbid([hc he]) = 0;
                prid([hc he]) = 0;
            end
            lb = [0;0];
            ub = [Inf;Inf];
            x0 = [1;1];
            [x,fval,exitflag,output,lambda] =...
            fmincon(@vflux,x0,[],[],[],[],lb,ub);
            pvec.kcat_fwd(Vex(irxn)) = x(1);
            pvec.kcat_bkw(Vex(irxn)) = x(2);
            pvec.Vmax(Vex(irxn)) = 1;
            flux = TKinetics(model,pvec,mc,Vex(irxn));
            fprintf('%3.6g',x);
        end
    end
end

function ss_flux = vflux(x)
kcatfwd = x(1);
kcatbkw = x(2);

if model.rev(Vex(irxn))
    flux = (kcatfwd*mc(sbid)-kcatbkw*mc(prid))./...
        (1+mc(sbid)+mc(prid));
elseif ~model.rev(Vex(irxn))
    flux = (kcatfwd*mc(sbid))./...
        (1+mc(sbid));
end

ss_flux = (flux-model.Vss(Vex(irxn)))^2;


end
end

    