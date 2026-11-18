from b.b import greet, greet_value


def test_greet() -> None:
    assert greet() == "hi"


def test_greet_value() -> None:
    assert greet_value() == "hi 42"
