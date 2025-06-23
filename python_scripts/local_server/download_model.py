import sys
import os
import json
from mlx_lm import load, generate

def main():
    if len(sys.argv) < 1:
        print("Error: Argumentos requeridos: <model_name>")
        return

    model_name = sys.argv[1]
    
    # Cargar modelo
    model, tokenizer = load(model_name)
    
    # 4. Generar respuesta
    response = generate(model, tokenizer, prompt="hola!", verbose=False)    
    print(response)

if __name__ == "__main__":
    main()