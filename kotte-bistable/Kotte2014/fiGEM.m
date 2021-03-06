function dy = fiGEM(t,x)

% T = 0.1;
% METH = 1e4;
% gal1 = 1e-8;

dy = zeros(4,1);

% dy(1) = 0.134.*gal1./(5000.^2+gal1.^2)-(9.26e-4+T).*x(1);
% dy(2) = 0.416.*x(1)./(1+(x(4)./1e4).^2)-(2.5e-4+T).*x(2);
% dy(3) = 0.584./(1+(METH/5e3).^4)-(2.45e-4+T)*x(3);
% dy(4) = 0.418.*x(3)./(1+(x(2)./1e4).^2)-(2.5e-4+T)*x(4);
a = 0.8; % a = 3.33
c = 1; % c = 4;

dy(1) = a*x(1)-x(2);
dy(2) = x(1)-x(3);
dy(3) = x(2)^3-c*x(3);