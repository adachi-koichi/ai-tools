#!/bin/bash
# Miro REST API CLI Tool
# Usage: ./miro.sh <command> [arguments]

set -e

# Load environment variables
if [ -f ".env.local" ]; then
  export $(grep -v '^#' .env.local | xargs)
fi

# Configuration
MIRO_API_BASE="https://api.miro.com/v2"

# Check for access token
if [ -z "$MIRO_ACCESS_TOKEN" ]; then
  echo "Error: MIRO_ACCESS_TOKEN is not set" >&2
  echo "Please set it via: export MIRO_ACCESS_TOKEN=your_token" >&2
  exit 1
fi

# Helper function for API calls
miro_api() {
  local method="$1"
  local endpoint="$2"
  local data="$3"

  local args=("-s" "-X" "$method")
  args+=("-H" "Authorization: Bearer ${MIRO_ACCESS_TOKEN}")
  args+=("-H" "Content-Type: application/json")

  if [ -n "$data" ]; then
    args+=("-d" "$data")
  fi

  curl "${args[@]}" "${MIRO_API_BASE}${endpoint}"
}

# Commands

cmd_list_boards() {
  miro_api "GET" "/boards"
}

cmd_create_board() {
  local name="$1"
  local description="${2:-}"

  if [ -z "$name" ]; then
    echo "Usage: $0 create-board <name> [description]" >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg name "$name" \
    --arg desc "$description" \
    '{name: $name, description: $desc}')

  miro_api "POST" "/boards" "$data"
}

cmd_get_board() {
  local board_id="$1"

  if [ -z "$board_id" ]; then
    echo "Usage: $0 get-board <board_id>" >&2
    exit 1
  fi

  miro_api "GET" "/boards/${board_id}"
}

cmd_update_board() {
  local board_id="$1"
  local name="$2"
  local description="${3:-}"

  if [ -z "$board_id" ] || [ -z "$name" ]; then
    echo "Usage: $0 update-board <board_id> <name> [description]" >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg name "$name" \
    --arg desc "$description" \
    '{name: $name, description: $desc}')

  miro_api "PATCH" "/boards/${board_id}" "$data"
}

cmd_delete_board() {
  local board_id="$1"

  if [ -z "$board_id" ]; then
    echo "Usage: $0 delete-board <board_id>" >&2
    exit 1
  fi

  miro_api "DELETE" "/boards/${board_id}"
}

cmd_list_items() {
  local board_id="$1"
  local item_type="${2:-}"
  local limit="${3:-50}"

  if [ -z "$board_id" ]; then
    echo "Usage: $0 list-items <board_id> [type] [limit]" >&2
    exit 1
  fi

  local endpoint="/boards/${board_id}/items?limit=${limit}"
  if [ -n "$item_type" ]; then
    endpoint="${endpoint}&type=${item_type}"
  fi

  miro_api "GET" "$endpoint"
}

cmd_create_shape() {
  local board_id="$1"
  local shape_type="$2"
  local content="$3"
  local x="${4:-0}"
  local y="${5:-0}"
  local width="${6:-200}"
  local height="${7:-100}"

  if [ -z "$board_id" ] || [ -z "$shape_type" ] || [ -z "$content" ]; then
    echo "Usage: $0 create-shape <board_id> <shape_type> <content> [x] [y] [width] [height]" >&2
    echo "Shape types: rectangle, round_rectangle, circle, triangle, rhombus, etc." >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg shape "$shape_type" \
    --arg content "<p>$content</p>" \
    --argjson x "$x" \
    --argjson y "$y" \
    --argjson width "$width" \
    --argjson height "$height" \
    '{
      data: {
        shape: $shape,
        content: $content
      },
      style: {
        fillColor: "#ffffff",
        fillOpacity: "1.0",
        fontFamily: "arial",
        fontSize: "14",
        borderColor: "#1a1a1a",
        borderWidth: "2",
        borderOpacity: "1.0",
        borderStyle: "normal",
        textAlign: "center",
        textAlignVertical: "middle",
        color: "#1a1a1a"
      },
      position: {
        x: $x,
        y: $y,
        origin: "center"
      },
      geometry: {
        width: $width,
        height: $height
      }
    }')

  miro_api "POST" "/boards/${board_id}/shapes" "$data"
}

cmd_update_shape() {
  local board_id="$1"
  local item_id="$2"
  local content="$3"

  if [ -z "$board_id" ] || [ -z "$item_id" ] || [ -z "$content" ]; then
    echo "Usage: $0 update-shape <board_id> <item_id> <content>" >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg content "<p>$content</p>" \
    '{data: {content: $content}}')

  miro_api "PATCH" "/boards/${board_id}/shapes/${item_id}" "$data"
}

cmd_delete_shape() {
  local board_id="$1"
  local item_id="$2"

  if [ -z "$board_id" ] || [ -z "$item_id" ]; then
    echo "Usage: $0 delete-shape <board_id> <item_id>" >&2
    exit 1
  fi

  miro_api "DELETE" "/boards/${board_id}/shapes/${item_id}"
}

cmd_create_sticky() {
  local board_id="$1"
  local content="$2"
  local color="${3:-light_yellow}"
  local x="${4:-0}"
  local y="${5:-0}"

  if [ -z "$board_id" ] || [ -z "$content" ]; then
    echo "Usage: $0 create-sticky <board_id> <content> [color] [x] [y]" >&2
    echo "Colors: gray, light_yellow, yellow, orange, light_green, green, dark_green," >&2
    echo "        cyan, light_pink, pink, violet, red, light_blue, blue, dark_blue, black" >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg content "$content" \
    --arg color "$color" \
    --argjson x "$x" \
    --argjson y "$y" \
    '{
      data: {
        content: $content,
        shape: "square"
      },
      style: {
        fillColor: $color,
        textAlign: "center",
        textAlignVertical: "middle"
      },
      position: {
        x: $x,
        y: $y,
        origin: "center"
      }
    }')

  miro_api "POST" "/boards/${board_id}/sticky_notes" "$data"
}

cmd_update_sticky() {
  local board_id="$1"
  local item_id="$2"
  local content="$3"

  if [ -z "$board_id" ] || [ -z "$item_id" ] || [ -z "$content" ]; then
    echo "Usage: $0 update-sticky <board_id> <item_id> <content>" >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg content "$content" \
    '{data: {content: $content}}')

  miro_api "PATCH" "/boards/${board_id}/sticky_notes/${item_id}" "$data"
}

cmd_delete_sticky() {
  local board_id="$1"
  local item_id="$2"

  if [ -z "$board_id" ] || [ -z "$item_id" ]; then
    echo "Usage: $0 delete-sticky <board_id> <item_id>" >&2
    exit 1
  fi

  miro_api "DELETE" "/boards/${board_id}/sticky_notes/${item_id}"
}

cmd_create_text() {
  local board_id="$1"
  local content="$2"
  local x="${3:-0}"
  local y="${4:-0}"
  local font_size="${5:-14}"

  if [ -z "$board_id" ] || [ -z "$content" ]; then
    echo "Usage: $0 create-text <board_id> <content> [x] [y] [font_size]" >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg content "<p>$content</p>" \
    --argjson x "$x" \
    --argjson y "$y" \
    --arg fontSize "$font_size" \
    '{
      data: {
        content: $content
      },
      style: {
        color: "#1a1a1a",
        fillOpacity: "1.0",
        fontFamily: "arial",
        fontSize: $fontSize,
        textAlign: "left"
      },
      position: {
        x: $x,
        y: $y,
        origin: "center"
      }
    }')

  miro_api "POST" "/boards/${board_id}/texts" "$data"
}

cmd_update_text() {
  local board_id="$1"
  local item_id="$2"
  local content="$3"

  if [ -z "$board_id" ] || [ -z "$item_id" ] || [ -z "$content" ]; then
    echo "Usage: $0 update-text <board_id> <item_id> <content>" >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg content "<p>$content</p>" \
    '{data: {content: $content}}')

  miro_api "PATCH" "/boards/${board_id}/texts/${item_id}" "$data"
}

cmd_delete_text() {
  local board_id="$1"
  local item_id="$2"

  if [ -z "$board_id" ] || [ -z "$item_id" ]; then
    echo "Usage: $0 delete-text <board_id> <item_id>" >&2
    exit 1
  fi

  miro_api "DELETE" "/boards/${board_id}/texts/${item_id}"
}

cmd_create_connector() {
  local board_id="$1"
  local start_id="$2"
  local end_id="$3"
  local shape="${4:-curved}"

  if [ -z "$board_id" ] || [ -z "$start_id" ] || [ -z "$end_id" ]; then
    echo "Usage: $0 create-connector <board_id> <start_item_id> <end_item_id> [shape]" >&2
    echo "Shapes: straight, elbowed, curved" >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg startId "$start_id" \
    --arg endId "$end_id" \
    --arg shape "$shape" \
    '{
      startItem: {
        id: $startId
      },
      endItem: {
        id: $endId
      },
      style: {
        strokeColor: "#1a1a1a",
        strokeWidth: "2",
        strokeStyle: "normal",
        startStrokeCap: "none",
        endStrokeCap: "stealth"
      },
      shape: $shape
    }')

  miro_api "POST" "/boards/${board_id}/connectors" "$data"
}

cmd_delete_connector() {
  local board_id="$1"
  local item_id="$2"

  if [ -z "$board_id" ] || [ -z "$item_id" ]; then
    echo "Usage: $0 delete-connector <board_id> <item_id>" >&2
    exit 1
  fi

  miro_api "DELETE" "/boards/${board_id}/connectors/${item_id}"
}

cmd_create_frame() {
  local board_id="$1"
  local title="$2"
  local x="${3:-0}"
  local y="${4:-0}"
  local width="${5:-800}"
  local height="${6:-600}"

  if [ -z "$board_id" ] || [ -z "$title" ]; then
    echo "Usage: $0 create-frame <board_id> <title> [x] [y] [width] [height]" >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg title "$title" \
    --argjson x "$x" \
    --argjson y "$y" \
    --argjson width "$width" \
    --argjson height "$height" \
    '{
      data: {
        title: $title,
        format: "custom"
      },
      style: {
        fillColor: "#ffffff"
      },
      position: {
        x: $x,
        y: $y,
        origin: "center"
      },
      geometry: {
        width: $width,
        height: $height
      }
    }')

  miro_api "POST" "/boards/${board_id}/frames" "$data"
}

cmd_delete_frame() {
  local board_id="$1"
  local item_id="$2"

  if [ -z "$board_id" ] || [ -z "$item_id" ]; then
    echo "Usage: $0 delete-frame <board_id> <item_id>" >&2
    exit 1
  fi

  miro_api "DELETE" "/boards/${board_id}/frames/${item_id}"
}

cmd_create_card() {
  local board_id="$1"
  local title="$2"
  local description="${3:-}"
  local x="${4:-0}"
  local y="${5:-0}"

  if [ -z "$board_id" ] || [ -z "$title" ]; then
    echo "Usage: $0 create-card <board_id> <title> [description] [x] [y]" >&2
    exit 1
  fi

  local data=$(jq -n \
    --arg title "$title" \
    --arg desc "$description" \
    --argjson x "$x" \
    --argjson y "$y" \
    '{
      data: {
        title: $title,
        description: $desc
      },
      style: {
        cardTheme: "#2d9bf0"
      },
      position: {
        x: $x,
        y: $y,
        origin: "center"
      }
    }')

  miro_api "POST" "/boards/${board_id}/cards" "$data"
}

cmd_help() {
  cat << 'EOF'
Miro REST API CLI Tool

Usage: ./miro.sh <command> [arguments]

Board Commands:
  list-boards                           List all boards
  create-board <name> [description]     Create a new board
  get-board <board_id>                  Get board details
  update-board <board_id> <name> [desc] Update board
  delete-board <board_id>               Delete board

Item Commands:
  list-items <board_id> [type] [limit]  List items on board

Shape Commands:
  create-shape <board_id> <type> <content> [x] [y] [width] [height]
  update-shape <board_id> <item_id> <content>
  delete-shape <board_id> <item_id>

Sticky Note Commands:
  create-sticky <board_id> <content> [color] [x] [y]
  update-sticky <board_id> <item_id> <content>
  delete-sticky <board_id> <item_id>

Text Commands:
  create-text <board_id> <content> [x] [y] [font_size]
  update-text <board_id> <item_id> <content>
  delete-text <board_id> <item_id>

Connector Commands:
  create-connector <board_id> <start_id> <end_id> [shape]
  delete-connector <board_id> <item_id>

Frame Commands:
  create-frame <board_id> <title> [x] [y] [width] [height]
  delete-frame <board_id> <item_id>

Card Commands:
  create-card <board_id> <title> [description] [x] [y]

Environment:
  MIRO_ACCESS_TOKEN   Required. Your Miro API access token.

Examples:
  ./miro.sh create-board "My Board" "Description"
  ./miro.sh create-shape uXjVK123 rectangle "Hello World" 0 0
  ./miro.sh create-sticky uXjVK123 "Note" light_yellow 100 100
  ./miro.sh create-connector uXjVK123 item1 item2
EOF
}

# Main
command="${1:-help}"
shift || true

case "$command" in
  list-boards)     cmd_list_boards "$@" ;;
  create-board)    cmd_create_board "$@" ;;
  get-board)       cmd_get_board "$@" ;;
  update-board)    cmd_update_board "$@" ;;
  delete-board)    cmd_delete_board "$@" ;;
  list-items)      cmd_list_items "$@" ;;
  create-shape)    cmd_create_shape "$@" ;;
  update-shape)    cmd_update_shape "$@" ;;
  delete-shape)    cmd_delete_shape "$@" ;;
  create-sticky)   cmd_create_sticky "$@" ;;
  update-sticky)   cmd_update_sticky "$@" ;;
  delete-sticky)   cmd_delete_sticky "$@" ;;
  create-text)     cmd_create_text "$@" ;;
  update-text)     cmd_update_text "$@" ;;
  delete-text)     cmd_delete_text "$@" ;;
  create-connector) cmd_create_connector "$@" ;;
  delete-connector) cmd_delete_connector "$@" ;;
  create-frame)    cmd_create_frame "$@" ;;
  delete-frame)    cmd_delete_frame "$@" ;;
  create-card)     cmd_create_card "$@" ;;
  help|--help|-h)  cmd_help ;;
  *)
    echo "Unknown command: $command" >&2
    echo "Run '$0 help' for usage." >&2
    exit 1
    ;;
esac
