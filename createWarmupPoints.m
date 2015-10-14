function warmUp = createWarmupPoints(model,bounds,npts)
if nargin<3 || npts<2*size(model.S,1)
    %default # of warmup points
    npts = 2*size(model.S,1);
end

%set concentration bounds
if nargin<2
    bounds = setupMetLP(model);    
else
    
    %setup the initial LP problem to obtain cocnetrations
    
%     if isfield(bounds,'lb')
%         lb = bounds.lb;
%         bndflag_lb = 0;
%     end
%     if isfield(bounds,'ub')
%         ub = bounds.ub;
%         bndflag_ub = 0;
%     end
end

lb = assignConc(bounds.lb,model,bounds);
ub = assignConc(bounds.ub,model,bounds);
    
[nmets] = size(model.S,1);

warmUp = sparse(nmets,npts);
% model = setupMetLP(model);

validflag = 0;
ipt = 1;
%generate points
while ipt<npts/2
    %create random objective function    
%     prxnid = 0;
    bounds.cprod = rand(1,nmets)-0.5;
    
    %max/min objective
    if ipt<=nmets
%         prxnid = ipt;
        bounds.cprod = sparse(1,ipt,1,1,nmets);                
    end
    
    %get maximum and minimum for cprod(ipt)
    [LPmax,LPmin] = solvemetLP(bounds);
    
    %use max points
    if LPmax.flag>0
        xmax = separate_slack(LPmax.x,model,bounds);
%         xmax = LPmax.x;
        validflag = validflag+1;
    else
        validflag = validflag-1;
    end
    if LPmin.flag>0
        xmin = separate_slack(LPmin.x,model,bounds);
%         xmin = LPmin.x;
        validflag = validflag+1;
    else
        validflag = validflag-1;
    end
    
    %move points to within bounds
    xmax(xmax>ub) = ub(xmax>ub);
    xmax(xmax<lb) = lb(xmax<lb);
    
    xmin(xmin>ub) = ub(xmin>ub);
    xmin(xmin<lb) = lb(xmin<lb);
    
    %store points
    warmUp(:,2*ipt-1) = xmin;
    warmUp(:,2*ipt) = xmax;
    
    if validflag == 2
        ipt = ipt+1;
    else
        if validflag<0
            fprintf('Both min and max failed\n');
        elseif validflag == 0
            fprintf('Either min or max failed\n');
        end
    end  
end

centrepoint = mean(warmUp,2);

%moving in points
warmUp = warmUp*.99+.01*centrepoint*ones(1,npts);
            