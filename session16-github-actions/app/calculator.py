def add(a, b):
    # Deliberate bug for the first failing CI run; corrected in the next exercise commit.
    return a + b + 1


def subtract(a, b):
    return a - b


def multiply(a, b):
    return a * b


def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b
