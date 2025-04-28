import sys
import os
import json
from mlx_lm import load, generate

def load_chat_history(file_path):
    """Carga el historial de chat desde un archivo"""
    if not os.path.exists(file_path):
        return []
    
    with open(file_path, "r", encoding='utf-8') as file:
        lines = file.readlines()
    
    history = []
    current_role = None
    
    for line in lines:
        line = line.strip()
        if line.startswith("user: "):
            history.append({"role": "user", "content": line[6:]})
        elif line.startswith("aiModel: "):
            history.append({"role": "assistant", "content": line[9:]})
        elif line == "-" * 20:
            continue  # Ignorar separadores
    
    return history

def main():
    if len(sys.argv) < 4:
        print("Error: Argumentos requeridos: <model_name> <user_prompt> <documents_app_path>")
        return

    model_name = sys.argv[1]
    user_prompt = sys.argv[2]
    documents_app_path = sys.argv[3]
    
    # Cargar modelo
    model, tokenizer = load(model_name)
    safe_model_name = model_name.replace('/', '_')
    
    # Rutas de archivos
    chats_dir = os.path.join(documents_app_path, "chats")
    chat_file = os.path.join(chats_dir, f"{safe_model_name}.txt")
    
    # 1. Cargar historial previo
    chat_history = load_chat_history(chat_file)
    
    # 2. Añadir el nuevo mensaje del usuario
    chat_history.append({"role": "user", "content": user_prompt})
    
    # 3. Generar prompt con todo el historial
    if tokenizer.chat_template:
        prompt = tokenizer.apply_chat_template(chat_history, add_generation_prompt=True)
    else:
        # Si no hay chat_template, concatenar manualmente
        prompt = "\n".join([f"{msg['role']}: {msg['content']}" for msg in chat_history])
    
    # 4. Generar respuesta
    response = generate(model, tokenizer, prompt=prompt, verbose=False)

    ai_response = ""

    if "</think>" in response:
    # Si contiene </think>, extraer solo la parte después del tag
        ai_response = response.split("</think>")[1].strip()
    else:
    # Si no contiene el tag, usar la respuesta completa
        ai_response = response.strip()
    
    # 5. Guardar la interacción completa
    os.makedirs(chats_dir, exist_ok=True)
    with open(chat_file, "a", encoding='utf-8') as file:
        file.write(f"user: {user_prompt}\n")
        file.write(f"aiModel: {ai_response}\n")
        file.write("-" * 20 + "\n")
    
    print(response)

if __name__ == "__main__":
    main()