% Go to main() function
main()

% Uncomment the desired functionality
function [] = main()
    %dispAnsw(@sin, @polinomInterp, @getEquidistPoint, -5*pi, 5*pi);
    %dispAnsw(@sin, @lagrInterp, @getEquidistPoint, -5*pi, 5*pi);
    %dispAnsw(@sin, @polinomInterp, @getChebPoint, -5*pi, 5*pi);
    %dispAnsw(@sin, @lagrInterp, @getChebPoint, -5*pi, 5*pi);
    
    %dispAnsw(@secFunc, @polinomInterp, @getEquidistPoint, -1, 1);
    %dispAnsw(@secFunc, @lagrInterp, @getEquidistPoint, -1, 1);
    %dispAnsw(@secFunc, @polinomInterp, @getChebPoint, -1, 1);
    %dispAnsw(@secFunc, @lagrInterp, @getChebPoint, -1, 1);
    
    %x = getEquidistPoint(-1, 1, 200);
    %points = getEquidistPoint(-1, 1, 20);
    %y = polinomInterp(@secFunc, points, x);
    %plot(x, y, x, arrayfun(@secFunc, x));
end

function [] = dispAnsw(func, interpFunc, pointsFunc, leftBoard, rightBoard)
    errors = research(func, interpFunc, pointsFunc, leftBoard, rightBoard, 1000, 0.001, 40);
    for i = 1:length(errors)
        disp([i ,errors(i)]);
    end
end

function res = secFunc(x)
	res = 1 / (1 + 12 * x * x);
end

function x = getEquidistPoint(leftB, rightB, n)
    x = [leftB];
    step = (abs(leftB) + abs(rightB)) / (n - 1);
    actVal = leftB;
    for i = 2:(n-1)
        actVal = actVal + step;
        x = [x, actVal];
    end
    x = [x, rightB];
end

function x = getChebPoint(leftB, rightB, n)
    x = [];
    for i = 1:n
        x = [x, (leftB + rightB) / 2 + (rightB - leftB) / 2 * cos((2*i - 1) / 2 / n * pi)];
    end
end

function coef = getPolCoef(fun, x)
    answ = arrayfun(fun, x).';
    
    n = numel(x);
    A = ones(n, 1);
    for i = 2:n
        A(:,i) = (x.') .* A(:, i - 1);
    end
    
    coef = linsolve(A, answ);
end

function xVal = getPolAnsw(coef, x)
    n = numel(coef);
    xVal = 0;
    for i = 1:n
        xVal = xVal + coef(i) * (x .^ (i - 1));
    end
end

function xVal = polinomInterp(fun, points, x)
    coef = getPolCoef(fun, points);
    xVal = getPolAnsw(coef, x);
end

function xVal = lagrInterp(fun, points, x)
    	xVal = [];
	for ptr = x
		res = 0;
		for node1 = points
			prod1 = 1;
			prod2 = 1;
			for node2 = points
				if (node1 == node2)
					continue
				end
				prod1 = prod1 * (ptr - node2);
				prod2 = prod2 * (node1 - node2);
			end
			res = res + fun(node1) *  (prod1 / prod2);
		end
		xVal = [xVal res];
	end
end

function error = getError(leftB, rightB, interpFunc, func, n)
    x = getEquidistPoint(leftB, rightB, n);
    interpVal = interpFunc(x);
    realVal = arrayfun(func, x);
    error = max(abs(interpVal - realVal));
end

function ret = research(func, interpFunc, pointsFunc, leftB, rightB, errorPointsNum, epsilon, maxDegree)
    degree = 1;
    firstDegree = 0;
    error = [];
    while (degree < maxDegree)
        degree = degree + 1;
        points = pointsFunc(leftB, rightB, degree);
        f = @(x) interpFunc(func, points, x);
        error = [error, getError(leftB, rightB, f, func, errorPointsNum)];
        if (error(degree - 1) <= epsilon) && (firstDegree == 0)
            firstDegree = degree;
        end
        if (firstDegree ~= 0) && (abs(firstDegree - degree) >= 5)
            break
        end
    end
    ret = error;
end
