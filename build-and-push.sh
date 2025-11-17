#!/bin/bash

# build-and-push.sh
# Usage: ./build-and-push.sh 1.2.58

set -e  # Exit on error

# Check if version argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <semver>"
    echo "Example: $0 1.2.58"
    exit 1
fi

VERSION=$1
REGISTRY="rohitmmm"
IMAGE_NAME="argo-cd-test"

# Generate random 7-character git hash (lowercase hex)
GIT_HASH=$(openssl rand -hex 4 | cut -c1-7)

# Build the full tag
TAG="${VERSION}-dev.${GIT_HASH}"
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${TAG}"

echo "=========================================="
echo "Building and pushing Docker image"
echo "=========================================="
echo "Version:    ${VERSION}"
echo "Git Hash:   ${GIT_HASH}"
echo "Tag:        ${TAG}"
echo "Full Image: ${FULL_IMAGE}"
echo "=========================================="

# Generate index.html with version information
echo "Generating index.html..."
cat > index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>ArgoCD Test App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        .info {
            margin: 20px 0;
            padding: 15px;
            background-color: #ecf0f1;
            border-radius: 4px;
        }
        .label {
            font-weight: bold;
            color: #34495e;
        }
        .value {
            color: #2980b9;
            font-family: monospace;
            font-size: 1.1em;
        }
        .success {
            color: #27ae60;
            font-size: 1.2em;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 ArgoCD Image Updater Test</h1>
        <div class="info">
            <p><span class="label">Version:</span> <span class="value">${VERSION}</span></p>
            <p><span class="label">Git Hash:</span> <span class="value">${GIT_HASH}</span></p>
            <p><span class="label">Full Tag:</span> <span class="value">${TAG}</span></p>
            <p><span class="label">Image:</span> <span class="value">${FULL_IMAGE}</span></p>
        </div>
        <p class="success">✅ Container is running successfully!</p>
        <p><small>Built on: $(date)</small></p>
    </div>
</body>
</html>
EOF

echo "index.html generated successfully!"

# Build the image
echo "Building image..."
docker build -t ${FULL_IMAGE} .

echo "Build complete!"

# Push to Docker Hub
echo "Pushing to Docker Hub..."
docker push ${FULL_IMAGE}

echo "=========================================="
echo "✅ Successfully pushed: ${FULL_IMAGE}"
echo "=========================================="
echo ""
echo "To test locally:"
echo "  docker run -p 8080:80 ${FULL_IMAGE}"
echo "  curl http://localhost:8080"
echo ""
echo "Image Updater should detect this version automatically!"
