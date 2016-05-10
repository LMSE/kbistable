function dM = Kotte_givenNLAE(kmrgd,model,pvec)

d = pvec(13);
dM = zeros(3,1);
if ~isempty(model)
    PM = cons(model.PM,kmrgd);
    allmc = [kmrgd;PM];
else
    allmc = kmrgd;
end
dM = cons(dM,allmc);
flux = Kotte_givenFlux(allmc,pvec,model);
% differential equations
% PEP
dM(1) = flux(1) - flux(4) - flux(5);
% FBP
dM(2) = flux(4) - flux(3);
% enzymes
% E
dM(3) = flux(2) - d*allmc(3);