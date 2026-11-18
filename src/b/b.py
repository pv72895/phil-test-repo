from a.a import x


def greet() -> str:
    return "hi"


def greet_x() -> str:
    return f"hi {x()}"
