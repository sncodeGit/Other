import socket

def __get_simple_num(a, b):
    for i in range(a,b+1):
        is_simple = True
        for j in range(2, i // 2 + 1):
            if (i % j == 0):
                is_simple = False
                break
        if is_simple:
            yield i

def __gcd_extended(num1, num2):
    if num1 == 0:
        return (num2, 0, 1)
    else:
        div, x, y = __gcd_extended(num2 % num1, num1)
    return (div, y - (num2 // num1) * x, x)

def __generate_keys(pq_left, pq_right, c_left, c_right):
    pub_key = {
        "N": 0,
        "c": 0,
    }
    priv_key = {
        "N": 0,
        "d": 0,
    }

    # Выбираем два простых числа
    simple_nums_gen = __get_simple_num(pq_left, pq_right)
    p = 1000000007# next(simple_nums_gen) # 1000000007
    print("p:", p)
    q = 1000000009# next(simple_nums_gen) # 1000000009
    print("q:", q)

    # Вычисляем модуль
    N = p * q
    print("N:", N)

    # Вычисляем значение функции Эйлера
    euler = (p-1) * (q-1)
    print('euler:', euler)

    # Вычисляем открытую экспоненту
    c_generator = __get_simple_num(c_left, c_right)
    c = next(c_generator)
    print("c:", c)

    # Найдем НОД(c, euler) с помощью расширенного алгоритма Евклида
    # Т.к. с и euler - взаимнопростые, получим:
    # alpha * c + beta * euler = НОД(c, euler) = 1
    # alpha - и есть ответ, т.к:
    # (alpha * c) % euler = (1 - beta * euler) % euler = 1
    d = __gcd_extended(c, euler)[1]
    print(__gcd_extended(c, euler))
    print('d:', d)

    pub_key['N'] = N
    pub_key['c'] = c
    priv_key['N'] = N
    priv_key['d'] = d
    print('pub_key:', pub_key)
    print('prib_key', priv_key)
    print("-----------")
    return (pub_key, priv_key)

def __get_last_n_by_2(num, deg, _mod):
    while deg != 1:
        num = num % _mod
        num = num ** 2
        deg = deg // 2
    num = num % _mod
    return num

def __decrypt_message(num, deg, _mod):
    num = num % _mod
    bin_deg = bin(deg)[2:]
    current_deg = len(bin_deg) - 1
    current_num = 1
    while current_deg != 0:
        if bin_deg[0] == '1':
            current_num = current_num * __get_last_n_by_2(num,
                                    2 ** current_deg, _mod)
            current_num = current_num % _mod
        current_deg -= 1
        bin_deg = bin_deg[1:]
    if bin_deg[0] == '1':
        current_num = current_num * num
        current_num = current_num % _mod
    return current_num

def __decode_message(decode_list):
    message = []
    for i in decode_list:
        code = str(i)[1:]
        while code != '':
            symb_code = int(code[:4])
            message.append(chr(symb_code))
            code = code[4:]
    return ''.join(message)

if __name__ == "__main__":
    pub_key, priv_key = __generate_keys(1000000000, 9999999999, 10, 20)

    sock = socket.socket()
    sock.bind(('', 9097))
    sock.listen(1)

    conn, addr = sock.accept()
    print('connected:', addr)

    encode_message = []

    while True:
        data = conn.recv(1024)
        if not data:
            break
        print("I accept: ", data)
        if data.decode("utf-8").upper() == "READY":
            N_byte = str.encode(str(pub_key['N']), encoding='utf-8')
            conn.send(N_byte)
            continue
        if data.decode("utf-8").upper() == "GET_N":
            c_byte = str.encode(str(pub_key['c']), encoding='utf-8')
            conn.send(c_byte)
            continue
        else:
            encode_message.append(data.decode("utf-8"))
    conn.close()

    encode_message = list(map(lambda x: int(x), encode_message))
    print("----------------------")
    print("Encode message:", encode_message)

    input("Enter some to decrypt message: ")

    decode_message = list(
        map(lambda x: __decrypt_message(x, priv_key['d'], (pub_key['N'])), encode_message)
    )
    print("----------------------")
    print("Decrypt message:", decode_message)

    input("Enter some to decode message: ")

    message = __decode_message(decode_message)
    print('Message:', message)
