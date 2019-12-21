% Go to main() function
main();

function [] = main()
    load('data.mat');
    plot(V, b1f, 'ro-', V, b2f, 'go-');
    dispAnsw(V, b1f, 0.03);
    dispAnsw(V, b2f, 0.075);
end

function [] = dispAnsw(x, y, eps)
    error = 1;
    n = 1;
    while error > eps
        [coef, func, error] = polinomApprox(x, y, n);
        n = n + 1;
    end
    disp(coef);
    X = 0:11;
    figure;
    plot(x, y, 'r.', X, arrayfun(func, X));
end

function [coef, func, error] = polinomApprox(x, y, n)
    deg = 0:n-1;
    A = (x.').^ deg;
    A_T = A';
    coef = inv(A_T * A) * A_T * y.';
    func = @(x_val) sum((x_val .^ deg) .* coef.');
    error = sum(abs(arrayfun(func, x) - y) ./ abs(y)) / length(x);
end
