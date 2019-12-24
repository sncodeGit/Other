% Go to main() function
main();

function main()
    a = 1;
    b = 2;
    x_l = 2;
    x_r = 2.5; 
    t = linspace(1, 2, 7);
    tt = linspace(1, 2, 100);
    x = fminsearch(@(x)(builtin_integral(x, t, x_l, x_r)), [0 0 0 0 0]);
    x = [x_l x x_r];
    disp(x)
    plot(tt, tt + 1./tt, "b", t,x,'ro');
end

function res=builtin_integral(x,t,x_l,x_r)
    xt = [x_l x x_r];
	xt_coef = polyfit(t, xt, length(xt)); 
    dxt_coef = polyder(xt_coef); 
    res = integral(@(t)foo(t,xt_coef,dxt_coef),1,2);
end

function res=foo(t,xt,dxt)
	res = t .* polyval(dxt,t).^2 + polyval(xt,t).^2 ./ t;
end
