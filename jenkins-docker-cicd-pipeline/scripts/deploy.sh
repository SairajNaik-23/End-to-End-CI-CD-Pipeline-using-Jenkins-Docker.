#!/usr/bin/env bash
# Runs ON THE DEPLOY SERVER (Jenkins pipes it over SSH).
# Pulls the new image, replaces the running container, and rolls back
# to the previous image if the new one doesn't become healthy.
#
# Usage: deploy.sh <image:tag> <container-name> <host-port>
set -euo pipefail

IMAGE="$1"
NAME="${2:-demo-app}"
PORT="${3:-80}"

echo ">> Pulling ${IMAGE}"
docker pull "$IMAGE"

# Remember the image currently running (for rollback)
PREVIOUS_IMAGE=$(docker inspect --format '{{.Config.Image}}' "$NAME" 2>/dev/null || true)

echo ">> Replacing container ${NAME}"
docker rm -f "$NAME" 2>/dev/null || true
docker run -d \
  --name "$NAME" \
  --restart unless-stopped \
  -p "${PORT}:3000" \
  -e APP_VERSION="${IMAGE##*:}" \
  "$IMAGE"

echo ">> Waiting for the container to become healthy"
for i in $(seq 1 12); do
  STATUS=$(docker inspect --format '{{.State.Health.Status}}' "$NAME")
  echo "   attempt ${i}: ${STATUS}"
  if [ "$STATUS" = "healthy" ]; then
    echo ">> Deployment successful"
    docker image prune -f >/dev/null
    exit 0
  fi
  sleep 5
done

echo ">> New container is not healthy - rolling back"
docker rm -f "$NAME"
if [ -n "$PREVIOUS_IMAGE" ]; then
  docker run -d --name "$NAME" --restart unless-stopped -p "${PORT}:3000" "$PREVIOUS_IMAGE"
  echo ">> Rolled back to ${PREVIOUS_IMAGE}"
fi
exit 1
