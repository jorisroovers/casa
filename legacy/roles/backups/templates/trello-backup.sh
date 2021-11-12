API_KEY="{{trello_api_key}}"
API_TOKEN="{{trello_api_token}}"

echo "Fetching boards..."

# Fetch list of boards
BOARDS=$(curl -s  "https://api.trello.com/1/members/me/boards?key=$API_KEY&token=$API_TOKEN")
NUM_BOARDS=$(echo "$BOARDS" | jq '. | length')

# For each board, fetch all cards on the board and dump to a file
for i in $(seq 0 $(( $NUM_BOARDS-1 ))); do
  BOARD=$(echo $BOARDS | jq ".[$i]")
  BOARD_ID=$(echo $BOARD | jq -r '.id')
  BOARD_NAME=$(echo $BOARD | jq -r '.name')
  echo -n "Fetching cards from board $BOARD_NAME ($BOARD_ID)..."
  curl -s "https://api.trello.com/1/boards/$BOARD_ID/cards?key=$API_KEY&token=$API_TOKEN" > "$BOARD_NAME.json"
  echo "DONE"
done

echo "ALL DONE"