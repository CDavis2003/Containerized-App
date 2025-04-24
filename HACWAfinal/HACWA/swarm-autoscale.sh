#!/usr/bin/env bash
# swarm-autoscale.sh

sudo docker-compose build

sudo docker swarm init
sudo docker stack deploy --compose-file docker-compose.yml webstack

# Simple Swarm autoscaler: adjusts replicas based on average CPU usage.

#####################################
# CONFIGURATION
#####################################
SERVICE_NAME="webstack_web"        # name of your swarm service
MIN_REPLICAS=3                   # never scale below this
MAX_REPLICAS=6                  # never scale above this
UPPER_THRESHOLD=0.1             # if avg CPU > this, scale up
LOWER_THRESHOLD=0.01             # if avg CPU < this, scale down
SLEEP_INTERVAL=10                # seconds between checks

#####################################
# PREREQS: bc, docker CLI
#####################################

while true; do
  # 1. Get current desired replicas
  CURRENT=$(docker service ls \
    --filter name="$SERVICE_NAME" \
    --format '{{.Replicas}}' \
    | awk -F/ '{print $1}' \
    |head -n 1)
  if [[ -z "$CURRENT" ]]; then
    echo " Service '$SERVICE_NAME' not found."
    exit 1
  fi

  # 2. List container IDs for this service
  #    (Swarm names tasks like SERVICE_NAME.ID)
  CONTAINERS=$(docker ps \
    --filter "name=${SERVICE_NAME}\." \
    --format '{{.ID}}')

  if [[ -z "$CONTAINERS" ]]; then
    echo " No running tasks for '$SERVICE_NAME'."
    sleep "$SLEEP_INTERVAL"
    continue
  fi

  # 3. Gather CPU% for each container, sum & average
  TOTAL=0
  COUNT=0
  while read -r cid usage; do
    # strip trailing '%'
    usage=${usage%\%}
    TOTAL=$(awk "BEGIN {print $TOTAL + $usage}")
    COUNT=$((COUNT + 1))
  done < <(
    docker stats --no-stream \
      --format "{{.Container}} {{.CPUPerc}}" $CONTAINERS
  )

  AVG=$(awk "BEGIN {print $TOTAL / $COUNT}")

  echo "$(date '+%T') ▶ Avg CPU of $SERVICE_NAME = ${AVG}%"

  # 4. Decide new replica count
  NEW=$CURRENT
  if (( $(echo "$AVG > $UPPER_THRESHOLD" | bc -l) )); then
    NEW=$((CURRENT + 1))
  elif (( $(echo "$AVG < $LOWER_THRESHOLD" | bc -l) )); then
    NEW=$((CURRENT - 1))
  fi

  # clamp to [MIN_REPLICAS, MAX_REPLICAS]
  (( NEW < MIN_REPLICAS )) && NEW=$MIN_REPLICAS
  (( NEW > MAX_REPLICAS )) && NEW=$MAX_REPLICAS

  # 5. Scale if needed
  if [[ $NEW -ne $CURRENT ]]; then
    echo " Scaling $SERVICE_NAME: $CURRENT → $NEW replicas"
    docker service scale "$SERVICE_NAME"="$NEW"
  else
    echo "No scaling action needed"
  fi

  sleep "$SLEEP_INTERVAL"
done
