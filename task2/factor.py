for num in range(1, 101):
    if num % 3 == 0 and num % 5 == 0:
        print("BlackRed")
    elif num % 3 == 0:
        print("Black")
    elif num % 5 == 0:
        print("Red")
    else:
        print(num)
