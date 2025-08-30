#!/bin/sh
pkill -TERM -f "n8n start" && echo "Stopping n8n gracefully..." || echo "No n8n process found"