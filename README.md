# HW11 - AI Summary (Flutter, Android only)

Simple Flutter app with one AI feature: summarize user text into:
- `title`
- `summary` (1-2 short sentences)

## What is implemented

- Android-only Flutter project structure.
- One screen with:
  - input text field
  - button to send text to AI
  - output widget for title + summary
- OpenRouter API call.
- Strict JSON schema in request (`response_format: json_schema`).
- Client-side validation of returned JSON.

## Security

- API key is **not** stored in source code.
- Endpoint and model are also passed from environment variables.
- Run example:

```bash
flutter run ^
  --dart-define=OPENROUTER_API_KEY=your_key_here ^
  --dart-define=OPENROUTER_ENDPOINT=https://openrouter.ai/api/v1/chat/completions ^
  --dart-define=OPENROUTER_MODEL=openai/gpt-4.1-mini
```

You can replace `OPENROUTER_MODEL` with any OpenRouter model that supports structured outputs.
