#!/usr/bin/env bash

# Script to process YouTube video transcripts using Whisper-CPP and LLM for summary

# Function to display help message
function show_help() {
    echo "Usage: $0 [options] <YouTube_URL>"
    echo ""
    echo "Options:"
    echo "  -h, --help          Display this help message"
    echo "  -c, --cleanup       Clean up temporary files"
    echo "  -m, --model <path>  Specify Whisper model path"
    echo "  -o, --output <dir>  Specify output directory"
    echo "  -t, --output-type   Specify output type (TEXT or HTML)"
    echo ""
    echo "Examples:"
    echo "  $0 https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    echo "  $0 -c https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    echo "  $0 -t TEXT https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}

# Parse command line arguments
CLEANUP=false
MODEL_PATH=""
OUTPUT_DIR="."
OUTPUT_TYPE="HTML"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        -c|--cleanup) CLEANUP=true ;;
        -m|--model) MODEL_PATH="$2"; shift ;;
        -o|--output) OUTPUT_DIR="$2"; shift ;;
        -t|--output-type) OUTPUT_TYPE="$2"; shift ;;
        *) break ;;
    esac
    shift
done

# Check if YouTube URL is provided
if [[ -z "$1" ]]; then
    echo "Error: YouTube URL is required."
    show_help
    exit 1
fi

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
    show_help
    exit 1
fi

# Define directories for models, audio files, and transcripts
MODELS_DIR="${OUTPUT_DIR}/models"
AUDIO_DIR="${OUTPUT_DIR}/audios"
TRANSCRIPT_DIR="${OUTPUT_DIR}/transcripts"

# Create directories if they do not exist
mkdir -p "${MODELS_DIR}"
mkdir -p "${AUDIO_DIR}"
mkdir -p "${TRANSCRIPT_DIR}"

# Define file paths
TRANSCRIPT_FILE="${TRANSCRIPT_DIR}/${VIDEO_ID}"
AUDIO_FILE="${AUDIO_DIR}/${VIDEO_ID}.mp3"
WHISPER_MODEL="${MODEL_PATH:-${MODELS_DIR}/whisper-large-v3-cantonese.bf16.bin}"

# Check if Whisper model file exists
if [ ! -f "${WHISPER_MODEL}" ]; then
    echo "Error: Whisper model file not found: ${WHISPER_MODEL}"
    exit 1
fi

# Function to download audio from YouTube
function download_audio() {
    local url="$1"
    local output="$2"

    echo "Downloading audio from YouTube: ${url}"
    yt-dlp -f 'ba[acodec^=mp3]/ba/b' -x --audio-format mp3 -o "${output}" "${url}"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download audio from YouTube."
        exit 1
    fi
}

# Function to transcribe audio using Whisper-CPP
function transcribe_audio() {
    local audio_file="$1"
    local output_file="$2"
    local model="$3"

    echo "Transcribing audio: ${audio_file}"
    whisper-cli -m "${model}" -l auto "${audio_file}" --no-speech-thold 0.4 -olrc -fa -sns --output-file "${output_file}"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to transcribe audio."
        exit 1
    fi
}

# Function to generate summary using LLM
function generate_summary() {
    local transcript_file="$1"
    local output_file="$2"

    echo "Generating summary using Google Gemini model..."

    # Determine the output format based on OUTPUT_TYPE
    if [[ "${OUTPUT_TYPE}" == "TEXT" ]]; then
        cat "${transcript_file}.lrc" | \
         llm -m gemini-2.5-flash-preview-05-20 \
             -s "show in Traditional Hong Kong Chinese Language,
                list the items discuss in the video transcript,
                in table format with item name, price and description,
                make summary. 
                Pretty format and use plain text output" \
            > "${output_file}"
    else
        cat "${transcript_file}.lrc" | \
         llm -m gemini-2.5-flash-preview-05-20 \
             -s "show in Traditional Hong Kong Chinese Language,
                list the items discuss in the video transcript,
                in table format with alternative-row color with item name, price and description,
                make summary. 
                Pretty format and use HTML source output to save as .html file" | \
            sed -n '/\`\`\`html/,/\`\`\`/p' | sed -e '1d' -e '$d' \
            > "${output_file}"
    fi

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to generate summary."
        exit 1
    fi
}

# Function to clean up temporary files
function cleanup() {
    local audio_file="$1"
    local transcript_file="$2"

    echo "Cleaning up temporary files..."
    rm -f "${audio_file}"
    rm -f "${transcript_file}.lrc"

    if [[ $? -ne 0 ]]; then
        echo "Warning: Failed to clean up some files."
    fi
}

# Step 1: Download audio from YouTube
if [ -f "${AUDIO_FILE}" ]; then
    echo "Reusing existing audio file: ${AUDIO_FILE}"
else
    download_audio "${INPUT_YT_URL}" "${AUDIO_FILE}"
fi

# Step 2: Transcribe audio using Whisper-CPP
if [ -f "${TRANSCRIPT_FILE}.lrc" ]; then
    echo "Reusing existing transcript: ${TRANSCRIPT_FILE}.lrc"
else
    transcribe_audio "${AUDIO_FILE}" "${TRANSCRIPT_FILE}" "${WHISPER_MODEL}"
fi

# Step 3: Generate summary using LLM
if [[ "${OUTPUT_TYPE}" == "TEXT" ]]; then
    generate_summary "${TRANSCRIPT_FILE}" "${TRANSCRIPT_FILE}.txt"
else
    generate_summary "${TRANSCRIPT_FILE}" "${TRANSCRIPT_FILE}.html"
fi

# Clean up if requested
if ${CLEANUP}; then
    cleanup "${AUDIO_FILE}" "${TRANSCRIPT_FILE}"
fi

# End of script
echo "Processing completed."
