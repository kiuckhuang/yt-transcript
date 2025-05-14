#!/opt/homebrew/bin/bash

# Script to process YouTube video transcripts using Whisper-CPP and LLM for summary

# Define input YouTube URL
INPUT_YT_URL="$1"

# Extract video ID from URL or direct input
VIDEO_ID=""

# Validate input as a YouTube video ID (11 characters: letters, numbers, _, -)
if [[ "$INPUT_YT_URL" =~ ^[A-Za-z0-9_-]{11}$ ]]; then
    VIDEO_ID="$INPUT_YT_URL"
fi

# Use regex to extract video ID from various YouTube URL formats
REGEX='(youtu\.be/|youtube\.com/(watch\?v=|embed/|v/|shorts/|shorts\?v=|.*[?&]v=))([A-Za-z0-9_-]{11})'

if [[ "$INPUT_YT_URL" =~ $REGEX ]]; then
    VIDEO_ID="${BASH_REMATCH[3]}"
fi

# Check if video ID is valid
if [ -z "${VIDEO_ID}" ]; then
    echo "Error: Input is not a valid YouTube video URL or ID."
    echo "Usage: $0 <YouTube_URL>"
    exit 1
fi

# Define directories for models, audio files, and transcripts
MODELS_DIR="./models"
AUDIO_DIR="./audios"
TRANSCRIPT_DIR="./transcripts"

# Create directories if they do not exist
mkdir -p "${MODELS_DIR}"
mkdir -p "${AUDIO_DIR}"
mkdir -p "${TRANSCRIPT_DIR}"

# Define file paths
TRANSCRIPT_FILE="${TRANSCRIPT_DIR}/${VIDEO_ID}"
AUDIO_FILE="${AUDIO_DIR}/${VIDEO_ID}.mp3"
WHISPER_MODEL="${MODELS_DIR}/whisper-large-v3-cantonese.bf16.bin"

# Check if Whisper model file exists
if [ ! -f "${WHISPER_MODEL}" ]; then
    echo "Error: Whisper model file not found: ${WHISPER_MODEL}"
    exit 1
fi

# Step 1: Download audio from YouTube using yt-dlp
if [ -f "${AUDIO_FILE}" ]; then
    echo "Reusing existing audio file: ${AUDIO_FILE}"
else
    echo "Downloading audio from YouTube: ${INPUT_YT_URL}"
    yt-dlp -f 'ba[acodec^=mp3]/ba/b' -x --audio-format mp3 -o "${AUDIO_FILE}" "${INPUT_YT_URL}"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download audio from YouTube."
        echo "Usage: $0 <YouTube_URL>"
        exit 1
    fi
fi

# Step 2: Transcribe audio using Whisper-CPP
if [ -f "${TRANSCRIPT_FILE}.lrc" ]; then
    echo "Reusing existing transcript: ${TRANSCRIPT_FILE}.lrc"
else
    echo "Transcribing audio: ${AUDIO_FILE}"
    whisper-cli -m "${WHISPER_MODEL}" -l auto "${AUDIO_FILE}" -olrc -fa -sns --output-file "${TRANSCRIPT_FILE}"
fi

# Step 3: Generate summary using LLM (e.g., Qwen or Google Gemini)
# Using Qwen3_4b model (local)
#echo "Generating summary using Qwen3_4b model..."
#cat "${TRANSCRIPT_FILE}.lrc" | llm -m qwen3_4b -s "show with Traditional Hong Kong Chinese, list the items discuss in the video transcript, in point form, make summary"

# Alternative: Using Google Gemini (non-local)
echo "Generating summary using Google Gemini model..."
cat "${TRANSCRIPT_FILE}.lrc" | llm -m gemini-2.0-flash -s "show with Traditional Hong Kong Chinese, list the items discuss in the video transcript, in point form, make summary"

# End of script
echo "Processing completed."
