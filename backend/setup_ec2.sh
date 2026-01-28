#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting EC2 Setup for CropDetect..."

# 1. Update System & Install Dependencies
echo "📦 Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y \
    python3-pip \
    python3-venv \
    ffmpeg \
    libgl1-mesa-glx \
    libglib2.0-0

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
