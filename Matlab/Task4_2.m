% Go to main() function
main();

function [] = main()
    % Аналитически решим уравнение
    dsolve('Dy = y^2 + 1', 'y(0) = 0')
    
    % Аналитическое решение данного дифференциального уравнения: y(t) = tan(t)
    
    % Нарисуем графики тангенса и решения, найденного численным методом
    % Тангенс - зелёный, численным методом - красный
    plot_solution(0, 0, 1, 0.001);
    figure;
    plot_solution(0, 0, pi/2, 0.001);
    figure;
    
    % На отрезках до Pi/2 метод Рунге-Кутты 4 порядка отрабатывает корректно
    
    % Посмотрим как он отработает для большего отрезка
    plot_solution(0, 0, pi/2 + 0.1, 0.001);
    
    % Дело в том, что в точке [Pi/2; 0] тангенс имеет ассимптоту, то есть
    % значение тангенса уходит в + бесконечность по Oy с левой стороны 
    % и в - бесконечность с правой сторны
    % При этом численное значение y(t) продолжает расти, что приводит к
    % бесконечному росту численного значение решения диффуры
end

% Решение дифференциального уравнения методом Рунге-Кутты 4 порядка
% Суммарная ошибка - O(delta^4) на конечном интервале
% [x0, y0] - начальная точка вычисления
% b - ищем решения на промежутке [x0, b]
% delta - шаг метода
function [] = plot_solution(x0, y0, b, delta)
    X = x0:delta:b;
    Y1 = tan(X);
    
    right_part = @(y) y^2 + 1; % правая часть задачи Коши [y' = f(x,y)]
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
