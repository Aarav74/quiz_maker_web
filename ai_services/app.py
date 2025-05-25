from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch
import logging
import json

app = FastAPI()
logging.basicConfig(level=logging.INFO)

# Hugging Face token
HF_TOKEN = "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"  # Replace with your actual token

# Load model with token
try:
    tokenizer = AutoTokenizer.from_pretrained(
        "mistralai/Mistral-7B-Instruct-v0.1",
        use_auth_token=HF_TOKEN
    )
    model = AutoModelForCausalLM.from_pretrained(
        "mistralai/Mistral-7B-Instruct-v0.1",
        torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
        device_map="auto",
        use_auth_token=HF_TOKEN
    )
    logging.info("Model loaded successfully with Hugging Face token.")
except Exception as e:
    logging.error(f"Model loading failed: {e}")
    raise

class PromptRequest(BaseModel):
    prompt: str

@app.post("/generate")
async def generate_questions(request: PromptRequest):
    try:
        prompt = f"""
        [INST] You are a quiz generator. Create 5 MCQs from the text below.
        Return only JSON format like this:
        {{
            "questions": [
                {{
                    "question": "...",
                    "options": ["...", "...", "...", "..."],
                    "correctAnswerIndex": 0,
                    "explanation": "..."
                }}
            ]
        }}

        Text: {request.prompt}
        [/INST]
        """

        inputs = tokenizer(prompt, return_tensors="pt").to(model.device)
        output = model.generate(
            **inputs,
            max_new_tokens=1000,
            temperature=0.7,
            do_sample=True
        )

        generated_text = tokenizer.decode(output[0], skip_special_tokens=True)
        json_start = generated_text.find('{')
        json_end = generated_text.rfind('}') + 1
        json_str = generated_text[json_start:json_end]

        return {"questions": json.loads(json_str)["questions"]}

    except Exception as e:
        logging.error(f"Question generation failed: {e}")
        raise HTTPException(status_code=500, detail="Question generation failed.")
