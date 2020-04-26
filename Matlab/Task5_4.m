% Go to main() function
main();

function [] = main()
    % Аналитически решим уравнение:
    % y'' + 100000.001y' + 100y = 0
    solution = dsolve('D2y + 100000.001 * Dy + 100*y = 0');
    disp(solution);
    
    % Полученное общее решение:
    % C1*exp(-x/1000) + C2*exp(-100000*x)
    
    % Проиллюстрируем геометрическое предстваление полученного общего
    % решения, построив несколько частных решений (для разных C1 и C2)
    
    global analytical_solution
    analytical_solution = @(c1, c2, x) c1 * exp(-x/1000) + c2 * exp(-100000*x);
    
    X = linspace(-0.00002, 0.00005, 100);
    hold on;
    for c1 = -1:1:1
        for c2 = -1:1:1
            plot(X, analytical_solution(c1, c2, X));
        end
    end
    legend('c1 = -1, c2 = -1', 'c1 = -1, c2 = 0', 'c1 = -1, c2 = 1', ...
        'c1 = 0, c2 = -1', 'c1 = 0, c2 = 0', 'c1 = 0, c2 = 1', 'c1 = 1, c2 = -1', ...
        'c1 = 1, c2 = 0', 'c1 = 1, c2 = 1');
    title("Общее решение y'' + 100000.001*y' + 100*y = 0");
    hold off;
    
    figure;
    
    X = linspace(-10000, 10000, 100000);
    hold on;
    for c1 = -1:1:1
        for c2 = -1:1:1
            plot(X, analytical_solution(c1, c2, X));
        end
    end
    legend('c1 = -1, c2 = -1', 'c1 = -1, c2 = 0', 'c1 = -1, c2 = 1', ...
        'c1 = 0, c2 = -1', 'c1 = 0, c2 = 0', 'c1 = 0, c2 = 1', 'c1 = 1, c2 = -1', ...
        'c1 = 1, c2 = 0', 'c1 = 1, c2 = 1');
    title("Общее решение y'' + 100000.001*y' + 100*y = 0");
    hold off;
    figure;
    
    % Рассмотрим частные решения:
    % 1) c1 = -1, c2 = 1
    % 2) c1 = 1, c2 = -1
    % Как видно из графика общего решения на больших значениях x, 
    % все частные решения разделены на 3 группы. Указанные выше частные 
    % решения соответсвуют двум этим группам.
    
    % Сначала для наглядности посмотрим графики данных частных решений
    
    X = linspace(-10000, 10000, 100000);
    hold on;
    plot(X, analytical_solution(-1, 1, X));
    plot(X, analytical_solution(1, -1, X));
    title("Частные решения y'' + 100000.001*y' + 100*y = 0");
    legend('Частное решение: -1 * exp(-x/1000) + 1 * exp(-100000*x)', ...
        'Частное решение: 1 * exp(-x/1000) - 1 * exp(-100000*x)');
    hold off;
    figure;
    
    % Для численного решения ОДУ 2 порядка необходимо найти начальные
    % условия, соответствующие рассматриваемым коэффициентам.
    % Будем для простоты рассматривать начальные условия вида:
    % y(0) = ? , y'(0) = ?
    
    % Общее решение:
    % y(x) = c1 * e ^ (-100000 * x) + c2 * e ^ (-0.001 * x)
    % y'(x) = -c1 * 100000 * e ^ (-100000 * x) - c2 * 0.001 * e ^ (-0.001 * x)

    % Для c1 = -1, c2 = 1:
    % y(0) = 0
    % y'(0) = 100000 - 0.001 = 99999.999
    
    % Для c1 = 1, c2 = -1:
    % y(0) = 0
    % y'(0) = -100000 + 0.001 = -99999.999
    
    % Представим ОДУ 2 порядка как систему ОДУ 1 порядка

    % [c1 = -1, c2 = 1]:
    % y' = z
    % z' = -100000.001*z - 100*y
    % С начальными условиями:
    % y(0) = 0
    % z(0) = 99999.999
    
    % [c1 = 1, c2 = -1]:
    % y' = z
    % z' = -100000.001*z - 100*y
    % С начальными условиями:
    % y(0) = 0
    % z(0) = -99999.999
    
    global right_y right_z start_y start_z
    right_y = @(x,y,z) z;
    right_z = @(x,y,z) -100000.001*z - 100*y;
    
    % Рассмотрим сначала [c1 = -1, c2 = 1]
    
    start_y = [0, 1.0];
    start_z = [0, 99999.999];
    
    % Неявный метод
    
    res = euler(500, 0.01, -1, 1, 'implicit');
    
    plot(res(1, :), res(4, :), 'or');
    title('Ошибка; Неявный метод; c1 = -1, c2 = 1');
    xlabel('x');
    ylabel('Ошибка (аналитическое решение - численное решение)');
    figure;
    
    X = linspace(0, 500, 10000);
    hold on;
    plot(X, analytical_solution(-1, 1, X), 'r');
    plot(res(1, :), res(3, :), 'oy');
    legend('аналитическое решение', 'численное решение');
    title('y(x); Неявный метод; c1 = -1, c2 = 1');
    xlabel('x');
    ylabel('y');
    hold off;
    figure;
    
    % Явный метод
    
    res = euler(500, 0.01, -1, 1, 'explicit');
    
    plot(res(1, :), res(4, :), 'or');
    title('Ошибка; Явный метод; c1 = -1, c2 = 1');
    xlabel('x');
    ylabel('Ошибка (аналитическое решение - численное решение)');
    figure;
    
    X = linspace(0, 500, 10000);
    hold on;
    plot(X, analytical_solution(-1, 1, X), 'r');
    plot(res(1, :), res(3, :), 'oy');
    legend('аналитическое решение', 'численное решение');
    title('y(x); Явный метод; c1 = -1, c2 = 1');
    xlabel('x');
    ylabel('y');
    hold off;
    figure;
    
    % Теперь рассмотрим [c1 = 1, c2 = -1]
    
    start_y = [0, 1.0];
    start_z = [0, -99999.999];
    
    % Неявный метод
    
    res = euler(500, 0.01, 1, -1, 'implicit');
    
    plot(res(1, :), res(4, :), 'or');
    title('Ошибка; Неявный метод; c1 = 1, c2 = -1');
    xlabel('x');
    ylabel('Ошибка (аналитическое решение - численное решение)');
    figure;
    
    X = linspace(0, 500, 10000);
    hold on;
    plot(X, analytical_solution(1, -1, X), 'r');
    plot(res(1, :), res(3, :), 'oy');
    legend('аналитическое решение', 'численное решение');
    title('y(x); Неявный метод; c1 = 1, c2 = -1');
    xlabel('x');
    ylabel('y');
    hold off;
    figure;
    
    % Явный метод
    
    res = euler(500, 0.01, 1, -1, 'explicit');
    
    plot(res(1, :), res(4, :), 'or');
    title('Ошибка; Явный метод; c1 = 1, c2 = -1');
    xlabel('x');
    ylabel('Ошибка (аналитическое решение - численное решение)');
    figure;
    
    X = linspace(0, 500, 10000);
    hold on;
    plot(X, analytical_solution(1, -1, X), 'r');
    plot(res(1, :), res(3, :), 'oy');
    legend('аналитическое решение', 'численное решение');
    title('y(x); Явный метод; c1 = 1, c2 = -1');
    xlabel('x');
    ylabel('y');
    hold off;
    
    % Как видно, явный метод работает куда хуже (фактически вообще не работает)
    % При этом неявный метод работает лучше, хотя не сказать, что хорошо,
    % поскольку он почти сразу уходит в Ox
    % При этом неявные методы работают много лучше с жёсткими системами
    % уравнений
    % Само понятие жёсткости как раз обычно подразумевает то, что для
    % получения корректных результатов необходимо использовать малый шаг
    % численного интегрирования
    % К сожалению, вероятно в данном случае шаг должен быть куда меньше
    % используемого мной, но в этом случае резко увеличивается количество
    % необходимых вычислений и поиск более подходящего шага оказался
    % слишком длительным процессом, поэтому я решил ограничиться
    % иллюстрацией одного примера.
end

% Метод Эйлера (явный или неявный)
% Поиск решений на отрезке [0, b] с шагом delta
% method определяет используемый метод:
% 1) explicit - явный
% 2) implicit - неявный
% Возвращает X, Y и ERR - ошибка на каждом значении из X:
% ERR = ANALYTICAL(X) - EULER_EXPLICT(X)
% c1 и c2 - коэффициенты для analytical_solution()
function res = euler(b, delta, c1, c2, method)
    global right_y right_z start_y start_z analytical_solution
    
    z = start_z(2);
    y = start_y(2);
    
    X = start_z(1):delta:b;
    Z = z;
    Y = y;
    ERR = 0;
    
    for x = (start_z(1)+delta):delta:b
        if method == 'explicit'
            next_val = euler_explicit_step(x, y, z, delta);
        else
            next_val = euler_implicit_step(x, y, z, delta);
        end
        z = next_val(1);
        y = next_val(2);
        Z = [Z z];
        Y = [Y y];
        err = analytical_solution(c1, c2, x) - y;
        ERR = [ERR err];
    end
    
    res = [X; Z; Y; ERR];
end

% Реализация шага явного метода Эйлера
function next_val = euler_explicit_step(x, y, z, delta)
    global right_y right_z
    next_y = y + delta * right_y(x, y, z);
    next_z = z + delta * right_z(x, y, z);
    next_val = [next_z next_y];
end

% Реализация шага неявного метода Эйлера
function next_val = euler_implicit_step(x, y, z, delta)
    % y_(i+1) = y_i + delta * z_(i+1)
    % z_(i+1) = z_i + delta * (-100000.001*z_(i+1) - 100*y_(i+1))
    % =>
    % y_(i+1) = y_i + delta * z_(i+1)
    % z_(i+1) = z_i - 100000.001 * delta * z_(i+1) - 100 * y_(i+1)
    % =>
    % y_(i+1) = y_i + delta * z_(i+1)
    % z_(i+1) = z_i - 100000.001 * delta * z_(i+1) - 100 * (y_i + delta * z_(i+1))
    % =>
    % y_(i+1) = y_i + delta * z_(i+1)
    % z_(i+1) = z_i - 100000.001 * delta * z_(i+1) - 100 * y_i - 100 * delta * z_(i+1)
    % =>
    % y_(i+1) = y_i + delta * z_(i+1)
    % z_(i+1) * (1 + 100000.001 * delta + 100 * delta) = z_i - 100 * y_i
    % =>
    % y_(i+1) = y_i + delta * z_(i+1)
    % z_(i+1) = (z_i - 100 * y_i) / (1 + 100100.001 * delta)
    next_z = (z - 100 * y) / (1 + 100100.001 * delta);
    next_y = y + delta * next_z;
    next_val = [next_z next_y];
end
