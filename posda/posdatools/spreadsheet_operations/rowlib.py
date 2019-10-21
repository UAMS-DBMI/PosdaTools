

def parse_line(line):
    first_colon = line.index(':')
    if first_colon != 0:  # malformed line, ignore it
        return None
    second_colon = line.index(':', first_colon + 1)

    label = line[first_colon + 1:second_colon] 
    value = line[second_colon + 2:]

    if value.startswith('['):
        value = eval(value)  # evil, but fast!

    return label, value


def test(filename):
    with open(filename, "r") as infile:
        for line in infile:
            l, v = parse_line(line.strip())
            print(l, v)

if __name__ == '__main__':
    import sys

    test(sys.argv[1])
