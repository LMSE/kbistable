function Nflux = changeFlux(model,initflux,VMCpos,VMCneg,allFlux)
%change flux value by the given percentage in VMC
if nargin<5
    allFlux = 0;
end
if nargin<4
    VMCneg = struct([]);
end
if nargin < 3
    fprintf('Nothing to change\n');
    Nflux = initval;
    return
end

ntrxn = model.nt_rxn;
Nflux = initflux;
if ~isempty(VMCneg)
    [fx_lb,fx_ub] = assignFlux(model,VMCneg);
    zro_met = find(initflux==0);
    if any(fx_lb(zro_met))
        idx = zro_met(logical(fx_lb(zro_met)));
        fprintf('%s is already zero. \n %s cannot be below zero',model.rxns(idx));
        error('initcond:ivalChk','Normalized Initial conditions cannot be negative');
    end
    if isempty(fx_ub)
        Nflux = Nflux-Nflux.*fx_lb/100;
        Nflux(initflux==0) = 0;
    elseif any(fx_lb>0) && any(fx_ub>0)
        fxid = find(fx_lb);
        for id = 1:length(fxid)
            rnd_dist =...
            random(makedist('Uniform','lower',fx_lb(fxid(id))/100,...
                                      'upper',fx_ub(fxid(id))/100),...
                                      length(fx_lb),1);
            Nflux(fxid(id)) = Nflux(fxid(id)).*rnd_dist(fxid(id));
        end
    end
end

if ~isempty(VMCpos)
    [fx_lb,fx_ub] = assignFlux(model,VMCpos);
    if isempty(fx_ub)
        Nflux = Nflux + Nflux.*fx_lb/100;
    elseif any(fx_lb>0) && any(fx_ub>0)
        fxid = find(fx_lb);
        for id = 1:length(fxid)
            rnd_dist =...
            random(makedist('Uniform','lower',fx_lb(fxid(id))/100,...
                                      'upper',fx_ub(fxid(id))/100),...
                                      1,1); 
            Nflux(fxid(id)) = Nflux(fxid(id)).*rnd_dist;
        end
    end
end

if allFlux
    pd = makedist('Uniform','lower',-10,'upper',10);
    [fx_lb,fx_ub] = assignFlux(model,[]);
    if isempty(fx_ub)
        nt_sign = sign(random(pd,length(fx_lb),1));    
        rnd_dist = random(makedist('Uniform'),length(fx_lb),1);
        Nflux = Nflux + nt_sign.*Nflux.*rnd_dist*0.5;
    elseif ~isempty(fx_lb) && ~isempty(fx_ub)
        nt_sign = sign(random(pd,length(fx_lb),1));
        if any(fx_lb>0) && any(fx_ub>0)
            rnd_dist = random(makedist('Uniform','lower',fx_lb/100,'upper',fx_ub/100),length(fx_lb),1);
            Nflux = Nflux.*rnd_dist;
        elseif ~any(fx_lb>0) && ~any(fx_ub>0)
            rnd_dist = random(makedist('Uniform'),length(fx_lb),1);
            Nflux = Nflux + nt_sign.*Nflux.*rnd_dist;
        end
    end
end