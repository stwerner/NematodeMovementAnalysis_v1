%interpolation with n points

function out = myinterpolfunction(yvalue, xvalue, n, method)

    Dx = diff(xvalue);                 
    Dy = diff(yvalue);                 
    s = sqrt(Dx.^2 + Dy.^2);     
    s = [0; cumsum(s)];
    s = s./s(end);
    doublepos = find(diff(s)==0);
    scorr=s; scorr(doublepos)=[];
    xvaluecorr=xvalue; xvaluecorr(doublepos)=[];
    yvaluecorr=yvalue; yvaluecorr(doublepos)=[];
    xvalue = interp1(scorr,xvaluecorr,0:1/n:1,method);
    yvalue = interp1(scorr,yvaluecorr,0:1/n:1,method);
    out = [yvalue' xvalue'];

end