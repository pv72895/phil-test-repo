from d.d import shout


def test_shout() -> None:
    assert shout("a") == "A!"
