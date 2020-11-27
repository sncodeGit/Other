def __gcd_extended(num1, num2):
    if num1 == 0:
        return (num2, 0, 1)
    else:
        div, x, y = __gcd_extended(num2 % num1, num1)
    return (div, y - (num2 // num1) * x, x)


