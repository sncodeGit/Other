% Go to main() function
main();

function [] = main()
    load('data11.mat');
    figure;
    plot(tt, xx, 'ro-', tt, yy, 'go-');
    dispAnsw(tt, xx);
    dispAnsw(tt, yy)
end

function [] = dispAnsw(x, y)
    [coef, func] = approxFirst(x, y);
    disp(coef);
    figure;
    X = linspace(0, 100, 10000);
    plot(x, y, 'r.', X, arrayfun(func, X), 'g-');
end

function [coef ,func] = approxFirst(x, y)
    f1 = @(x)1;
    f2 = @(x)exp(-5 * x) * sin(5 * x);
    f3 = @(x) exp(-5 * x) * cos(5 * x);
    A = horzcat(arrayfun(f1, x), arrayfun(f2, x), arrayfun(f3, x));
    A_T = A';
    coef = inv(A_T * A) * A_T * y;
    func = @(x_val) f1(x_val) * coef(1) + f2(x_val) * coef(2) + f3(x_val) * coef(3);
end

function [coef, func] = approxSecond(x, y)
    f1 = @(x)1;
    f2 = @(x)exp(-5 * x) * cos(5 * x);
    f3 = @(x) -1 * exp(-5 * x) * sin(5 * x);
    A = horzcat(arrayfun(f1, x), arrayfun(f2, x), arrayfun(f3, x));
    A_T = A';
    coef = inv(A_T * A) * A_T * y;
    func = @(x_val) f1(x_val) * coef(1) + f2(x_val) * coef(2) + f3(x_val) * coef(3);
end
