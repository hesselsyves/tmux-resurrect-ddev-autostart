#!/bin/bash
# Auto-run commands in specific tmux windows after tmux-resurrect restore.

DDEV_WINDOWS="trx pnp crd cbc oea zloket rabbit"
CONSUMERS_PANE=""

# Give resurrect a moment to fully restore pane working directories
sleep 2

for window in $(tmux list-windows -a -F "#{session_name}:#{window_index}:#{window_name}"); do
  IFS=':' read -r session index name <<< "$window"
  pane="${session}:${index}.0"

  # ddev start for project windows
  if echo "$DDEV_WINDOWS" | grep -qw "$name"; then
    pane_path=$(tmux display-message -t "$pane" -p '#{pane_current_path}' 2>/dev/null)
    
    if [ -n "$pane_path" ] && [ -f "${pane_path}/.ddev/config.yaml" ]; then
      tmux send-keys -t "$pane" "ddev start" Enter
      # Stagger starts to avoid overwhelming the system
      sleep 3
    fi
  fi

  # mitmweb for proxy window
  if [ "$name" = "proxy" ]; then
    tmux send-keys -t "$pane" "./mitmweb --listen-host 0.0.0.0 --listen-port 8888 --ssl-insecure --set anticomp=true" Enter
  fi

  # Remember the consumers window to run after all ddev starts are done
  if [ "$name" = "consumers" ]; then
    CONSUMERS_PANE="${session}:${index}"
  fi
done

# Wait for all ddev containers to be ready before starting consumers
if [ -n "$CONSUMERS_PANE" ]; then
  # Wait for all ddev starts to finish (check that no ddev process is still starting)
  while pgrep -f "ddev start" > /dev/null 2>&1; do
    sleep 5
  done

  # Send command to all 4 panes in the consumers window
  for pane_index in 0 1 2 3; do
    tmux send-keys -t "${CONSUMERS_PANE}.${pane_index}" "ddev drush messenger:consume crd" Enter
    sleep 1
  done
fi
