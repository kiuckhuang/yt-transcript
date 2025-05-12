# AI Toolchain Setup Guide

This yt-transcript repository provides a comprehensive setup guide for using AI tools on macOS/Linux for voice processing and language modeling. The toolchain includes:

- Whisper.cpp for voice-to-text
- CLI LLM for command-line language models
- Ollama for local LLM execution
- Cantonese-specific fine-tuned model

## Project Structure

```
yt-transcript/
├── models/                # Whisper model files
├── audios/                # Processed audio files
├── transcripts/           # Custom processing scripts
└── README.md
```

## 🛠 Installation

### Prerequisites

**Homebrew** - Package manager for macOS and Linux
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

### Download the project

```bash
git clone https://github.com/kiuckhuang/yt-transcript.git
cd yt-transcript
```


### Ollama model pull

Use `ollama pull` to download modle
```bash
ollama pull qwen3:4b
```

### LLM Model Config

Edit ~/Library/"Application Support"/io.datasette.llm/extra-openai-models.yaml
(Change to your own user profile path)

```text
- model_id: qwen3:4b
  model_name: qwen3:4b
  aliases: ["qwen3_4b"]
  api_base: "http://localhost:11434/v1"
- model_id: qwen3-32b
  model_name: qwen3-32b
  aliases: ["qwen3_32b"]
  api_base: "http://192.168.1.8:8080/v1"
```

### Whisper Models

1. **Base Whisper Models**  
   Download from: https://huggingface.co/ggerganov/whisper.cpp

2. **Cantonese Fine-tuned Model**  
   Download from: https://huggingface.co/kiuckhuang/whisper-large-v3-cantonese-ggml

```bash
curl -L -o models/whisper-large-v3-cantonese.bf16.bin 'https://huggingface.co/kiuckhuang/whisper-large-v3-cantonese-ggml/resolve/main/whisper-large-v3-cantonese.bf16.bin?download=true'
```


## Sample Usage

1. Use `yt-dlp` to download audio content
```bash
yt-dlp -f 'ba[acodec^=mp3]/ba/b' -x --audio-format mp3 -o audios/beyond_kol2025.mp3 "https://www.youtube.com/watch?v=9fLILe-SReU"
```
2. Process audio files with `whisper-cpp` using appropriate models
```bash
whisper-cli -m models/whisper-large-v3-cantonese.bf16.bin -l auto audios/beyond_kol2025.mp3 -olrc -fa -sns --output-file transcripts/beyond_kol2025
```
3. Use `llm` and `ollama` for language model inference
```bash
cat transcripts/beyond_kol2025.lrc | llm -m qwen3_4b -s "show with Traditional Hong Kong Chinese, list the items discuss in the video transcript, in point form, make summary /no_think"
```

## 📝 Notes

- Ensure all models are placed in the `models/` directory
- Check https://llm.datasette.io for CLI LLM configuration options
- Ollama models can be managed with `ollama pull <model-name>`


## 🌐 Resources

- [YouTube-DL GitHub](https://github.com/yt-dlp/yt-dlp)
- [YouTube Transcript API GitHub](https://github.com/jdepoix/youtube-transcript-api)
- [Whisper.cpp GitHub](https://github.com/ggml-org/whisper.cpp)
- [Ollama Website](https://ollama.com/)
- [CLI LLM Documentation](https://llm.datasette.io/en/stable/index.html)
- [HuggingFace Models](https://huggingface.co/models)
