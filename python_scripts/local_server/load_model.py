from transformers import AutoModelForCausalLM, AutoTokenizer

def main():
    
    # Descargar y cargar el modelo (se guarda en caché localmente)
    model_name = "mistralai/Mistral-7B-v0.1"  # También puedes usar "meta-llama/Llama-2-7b-chat-hf" (necesitas acceso)
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(model_name)

    # Ejemplo de inferencia
    input_text = "¿Cómo funciona un modelo de lenguaje?"
    inputs = tokenizer(input_text, return_tensors="pt")
    outputs = model.generate(**inputs, max_length=1000)

    print(tokenizer.decode(outputs[0], skip_special_tokens=True))



if __name__ == "__main__":
    main()