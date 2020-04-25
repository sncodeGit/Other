% Go to main() function
main();

% https://amd.spbstu.ru/userfiles/files/methodical_material/grigoriev_bs_chislennoe_reshenie_zhestkikh_sistem_odu_2016.pdf

function [] = main()
    % Найдём аналитическое решение диффуры y' = -10000 * y
    solution = dsolve('Dy = -10000 * y');
    disp(solution);
    
    % Найденное аналитическое решение:
    % y(x) = const * e^(-10000*x)
    
    % Для исследования жёсткости положим const = 1
    % То есть: 
    % y(x) = e^(-10000*x)
    % y(0) = 1
    
    global analytical_y right_dy
    analytical_y = @(x) exp(-10000 * x);
    right_dy = @(x, y) -10000 * y;
    
    % Построим несколько графиков ошибок решений, посчитанных численным
    % методом.
    % Ошибка высчитывается как разница между значением найденного
    % аналитически решения и решения, найденного численным методом в
    % рассматриваемой точке x.
    
    disp_solution(0.1, 0.01);
    figure;
    disp_solution(0.1, 0.001);
    figure;
    disp_solution(0.02, 0.0001);
    figure;
    disp_solution(0.03, 0.000001);
end

% b - граница рассматриваемого отрезка
% delta - шаг
function [] = disp_solution(b, delta)
    X = linspace(0, b, 1000);
    res_explicit = euler(b, delta, 'explicit');
    res_implicit = euler(b, delta, 'implicit');
    
    hold on;
    plot(res_explicit(1, :), res_explicit(3, :), 'ob');
    plot(res_implicit(1, :), res_implicit(3, :), '+r');
    plot(X, X*0, 'y');
    legend('явный метод', 'неявный метод');
    hold off;
    title("Шаг: " + num2str(delta) + ", Отрезок: [0;" + num2str(b) + "]");
    xlabel('x');
    ylabel('Ошибка (аналитическое решение - численное решение)');
    figure;
    
    plot(res_explicit(1, :), res_explicit(3, :), 'ob');
    title("Шаг: " + num2str(delta) + ", Отрезок: [0;" + num2str(b) + "]" + ...
        ", Явный метод");
    xlabel('x');
    ylabel('Ошибка (аналитическое решение - численное решение)');
    figure;
    
    plot(res_implicit(1, :), res_implicit(3, :), '+r');
    title("Шаг: " + num2str(delta) + ", Отрезок: [0;" + num2str(b) + "]" + ...
        ", Неявный метод");
    xlabel('x');
    ylabel('Ошибка (аналитическое решение - численное решение)');
    
    % Как видно, даже с шагом 0.01 неявный метод Эйлера работает неплохо
    % Особенно в сравнении с явным методом Эйлера, который начинает
    % работать с приемлемой точностью с шага, примерно на 2 порядка
    % меньшим шага неявного метода Эйлера.
    
    % Вообще говоря решение следующей системы диффур:
    % 1) y' = ay
    % 2) y(0) = c
    % вида y(x) = c * e^(a*x)
    % устойчиво при Re(a) <= 0 и неустойчиво при Re(a) > 0 (обобщая на случай 
    % комплексных чисел)
    
    % Условием устойчивости явного метода Эйлера является:
    % delta <= 2 / abs(Re(a))
    % то есть delta <= 2 / 10000, то есть delta <= 0.0002
    
    % Поведение явного метода, к примеру, при шаге 0.01 является
    % иллюстрацией неустойчивости метода.
    
    % Условием устойчивости неявного метода Эйлера является:
    % abs(1 / (1 - delta*a)) <= 1
    % Видно, что неявный метод Эйлера устойчив при любом неположительном a
    % В данном случае a < 0, поэтому неявный метод Эйлера в данном случае
    % предпочтительнее
end

% Метод Эйлера (явный или неявный)
% Поиск решений на отрезке [0, b] с шагом delta
% method определяет используемый метод:
% 1) explicit - явный
% 2) implicit - неявный
% Возвращает X, Y и ERR - ошибка на каждом значении из X:
% ERR = ANALYTICAL(X) - EULER_EXPLICT(X)
function res = euler(b, delta, method)
    global analytical_y right_dy
    
    X = 0.0:delta:b;
    Y = 1.0;
    ERR = 0.0;
    
    y = 1.0;
    for x = (0.0+delta):delta:b
        if method == 'explicit'
            y = euler_explicit_step(x, y, delta);
        else
            y = euler_implicit_step(x, y, delta);
        end
        Y = [Y y];
        err = analytical_y(x) - y;
        ERR = [ERR err];
    end
    
    res = [X; Y; ERR];
end

% Шаг явного метода Эйлера
function y = euler_explicit_step(x_old, y_old, delta)
    global right_dy
    y = y_old + delta * right_dy(x_old, y_old);
end

% Шаг неявного метода Эйлера
function y = euler_implicit_step(x_old, y_old, delta)
    % y_(i+1) = y_i + delta * f(x_(i+1), y_(i+1))
    % y_(i+1) = y_i + delta * -10000 * y_(i+1)
    % y_(i+1) * (1 + delta * 10000) = y_i
    % y_(i+1) = y_i / (1 + delta * 10000)
    y = y_old / (1 + delta * 10000);
end
