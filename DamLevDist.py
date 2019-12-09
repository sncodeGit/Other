# -*- coding: utf-8 -*-

import numpy as np
import random as rd
import matplotlib.pyplot as plt
import time
from mpl_toolkits.mplot3d import Axes3D

def getRuntime(C, T, iteration_num):
    sum = 0
    for i in range(iteration_num):
        getDamLevDist(C, T)
        sum += runtime
    return sum / iteration_num

def getStrings(N, M, seed):
    # Задаём алфавит из строчных букв английского языка
    alph = [chr(i) for i in range(97, 123)]
    
    # Задаём псевдорандом генерации строк
    rd.seed(seed)
    
    str1 = ''.join([alph[rd.randint(0,25)] for i in range(N)])
    str2 = ''.join([alph[rd.randint(0,25)] for i in range(M)])
    return [str1, str2]
    
def getDamLevDist(C, T):
    N = len(C)
    M = len(T)
    D = np.empty( (N + 1, M + 1) ) # Создаём матрицу решения
    
    global runtime
    start = time.time()
    
    # Заполняем матрицу решения для тривиальных случаев
    D[0][0] = 0
    for i in range(1, N+1):
        D[i][0] = i
    for j in range(1, M+1):
        D[0][j] = j
    
    # Создаём словарь для хранения индексов последнего вхождения
    # всех символов используемого алфавита в преобразуемую строку
    last_position = dict.fromkeys(C+T, 0)
    
    # Построчно заполняем матрицу решения
    for i in range(1, N+1):
        last = 0
        for j in range(1, M+1):
            ti = last_position[T[j-1]]
            tj = last
            if C[i - 1] != T[j - 1]:
                D[i][j] = min(D[i][j-1] + 1, D[i-1][j] + 1, D[i-1][j-1] + 1)
            else:
                D[i][j] = D[i-1][j-1]
                last = j
            if (ti != 0) and (tj != 0):
                D[i][j] = min(D[i][j], 
                    D[ti - 1][tj - 1] + (i - ti - 1) + 1 + (j - tj - 1))
        last_position[C[i-1]] = i
        
    end = time.time()
    runtime = end - start
        
    return D[N][M]

def main():
    # Построение двумерного графика для слов равных длин
    #X = np.arange(1, 202, 10)
    X = np.arange(211, 412, 10)
    Y = map(lambda x: getRuntime(x[0],x[1],10), [getStrings(i,i,32) for i in X])
    Y = np.array(list(Y))
    
    plt.plot(X, Y, label = 'Время работы алгоритма')
    plt.scatter(X, Y, marker='o', label = 'Точки измерения времени работы')
    
    for i in range(len(X)):
        print(X[i], ':', Y[i])
    
    mean = (Y/X/X).mean()
    #X = np.arange(1, 202)  
    X = np.arange(211, 412, 10)
    plt.plot(X, X*X*mean, label = 'График f(x) = x*x*' + str(mean))
    
    plt.xlabel('Размер слов, поданных на вход алгоритму (N и M)')
    plt.ylabel('Время работы алгоритма, усреднённое по 10 запускам (сек.)')
    plt.legend()
    plt.show()

    # Построение трёхмерного графика для слов различных длин
    X = np.arange(1, 102, 5)
    Y = np.arange(1, 102, 5)
    Z = np.empty((21,21))
    counter = 0
    for i in X:
        Z[counter] = np.array(list(map(lambda x: getRuntime(x[0],x[1],10), 
            [getStrings(i,j,32) for j in Y])))
        counter += 1
    X,Y = np.meshgrid(X,Y)
    
    fig = plt.figure()
    ax = fig.gca(projection='3d')
    ax.plot_surface(X,Y,Z)
    ax.set_xlabel('Размер первого слова (N)')
    ax.set_ylabel('Размер второго слова (M)')
    ax.set_zlabel('Время работы алгоритма')
    
    plt.show()

if __name__=='__main__':
    main()