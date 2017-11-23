#!/bin/bash

INPUT=$(< /dev/stdin)
REMEDIATION_COMMAND=$(echo "$INPUT" | jq -r .check.remediation.command)

echo "Remediating using '$REMEDIATION_COMMAND'"
echo "$REMEDIATION_COMMAND" | sh
