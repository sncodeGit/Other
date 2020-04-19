% Go to main() function
main();

function [] = main()
    % Аналитически решим первое уравнение
    solve = dsolve('D2y = 16.81*y', 'y(0) = 1.0', 'Dy(0) = -4.1');
    disp(solve);
    
    % Решение: y(t) = exp(-4.1*t)
    % y'(t) = -4.1 * exp(-4.1*t)
    
    % Аналитически решим второе уравнение
    solution = dsolve('D2y + 8.2*Dy + 16.81*y = 0', 'y(0) = 1.0', 'Dy(0) = -4.1');
    disp(solution);
    
    % Решение: y(t) = exp(-4.1*t)
    % y'(t) = -4.1 * exp(-4.1*t)
    
    analytical_y = @(t) exp(-4.1*t);
    analytical_Dy = @(t) -4.1 * exp(-4.1*t);
    
    % Сведём решение диффуры 2 порядка к решению системы диффур
    % Пусть y'(t) = z(t)
    
    % Тогда для первого уравнения получаем следующую систему:
    % z' = 16.81*y
    % y' = z
    % А начальные условия имеют следующий вид:
    % y(0) = 1.0
    % z(0) = -4.1
    
    % Для второго уравнения получаем:
    % z' + 8.2*z + 16.81*y = 0
    % y' = z
    % А начальные условия имеют следующий вид:
    % y(0) = 1.0
    % z(0) = -4.1
    
    % Проверим:
    solution = dsolve('Dz = 16.81*y', 'Dy = z', 'y(0) = 1.0', 'z(0) = -4.1');
    disp(solution.y);
    disp(solution.z);
    solution = dsolve('Dz + 8.2*z + 16.81*y = 0', 'Dy = z', 'y(0) = 1.0', 'z(0) = -4.1');
    disp(solution.y);
    disp(solution.z);
    
    % Построим графики решений первой системы диффур методом Эйлера и
    % методом Рунге-Кутты 4 порядка, а также найденного аналитически решения
    % Красный (непрерываный) - аналитическое решение
    % Зелёный (точечный, плюс) - численные решения методом Рунге-Кутты
    % Синий (точечный, круг) - численные решения методом Эйлера
    
    % b - правая граеница рассматриваемого отрезка по x: [0, b]
    % delta - шаг обоих численных методов
    b = 9.8;
    delta = 0.001;
    X = linspace(0, b, 1000);
    
    global right_y right_z start_y start_z
    right_y = @(x,y,z) z;
    right_z = @(x,y,z) 16.81*y;
    start_y = [0, 1.0];
    start_z = [0, -4.1];
    
    % Первое уравнение
    res_r_k = runge_kutta(b, delta);
    res_e = runge_kutta(b, delta);
    
    hold on;
    plot(X, analytical_y(X), 'r');
    plot(res_r_k(1, :), res_r_k(3, :), '+g');
    plot(res_e(1, :), res_e(3, :), 'ob');
    hold off;
    title("Функция y(t), y'' = 16.81*y");
    xlabel("t");
    ylabel("y(t)");
    figure;
    
    hold on;
    plot(X, analytical_Dy(X), 'r');
    plot(res_r_k(1, :), res_r_k(2, :), '+g');
    plot(res_e(1, :), res_e(2, :), 'ob');
    hold off;
    title("Производная функции y(t), y'' = 16.81*y");
    xlabel("t");
    ylabel("y'(t)");

    figure;
    % Второе уравнение
    right_z = @(x,y,z) - 8.2*z - 16.81*y;
    res_r_k = runge_kutta(b, delta);
    res_e = runge_kutta(b, delta);
    
    hold on;
    plot(X, analytical_y(X), 'r');
    plot(res_r_k(1, :), res_r_k(3, :), '+g');
    plot(res_e(1, :), res_e(3, :), 'ob');
    hold off;
    title("Функция y(t), y'' + 8.2*y' + 16.81y = 0");
    xlabel("t");
    ylabel("y(t)");
    figure;
    
    hold on;
    plot(X, analytical_Dy(X), 'r');
    plot(res_r_k(1, :), res_r_k(2, :), '+g');
    plot(res_e(1, :), res_e(2, :), 'ob');
    hold off;
    title("Производная функции y(t), y'' + 8.2*y' + 16.81y = 0");
    xlabel("t");
    ylabel("y'(t)");
    
    % Как можно увидеть, численные решения первого уравнения при увеличении
    % значения x начинают уходить в -бесконечность
    % Это связано с тем, что:
    % 1) Значения y и y' зависят друг от друга на каждом шаге вычисления
    % 2) Начальное значение y' отрицательно
    % То есть при вычислении численными методами значение y' будет
    % постепенно увеличиваться, а y постепенно уменьшаться. То есть графики
    % производной и самой функции уходит в бесконечность по ассимптоте [y = 0]
    % Соответственно, в зависимости от вида уравнения (скорости роста y' и y )
    % значение y в конечном итоге может уменьшиться до отрицательных
    % значений (и скорость уменьшения значения y начнёт расти), что и произошло
    % в случае первого уравнения.
end

% Решение системы диффур методом Рунге-Кутты 4 порядка
% b - правая граница отрезка
% delta - шаг метода
function res = runge_kutta(b, delta)
    global right_y right_z start_y start_z
    
    z = start_z(2);
    y = start_y(2);
    
    X = start_z(1):delta:b;
    Z = z;
    Y = y;
    
    for x = (start_z(1)+delta):delta:b
        next_val = runge_kutta_step(x, y, z, delta);
        z = next_val(1);
        y = next_val(2);
        Z = [Z z];
        Y = [Y y];
    end
    
    res = [X; Z; Y];
end

% Реализация шага метода Рунге-Кутты 4 порядка
function next_val = runge_kutta_step(x, y, z, delta)
    global right_y right_z
    k1 = delta * right_y(x, y, z);
    l1 = delta * right_z(x, y, z);
    k2 = delta * right_y(x + delta/2.0, y + k1/2.0, z + l1/2.0);
    l2 = delta * right_z(x + delta/2.0, y + k1/2.0, z + l1/2.0);
    k3 = delta * right_y(x + delta/2.0, y + k2/2.0, z + l2/2.0);
    l3 = delta * right_z(x + delta/2.0, y + k2/2.0, z + l2/2.0);
    k4 = delta * right_y(x + delta, y + k3, z + l3);
    l4 = delta * right_z(x + delta, y + k3, z + l3);
    next_y = y + (k1 + 2*k2 + 2*k3 + k4) / 6.0;
    next_z = z + (l1 + 2*l2 + 2*l3 + l4) / 6.0;
    next_val = [next_z next_y];
end

% Решение системы диффур методом Эйлера
% b - правая граница отрезка
% delta - шаг метода
function res = euler(b, delta)
    global right_y right_z start_y start_z
    
    z = start_z(2);
    y = start_y(2);
    
    X = start_z(1):delta:b;
    Z = z;
    Y = y;
    
    for x = (start_z(1)+delta):delta:b
        next_val = euler_step(x, y, z, delta);
        z = next_val(1);
        y = next_val(2);
        Z = [Z z];
        Y = [Y y];
    end
    
    res = [X; Z; Y];
end

% Реализация шага метода Эйлера
function next_val = euler_step(x, y, z, delta)
    global right_y right_z
    next_y = y + delta * right_y(x, y, z);
    next_z = z + delta * right_z(x, y, z);
    next_val = [next_z next_y];
end
