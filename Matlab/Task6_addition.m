% Go to main() function
main();

function [] = main()
    global k_d k_p m z_target T_fun t_stop delta g T_min T_max;
    
    % Обычно в технических расчетах такое значение, т.к. величина g
    % варьируется по географическим положениям
    g = 9.81;
    % Рандомные значения массы и коэффициента b
    m = 0.5;
    b = 2;
    
    % Начальные значения частоты вращения и подъемной силы
    w_0 = (m * g / (4 * b)) ^ 0.5;
    T_0 = 4 * b * (w_0 ^ 2);
    
    % Ограничим максимальное значение угловой скорости, поскольку она не может
    % увеличиваться бесконечно. Сути конкретное значение ограничения не
    % меняет, поэтому допустим, например, такое ограничение:
    w_max = m * g;
    % Тогда подъемная сила ограничена следующим значением:
    T_max = 4 * w_max;
    % Ограничим минимальное значение подъемной силы нулем, поскольку,
    % вероятно, винтовая подъемная сила не может "опускать" квадрокоптер
    T_min = 0;
    
    % Допустим такую конечную высоту (знак - поскольку ось Oz направлена 
    % против направления движения)
    z_target = -50;
    
    % Функция изменения подъемной силы
    % min() и max() используются поскольку задаем ограничение T_max и T_min
    T_fun = @(k_p, k_d, z, z_derivative) max(min(k_p * (z - z_target) + k_d * z_derivative + T_0, T_max), T_min);
    
    % Шаг по времени полета
    delta = 0.001;
    % Ограничение по времени "справа"
    t_stop = 50;
    
    % Построим несколько графиков для исследования величины минимизируемого
    % функционала при разных значениях коэффициентов
    
    kp = -1:0.5:1;
    kd = -1:0.5:1;
    [X, Y] = meshgrid(kp, kd);
    Z = [];
    for i = kp
        Z_str = [];
        for j = kd
            J_val = J([i j]);
            disp([i, j]);
            disp(J_val);
            Z_str = [Z_str J_val];
        end
        Z = [Z; Z_str];
    end
    plot3(X, Y, Z);
    xlabel('k_p');
    ylabel('k_d');
    zlabel('Величина минимизируемого функционала');
    
    % Видно, что при отрицательных значениях коэффициентов значение
    % минимизируемого функционала уходит в бесконечность
    
    figure;
    
    kp = 1:0.2:2;
    kd = 1:0.2:2.6;
    [X, Y] = meshgrid(kp, kd);
    Z = [];
    for i = kp
        Z_str = [];
        for j = kd
            Z_str = [Z_str J([i j])];
        end
        Z = [Z; Z_str];
    end
    plot3(X, Y, Z);
    xlabel('k_p');
    ylabel('k_d');
    zlabel('Величина минимизируемого функционала');
    
    figure;
    
    % Видно, что наименьшее значение в контексте построенных графиков
    % получается при коэффициентах:
    % k_p = 2.0
    % k_d = 2.6
    % Запустим поиск из этой точки
    
    % Стартовые значения коэффициентов
    kp_kd_start = [2.0, 2.6];
    
    % Поиск минимума
    kp_kd_answ = fminsearch(@J, kp_kd_start);
    J_ans = J(kp_kd_answ);
    disp(kp_kd_answ);
    disp(J_ans);
    
    % Получились следующие значения коэффициентов:
    % k_p: 1.0181, k_d: 0.9622
    % Значение минимизируемого функционала: 3630.5
    
    % Построим графики T, z , z' (скорость)
    
    k_p = 1.0181;
    k_d = 0.9622;
    ans = get_time_Z_DZ_T();
    
    plot(ans(1, :), ans(2, :));
    title("График изменения положения по оси Oz");
    xlabel('Время (t)');
    ylabel('z(t)');
    figure;
   
    plot(ans(1, :), ans(3, :));
    title("График изменения скорости (по оси Oz)");
    xlabel('Время (t)');
    ylabel('Dz(t)');
    figure;
    
    plot(ans(1, :), ans(4, :));
    title("График изменения величины подъемной силы (по оси Oz)");
    xlabel('Время (t)');
    ylabel('T(t)');
    
    % Насколько я могу судить, графики получились достаточно похожими на
    % реальность. Квадрокоптер в первые секунды резко увеличил подъемную
    % силу, из-за чего начала увеличиваться скорость и квадрокоптер начал
    % подниматься. Затем подъемная сила уменьшилась, квадракоптер начал
    % замедляться и в итоге даже немного перелетел через заданное
    % ограничение высоты (50). Вероятно, это может свидетельствовать о
    % все еще неидеальной устойчивости системы. Возможно, был найден только
    % локальный минимум, а глобально есть значения коэффициентов, при
    % которых система ведет себя куда устойчивее. В реальной системе,
    % вероятно, был бы задан некоторый допустимый "разброс" и нужно было бы
    % проводить исследования дальше или это решение нас бы устроило.
end

% Представим диффуру 2 порядка в виде системы диффур
% m * z'' + k_d * z' + k_p * (z - z_target) = 0
% =>
% z' = y
% y' = -(k_d * y  + k_p * (z - z_target)) / m
function dzdy = diff(t, zy)
    global k_d k_p z_target m g T_min T_max;
    % Учитывая ограничения на T: T_min <= T <= T_max найдем ограничениия на
    % значения скорости (z') и ускорения (z'') по оси Оz
    % ---
    % m*z'' = mg - T
    % =>
    % z'' = g - T/m
    % =>
    % z''_max = g - T_min/m
    % z''_min = g - T_max/m
    % =>
    % g - T_max/m <= z'' <= g - T_min/m
    % ---
    dy_max = g - T_min/m;
    dy_min = g - T_max/m;
    dy = -1 * (k_d * zy(2) + k_p * (zy(1) - z_target)) / m;
    dzdy = [zy(2); max(min(dy, dy_max), dy_min)];
end

% https://www.mathworks.com/help/matlab/ref/ode23s.html
% ---
% Функция для вычисления нужных векторов значений функции z (расстояние),
% dz (скорость), T (подъемная сила), t (время)
% Возвращает матрицу, первая строка которой - функция высоты
% вторая - функция скорости
% третья - функция значения подъемной силы
% четвертая - время, соответсвующее значениям первых 3 строк
% Важно: ограничивает высоту (максимальное значение z) по 
function time_Z_DZ_T = get_time_Z_DZ_T()
    global k_d k_p T_fun t_stop delta;
    % Начальные значения дифференциального уравнения следующие:
    % z(0) = 0 - начальное положение квадрокоптера в точке Oz = 0
    % z'(0) = 0 - начальная скорость квадрокоптера равна нулю
    
    % Используем функцию решения жестких дифференциальных уравнений ode23s() 
    % из-за её высокой скорости
    [t, Z] = ode23s(@diff,[0:delta:t_stop],[0 0]);
    
    % Вычислим подъемную силу
    T = T_fun(k_p, k_d, Z(:,1), Z(:,2));
    
    time_Z_DZ_T = [t.'; Z(:,1).'; Z(:,2).'; T.'];
end

% Функционал, который необходимо минимизировать
function ret = J(kp_kd)
    global k_d k_p z_target delta;
    k_d = kp_kd(2);
    k_p = kp_kd(1);
    val = get_time_Z_DZ_T();
    
    % Подинтегральное выражение
    integral = ((val(2, :) - z_target).^2 + val(3, :).^2 + val(4, :).^2).*delta;
    
    ret = sum(integral);
end
