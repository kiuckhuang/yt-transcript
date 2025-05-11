#!/opt/homebrew/bin/bash

filename=$(basename -- "$0")
extension="${filename##*.}"
filename="${filename%.*}"

# sample URL:
# https://www.youtube.com/watch?v=9fLILe-SReU
YT_URL=$1

MODELS=./models
AUDIOS=./audios
TRANSCRIPTS=./transcripts

TRANSCRIPT_FILE=${TRANSCRIPTS}/${filename}

MP3=${AUDIOS}/${filename}.mp3
WHISPER_MODEL=${MODELS}/whisper-large-v3-cantonese.bf16.bin

# 1. Use `yt-dlp` to download audio content
yt-dlp -f 'ba[acodec^=mp3]/ba/b' -x --audio-format mp3 -o ${MP3} "${YT_URL}"

# 2. Process audio files with `whisper-cpp` using appropriate models
whisper-cli -m ${WHISPER_MODEL} -l auto ${MP3} -olrc -fa -sns --output-file ${TRANSCRIPT_FILE}

# 3. Use `llm` and `ollama` for language model inference
cat ${TRANSCRIPT_FILE}.lrc | llm -m qwen3_32b -s "show with Traditional Hong Kong Chinese, list the items discuss in the video transcript, in point form, make summary /no_think"