# str.isnumeric etc may not be suitable
assert "❶❷❸❹".isnumeric()


def credit_card_is_valid(cc: str) -> bool:
    DIGITS = "0123456789"

    assert type(cc) is str
    # It must start with a 4, 5 or 6.
    if cc[0] not in ("4", "5", "6"):
        return False

    only_digits = "".join(x for x in cc if x in DIGITS)

    # It must contain exactly 16 digits.
    if len(only_digits) != 16:
        return False

    # It must only consist of digits (0-9).
    # It may have digits in groups of 4, separated by one hyphen "-".
    # It must NOT use any other separator like ' ' , '_', etc.
    if only_digits != cc:
        for group in cc.split("-"):
            if len(group) != 4:
                return False
            for char in group:
                if char not in DIGITS:
                    return False

    # It must NOT have 4 or more consecutive repeated digits.
    for digit in DIGITS:
        if digit * 4 in only_digits:
            return False

    return True


assert credit_card_is_valid("4253625879615786")
assert credit_card_is_valid("4424424424442444")
assert credit_card_is_valid("5122-2368-7954-3214")

assert not credit_card_is_valid("42536258796157867")
assert not credit_card_is_valid("4424444424442444")
assert not credit_card_is_valid("5122-2368-7954")
assert not credit_card_is_valid("44244x4424442444")
assert not credit_card_is_valid("0525362587961578")


def main():
    lines_to_read = int(input())
    assert lines_to_read > 0
    assert lines_to_read < 100
    for _ in range(lines_to_read):
        print("Valid" if credit_card_is_valid(input()) else "Invalid")


if __name__ == "__main__":
    main()
