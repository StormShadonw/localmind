import sys
from mlx_lm import load, generate

def main():
    if len(sys.argv) < 2:
        print("Error: Proporciona un prompt como argumento")
        return

    model = sys.argv[1]
    model, tokenizer = load(model)
    print(true)

if __name__ == "__main__":
    main()