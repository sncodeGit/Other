% Go to main() function
main();

function [] = main()
    % Аналитически решим уравнение
    dsolve('Dy = y^(1/3)', 'y(0) = 0')
    
    % Полученный ответ:
    % y(x) = ((2*x)/3)^(3/2)
    
    % Построим графики решения, найденного методом Рунге-Кутты 4 порядка и
    % график найденного аналитически решения для сравнения
    
    X = 0:0.1:10;
    Y = ((2*X)/3).^(3/2);
    plot(X, Y);
    title('Analytically');
    figure;
    plot_solution(0, 0, 10, 0.1)
    
    figure;
    
    X = 0:0.1:10000;
    Y = ((2*X)/3).^(3/2);
    plot(X, Y);
    title('Analytically');
    figure;
    plot_solution(0, 0, 10000, 0.1);
    
    % Как видно, найденные решения отличаются.
    % Без ограничений на гладкость правой части задачи Коши нельзя
    % однозначно судить о единственности её решения.
    % В данном случае функция f = y^(1/3) не гладкая, поскольку её производная в нуле
    % не определена. При этом ноль входит в область рассмотрения данной задачи Коши.
    % Соответственно, в данном случае метод Рунге-Кутты обнаружил другое решение,
    % нежели чем функция dsolve (насколько я вижу тождественное решение [y(x) = 0] 
    % по определению может считаться решением дифференциального уравнения).
end

% Решение дифференциального уравнения методом Рунге-Кутты 4 порядка
% Суммарная ошибка - O(delta^4) на конечном интервале
% [x0, y0] - начальная точка вычисления
% b - ищем решения на промежутке [x0, b]
% delta - шаг метода
function [] = plot_solution(x0, y0, b, delta)
    X = x0:delta:b;
    
    right_part = @(y) y^(1.0/3.0); % правая часть задачи Коши [y' = f(x,y)]
    y = y0;
    Y = y;
    % Итерационная часть метода
    for x = (x0 + delta):delta:b
        y = runge_kutta(right_part, y, delta);
        Y = [Y y];
    end
    
    plot(X, Y);
    title('Runge-Kutta');
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
    disp((k1 + 2 * k2 + 2 * k3 + k4));
end
