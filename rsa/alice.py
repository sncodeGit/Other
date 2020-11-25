import socket
import time

Message = "самый крутой российский фильм этого года это Кома and HELLO WORLD"

def __get_part_message(message, length):
    part_message = []
    for i in message:
        if len(part_message) == length:
            part_message = []
        part_message.append(i)
        if len(part_message) == length:
            yield part_message
    if len(part_message) != 0:
        yield part_message

def __get_code(message, length):
    print('------------------------')
    part_message_gen = __get_part_message(message, length)
    for i in part_message_gen:
        code = '1'
        for j in i:
            if ord(j) < 10:
                code = code + '000' + str(ord(j))
                continue
            if ord(j) < 100:
                code = code + '00' + str(ord(j))
                continue
            if ord(j) < 1000:
                code = code + '0' + str(ord(j))
                continue
            else:
                code = code + str(ord(j))
        print('Part message:', i)
        print('Code:', code)
        yield int(code)
    print('------------------------')

if __name__ == "__main__":
    pub_key = {
        "N": 0,
        "c": 0,
    }

    sock = socket.socket()
    sock.connect(('localhost', 9097))

    input("Enter some: ")
    sock.send(b'Ready')

    data = sock.recv(1024)
    print("I accept: ", data)
    N_str = data.decode("utf-8")
    pub_key["N"] = int(N_str)
    input("Enter some: ")
    sock.send(b'GET_N')

    data = sock.recv(1024)
    print("I accept: ", data)
    c_str = data.decode("utf-8")
    pub_key["c"] = int(c_str)
    print("------------")
    print("pub_key:", pub_key)

    input("Enter some: ")
    for i in __get_code(Message, 3):
        crypt_code = i ** pub_key['c'] % pub_key['N']
        sock.send(str(crypt_code).encode("utf-8"))
        time.sleep(0.5)

    sock.close()
