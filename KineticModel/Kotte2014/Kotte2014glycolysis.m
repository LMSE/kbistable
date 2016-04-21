function out = Kotte2014glycolysis
out{1} = @init;
out{2} = @fun_eval;
out{3} = [];
out{4} = [];
out{5} = [];
out{6} = [];
out{7} = [];
out{8} = [];
out{9} = [];

function dM = fun_eval(t,kmrgd,model,kEcat,KEacetate,...
                         KFbpFBP,vFbpmax,Lfbp,KFbpPEP,...
                         vEXmax,KEXPEP,...
                         vemax,KeFBP,ne,acetate,d)
pvec = [kEcat,KEacetate,...
        KFbpFBP,vFbpmax,Lfbp,KFbpPEP,...
        vEXmax,KEXPEP,...
        vemax,KeFBP,ne,acetate,d];
    
dM = Kotte_givenNLAE(kmrgd,model,pvec);


function [tspan,y0,options] = init
handles = feval(Kotte2014glycolysis);

% obtain initial steady states
M = zeros(3,1);
M(1)  = 1;      % E
M(2)  = 0.001;   % PEP
M(3)  = 10;   % FBP

% substitute this with SUNDIALS
[~,yout] = ode45(@Kotte_glycolysis,0:0.1:30,M);
y0 = yout(end,:);
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),...
                 'Hessians',handles(4),'HessiansP',handles(5));
tspan = [0 10];

function jac = jacobian(t,kmrgd,kEcat,KEacetate,...
                         KFbpFBP,vFbpmax,Lfbp,KFbpPEP,...
                         vEXmax,KEXPEP,...
                         vemax,KeFBP,ne,acetate,d)

function jacp = jacobianp(t,kmrgd,kEcat,KEacetate,...
                         KFbpFBP,vFbpmax,Lfbp,KFbpPEP,...
                         vEXmax,KEXPEP,...
                         vemax,KeFBP,ne,acetate,d)      
                     
function jacp = hessians(t,kmrgd,kEcat,KEacetate,...
                         KFbpFBP,vFbpmax,Lfbp,KFbpPEP,...
                         vEXmax,KEXPEP,...
                         vemax,KeFBP,ne,acetate,d)           
                     
function jacp = hessiansp(t,kmrgd,kEcat,KEacetate,...
                         KFbpFBP,vFbpmax,Lfbp,KFbpPEP,...
                         vEXmax,KEXPEP,...
                         vemax,KeFBP,ne,acetate,d)      

function jacp = der3(t,kmrgd,kEcat,KEacetate,...
                         KFbpFBP,vFbpmax,Lfbp,KFbpPEP,...
                         vEXmax,KEXPEP,...
                         vemax,KeFBP,ne,acetate,d)    
                     
function jacp = der4(t,kmrgd,kEcat,KEacetate,...
                         KFbpFBP,vFbpmax,Lfbp,KFbpPEP,...
                         vEXmax,KEXPEP,...
                         vemax,KeFBP,ne,acetate,d)    
                     
function jacp = der5(t,kmrgd,kEcat,KEacetate,...
                         KFbpFBP,vFbpmax,Lfbp,KFbpPEP,...
                         vEXmax,KEXPEP,...
                         vemax,KeFBP,ne,acetate,d)                         




