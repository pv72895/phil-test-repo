from b.b import greet, greet_x


def test_greet() -> None:
    assert greet() == "hi"


def test_greet_x() -> None:
    assert greet_x() == "hi 1"
