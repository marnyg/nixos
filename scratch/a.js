
let a =await fetch("https://openrouter.ai/api/v1/chat/completions", {
  method: "POST",
  headers: {
    "Authorization": "Bearer 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",
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    "model": "anthropic/claude-3.5-sonnet-20240620",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "What is in this image?"
          },
          {
            "type": "image_url",
            "image_url": {
              "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
            }
          }
        ]
      }
    ]
  })
});
console.log(await a.json())
