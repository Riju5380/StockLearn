#!/bin/bash

# Target volume details
SPARSE_IMAGE_PATH="/Volumes/Office Work/office/mobile apps/Working Directory/stock_learn_dev.sparseimage"
MOUNT_POINT="/Volumes/StockLearnDev"

echo "=== StockLearn APFS Virtual Drive Manager ==="

# Check if already mounted
if [ -d "$MOUNT_POINT" ]; then
    echo "✓ APFS Virtual Drive is already mounted at $MOUNT_POINT"
else
    # Check if sparse image exists
    if [ -f "$SPARSE_IMAGE_PATH" ]; then
        echo "Mounting APFS Virtual Drive from external SSD..."
        hdiutil attach "$SPARSE_IMAGE_PATH"
        if [ $? -eq 0 ]; then
            echo "✓ Successfully mounted virtual drive at $MOUNT_POINT"
        else
            echo "✗ Failed to mount the virtual drive. Please check your SSD connection."
            exit 1
        fi
    else
        echo "✗ Error: Virtual image not found at: $SPARSE_IMAGE_PATH"
        exit 1
    fi
fi

echo "--------------------------------------------"
echo "You can now work on your project inside: $MOUNT_POINT"
echo "To build your app, open a terminal there and run: flutter build apk --release"
echo "============================================"
