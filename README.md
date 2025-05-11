# AI Toolchain Setup Guide

This yt-transcript repository provides a comprehensive setup guide for using AI tools on macOS/Linux for voice processing and language modeling. The toolchain includes:

- Whisper.cpp for voice-to-text
- CLI LLM for command-line language models
- Ollama for local LLM execution
- Cantonese-specific fine-tuned model

## 🛠 Installation

### Prerequisites

1. **Homebrew** - Package manager for macOS and Linux
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

### Tools

Install the following applications via Homebrew:
```bash
brew install yt-dlp      # YouTube-DL fork (https://github.com/yt-dlp/yt-dlp)
brew install whisper-cpp # Whisper.cpp implementation (https://github.com/ggml-org/whisper.cpp)
brew install ollama      # Open-source LLM platform (https://ollama.com)
brew install llm         # CLI LLM client (https://llm.datasette.io)
```

## 🧠 Models

1. **Base Whisper Models**  
   Download from: https://huggingface.co/ggerganov/whisper.cpp

2. **Cantonese Fine-tuned Model**  
   Download from: https://huggingface.co/kiuckhuang/whisper-large-v3-cantonese-ggml

## 🧪 Usage

1. Use `yt-dlp` to download audio content
2. Process audio files with `whisper-cpp` using appropriate models
3. Use `llm` and `ollama` for language model inference

## 📦 Project Structure

```
project-root/
├── models/                # Whisper model files
├── audio/                 # Processed audio files
├── scripts/             # Custom processing scripts
└── README.md
```

## 📝 Notes

- Ensure all models are placed in the `models/` directory
- Check https://llm.datasette.io for CLI LLM configuration options
- Ollama models can be managed with `ollama pull <model-name>`

Would you like me to customize this further with specific workflow instructions or project details?
## 🌐 Resources

- [YouTube-DL GitHub](https://github.com/yt-dlp/yt-dlp)
- [Whisper.cpp GitHub](https://github.com/ggml-org/whisper.cpp)
- [Ollama Website](https://ollama.com/)
- [CLI LLM Documentation](https://llm.datasette.io/en/stable/index.html)
- [HuggingFace Models](https://huggingface.co/models)
