#!/opt/homebrew/bin/bash

filename=$(basename -- "$0")
extension="${filename##*.}"
filename="${filename%.*}"

# sample URL:
# https://www.youtube.com/watch?v=9fLILe-SReU
YT_URL=$1

if [ -z "${YT_URL}" ]; then
    echo "$0 YUTUBE_URL"
    exit 1;
fi

MODELS=./models
AUDIOS=./audios
TRANSCRIPTS=./transcripts

mkdir -p "${MODELS}"
mkdir -p "${AUDIOS}"
mkdir -p "${TRANSCRIPTS}"

TRANSCRIPT_FILE=${TRANSCRIPTS}/${filename}

MP3=${AUDIOS}/${filename}.mp3

WHISPER_MODEL=${MODELS}/whisper-large-v3-cantonese.bf16.bin

# check if whisper model file exist
if [ ! -f "${WHISPER_MODEL}" ]; then
    echo "Whisper model file not found: ${WHISPER_MODEL}"
    exit 1;
fi

# 1. Use `yt-dlp` to download audio content
if [ -f "${MP3}" ]; then
    echo "Re-use existing ${MP3}"
else
    yt-dlp -f 'ba[acodec^=mp3]/ba/b' -x --audio-format mp3 -o ${MP3} "${YT_URL}"

    if [[ $? -ne 0 ]]; then
        echo "$0 YUTUBE_URL"
        exit 1;
    fi
fi

# 2. Process audio files with `whisper-cpp` using appropriate models
if [ -f "${TRANSCRIPT_FILE}.lrc" ]; then
    echo "Re-use existing ${TRANSCRIPT_FILE}"
else
    whisper-cli -m ${WHISPER_MODEL} -l auto ${MP3} -olrc -fa -sns --output-file ${TRANSCRIPT_FILE}
fi

# 3. Use `llm` and `ollama` for language model inference
cat ${TRANSCRIPT_FILE}.lrc | llm -m qwen3_4b -s "show with Traditional Hong Kong Chinese, list the items discuss in the video transcript, in point form, make summary /no_think"

# use Google Gemini free model (non-local)
# cat ${TRANSCRIPT_FILE}.lrc | llm -m gemini-2.0-flash -s "show with Traditional Hong Kong Chinese, list the items discuss in the video transcript, in point form, make summary"