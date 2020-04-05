% Go to main() function
main();

% Материалы:
% https://studme.org/199301/informatika/metod_runge_kutty_chetvertogo_poryadka
% http://www.simumath.net/library/book.html?code=Dif_Ur_example

function [] = main()
    % Решим уравнение [y' = sqrt(1 - y^2)] с начальными условиями [y(0) = 0]
    % dy/dx = sqrt(1 - y^2)
    % dy/sqrt(1 - y^2) = dx
    % integral(dy/sqrt(1 - y^2)) = integral(dx)
    % arcsin(y) = x + Const
    % y = sin(x + Const)
    % Начальное условие: [y(0) = 0]
    % [y(0) = sin(Const)] => [Const = Pi*n]
    % n - любое целое число (в т.ч. и 0)
    % чтд.
    
    % Также проверим встроенной в matlab функцией
    dsolve('Dy=sqrt(1-y*y)', 'y(0) = 0')
    
    % Нарисуем графики синуса и решения, найденного численным методом
    % Синус - зелёный, численным методом - красный
    plot_solution(0, 0, pi / 2, 0.1);
    figure;
    plot_solution(0, 0, 20, 0.1);
    
    % Итог:
    % Поскольку в правой части присутствует квадратный корень, область
    % значений функции y(x) (в области рациональных чисел) ограничена
    % Точнее - |y(x)| <= 1
    % Соответственно, как только значение квадрата функции
    % (т.е. самой функции) превышает 1 возникают комплексные значения y
    % Вместо возврата ошибки Matlab просто игнорирует мнимую часть y
    % Соответственно, y(x) просто продолжает расти
end

% Решение дифференциального уравнения методом Рунге-Кутты 4 порядка
% Суммарная ошибка - O(delta^4) на конечном интервале
% [x0, y0] - начальная точка вычисления
% b - ищем решения на промежутке [x0, b]
% delta - шаг метода
function [] = plot_solution(x0, y0, b, delta)
    X = x0:delta:b;
    Y1 = sin(X);
    
    right_part = @(y) sqrt(1 - y^2); % правая часть задачи Коши [y' = f(x,y)]
    y = y0;
    Y2 = y;
    % Итерационная часть метода
    for x = (x0 + delta):delta:b
        y = runge_kutta(right_part, y, delta);
        Y2 = [Y2 y];
    end
    
    plot(X, Y1, 'g', X, Y2, 'r');
end

% Реализация шага метода Рунге-Кутты
% right_part - правая часть задачи Коши [y' = f(x,y)]
% y - значение y на данном шаге
% Полученное следующее значение y
function next_y = runge_kutta(right_part, y, delta)
    k1 = right_part(y);
    k2 = right_part(y + delta / 2 * k1);
    k3 = right_part(y + delta / 2 * k2);
    k4 = right_part(y + delta * k3);
    next_y = y + delta / 6 * (k1 + 2 * k2 + 2 * k3 + k4);
end
