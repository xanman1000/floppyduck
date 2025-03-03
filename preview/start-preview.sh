#!/bin/bash

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is required but not installed. Please install Node.js and try again."
    echo "Visit https://nodejs.org/ to download and install Node.js."
    exit 1
fi

echo "Starting Floppy Duck preview server..."
echo "Once the server starts, open http://localhost:3000 in your web browser"
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server
node server.js 