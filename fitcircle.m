% Fitting a function according to:
% (x-xc)^2+(y-yc)^2=R^2
% x^2+y^2 -2*xc*x -2*yc*y +xc^2+yc^2-R^2 = 0
% x^2+y^2 +a(1)*x +a(2)*y +a(3) = 0
%
% Input:
% - x and y coordinates
%
% Output:
% - center pOint coordinates xc, yc
% - radius R
% - fit parameters a
%
%%%%%%%%%%%%%%%%%%

function   [xc,yc,R,a] = fitcircle(x,y)

    x=x(:); y=y(:); %make column vector
    a=[x y ones(size(x))]\(-x.^2-y.^2); %solve system
    xc = -.5*a(1);
    yc = -.5*a(2);
    R  =  sqrt((a(1)^2+a(2)^2)/4-a(3));

end