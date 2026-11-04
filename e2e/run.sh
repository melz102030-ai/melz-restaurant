#!/usr/bin/env bash
# يعمل داخل emulators:exec: يشغّل خادم الطلبات والموقع، ثم الرحلة. كله محلي.
set -u

(cd cloudflare/lean-payments && npx --yes wrangler@latest dev --port 8787 --ip 127.0.0.1 \
  --var FIREBASE_PROJECT_ID:demo-melz \
  --var FIRESTORE_EMULATOR_ORIGIN:http://127.0.0.1:8080 \
  > "$RUNNER_TEMP/worker.log" 2>&1) &
node e2e/serve.mjs build/web 5000 &

for _ in $(seq 1 90); do
  if curl -s -o /dev/null http://127.0.0.1:8787/ && curl -s -o /dev/null http://127.0.0.1:5000/; then
    node e2e/order_flow.mjs
    status=$?
    if [ "$status" -ne 0 ]; then
      grep -iE "error|exception|failed" "$RUNNER_TEMP/worker.log" | tail -n 3 | sed 's/^/الخادم: /' >> "$E2E_ERRORS"
    fi
    exit "$status"
  fi
  sleep 2
done
echo "لم يعمل خادم الطلبات" >> "$E2E_ERRORS"
tail -n 5 "$RUNNER_TEMP/worker.log" >> "$E2E_ERRORS"
exit 1
