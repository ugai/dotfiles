import sys

MIN_PYTHON = (3, 10)

if __name__ == "__main__":
    sys.exit(0 if sys.version_info >= MIN_PYTHON else 1)
