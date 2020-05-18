# -*- coding: utf-8 -*-

import pandas as pd

def main():
    file_name = input()
    df = pd.read_csv(file_name, sep = '\t')
    df = df.sort_values(by='followers_cnt', kind='heapsort', ascending=False).head(10)
    names = list(zip(df.first_name, df.last_name))
    names = list(map(lambda obj: ' '.join(obj), names))
    for name in names:
        print(name)

if __name__ == "__main__":
    main()
