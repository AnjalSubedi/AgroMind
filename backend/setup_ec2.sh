#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting EC2 Setup for CropDetect..."

# 1. Update System & Install Dependencies
echo "📦 Installing system dependencies..."
sudo yum update -y
sudo yum install -y \
    python3-pip \
    python3-devel \
    mesa-libGL \
    glib2

# Note: FFmpeg is not in standard Amazon Linux repositories.
# You may need to install it from a static build or enable a repository like RPMFusion.
# Attempting to install if available or providing a fallback message.
if ! command -v ffmpeg &> /dev/null; then
    echo "⚠️  FFmpeg not found. Attempting to install tarball..."
    # Download static release
    wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
    tar -xf ffmpeg-release-amd64-static.tar.xz
    # Move to /usr/local/bin (assuming generic name in extracted folder, usually ffmpeg-*-static)
    sudo cp ffmpeg-*-static/ffmpeg /usr/local/bin/
    sudo cp ffmpeg-*-static/ffprobe /usr/local/bin/
    # cleanup
    rm -rf ffmpeg-release-amd64-static.tar.xz ffmpeg-*-static
fi

# 2. Setup Python Virtual Environment
echo "🐍 Setting up Python Virtual Environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "   Virtual environment created."
else
    echo "   Virtual environment already exists."
fi

# Activate venv
source venv/bin/activate

# 3. Install Python Requirements
echo "⬇️ Installing Python packages (this may take a while)..."
pip install --upgrade pip
pip install -r requirements.txt

# 4. Create Uploads Directory
echo "📁 ensuring uploads directory exists..."
mkdir -p uploads

echo "✅ Setup Complete!"
echo "To run the server manually:"
echo "   source venv/bin/activate"
echo "   uvicorn main:app --host 0.0.0.0 --port 8000"
