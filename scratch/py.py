import requests
import json

response = requests.post(
    url="https://openrouter.ai/api/v1/chat/completions",
    headers={
        "Authorization": "Bearer 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",
        "Content-Type": "application/json",
    },
    data=json.dumps(
        {
            "model": "deepseek/deepseek-r1",
            "messages": [{"role": "user", "content": "What is the meaning of life?"}],
        }
    ),
)
print(response.json())
