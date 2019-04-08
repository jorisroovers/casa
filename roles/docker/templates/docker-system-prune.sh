#!/bin/bash

echo "****** $(date +'%Y-%m-%d %H:%M:%S %Z') ******"
echo "Running docker system prune..."
sudo docker system prune -f
echo "DONE"

echo "Running systemctl daemon-reload..."
sudo systemctl daemon-reload
echo "DONE"