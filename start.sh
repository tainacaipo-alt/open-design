#!/usr/bin/env bash
set -e

export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm use 24 > /dev/null 2>&1

cd /tmp/open-design

echo "Starting Open Design..."
echo ""
npx tsx tools/dev/src/index.ts run web
