#!/usr/bin/env bash
set -euo pipefail

# Smoke test runner for Lib_Microsoft_Teams sequences through Convertigo HTTP endpoint.
# The script uses:
# - an authenticated Convertigo browser session (JSESSIONID + XSRF token)
# - Azure app credentials for Graph application token mode
#
# Usage:
#   chmod +x scripts/smoke_sequences.sh
#   scripts/smoke_sequences.sh
#
# Required environment variables:
#   C8O_ADMIN_INSTANCE
#   C8O_XSRF_TOKEN
#   C8O_JSESSIONID
#   AZ_TENANT_ID
#   AZ_CLIENT_ID
#   AZ_CLIENT_SECRET
#
# Optional environment variables:
#   C8O_BASE_URL (default: http://localhost:18080/convertigo/projects/Lib_Microsoft_Teams/.json)
#   ORGANIZER_USER_ID (default: michelm@convertigo.onmicrosoft.com)
#   TIME_ZONE (default: Europe/Paris)
#   TEST_TEAM_ID (default: 00000000-0000-0000-0000-000000000000)
#   TEST_CHANNEL_ID (default: 19:dummy@thread.tacv2)
#   TEST_CHAT_ID (default: 19:dummy@thread.v2)
#   TEST_MEMBER_ID (default: dummy-member-id)
#   TEST_ONLINE_MEETING_ID (default: dummy-online-meeting-id)
#   TEST_RECORDING_ID (default: dummy-recording-id)
#   TEST_SUBSCRIPTION_ID (default: dummy-sub-id)
#   TEST_DRIVE_ITEM_WEB_URL (default: https://contoso.sharepoint.com/:x:/r/sites/demo/Shared%20Documents/file.txt)
#   TEST_NOTIFICATION_URL (default: https://example.com/webhook)

C8O_BASE_URL="${C8O_BASE_URL:-http://localhost:18080/convertigo/projects/Lib_Microsoft_Teams/.json}"
ORGANIZER_USER_ID="${ORGANIZER_USER_ID:-michelm@convertigo.onmicrosoft.com}"
TIME_ZONE="${TIME_ZONE:-Europe/Paris}"
TEST_TEAM_ID="${TEST_TEAM_ID:-00000000-0000-0000-0000-000000000000}"
TEST_CHANNEL_ID="${TEST_CHANNEL_ID:-19:dummy@thread.tacv2}"
TEST_CHAT_ID="${TEST_CHAT_ID:-19:dummy@thread.v2}"
TEST_MEMBER_ID="${TEST_MEMBER_ID:-dummy-member-id}"
TEST_ONLINE_MEETING_ID="${TEST_ONLINE_MEETING_ID:-dummy-online-meeting-id}"
TEST_RECORDING_ID="${TEST_RECORDING_ID:-dummy-recording-id}"
TEST_SUBSCRIPTION_ID="${TEST_SUBSCRIPTION_ID:-dummy-sub-id}"
TEST_DRIVE_ITEM_WEB_URL="${TEST_DRIVE_ITEM_WEB_URL:-https://contoso.sharepoint.com/:x:/r/sites/demo/Shared%20Documents/file.txt}"
TEST_NOTIFICATION_URL="${TEST_NOTIFICATION_URL:-https://example.com/webhook}"

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required env var: $name" >&2
    exit 1
  fi
}

# Validate required environment upfront.
require_env "C8O_ADMIN_INSTANCE"
require_env "C8O_XSRF_TOKEN"
require_env "C8O_JSESSIONID"
require_env "AZ_TENANT_ID"
require_env "AZ_CLIENT_ID"
require_env "AZ_CLIENT_SECRET"

# Build dynamic test timestamps used across event and planning sequences.
START_ISO="$(date -u -v+2d '+%Y-%m-%dT%H:00:00' 2>/dev/null || date -u -d '+2 days' '+%Y-%m-%dT%H:00:00')"
END_ISO="$(date -u -v+2d -v+30M '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -u -d '+2 days +30 minutes' '+%Y-%m-%dT%H:%M:%S')"
WINDOW_START_ISO="$(date -u -v+2d -v-1H '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -u -d '+2 days -1 hour' '+%Y-%m-%dT%H:%M:%S')"
WINDOW_END_ISO="$(date -u -v+4d '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -u -d '+4 days' '+%Y-%m-%dT%H:%M:%S')"
EXPIRATION_ISO="$(date -u -v+8H '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -d '+8 hours' '+%Y-%m-%dT%H:%M:%SZ')"

ATTENDEES_JSON="[{\"email\":\"${ORGANIZER_USER_ID}\",\"name\":\"Organizer\",\"type\":\"required\"}]"
SETTINGS_JSON='{"allowMeetingChat":"enabled"}'
CHECKS_JSON='["calendar","presence","chats"]'
METADATA_JSON='{"smoke":true}'
FILE_B64='Y29kZXggc21va2U='

RESULTS_FILE="$(mktemp)"
trap 'rm -f "$RESULTS_FILE"' EXIT

# HTTP helper that posts one sequence call with shared auth/session parameters.
call_sequence() {
  local sequence="$1"
  shift
  local -a args=(
    curl -sS "$C8O_BASE_URL"
    -H "Accept: */*"
    -H "Admin-Instance: $C8O_ADMIN_INSTANCE"
    -H "x-xsrf-token: $C8O_XSRF_TOKEN"
    -H "Content-Type: application/x-www-form-urlencoded"
    -b "introjs-dontShowAgain=true; JSESSIONID=$C8O_JSESSIONID"
    --data-urlencode "__sequence=$sequence"
    --data-urlencode "tenantId=$AZ_TENANT_ID"
    --data-urlencode "clientId=$AZ_CLIENT_ID"
    --data-urlencode "clientSecret=$AZ_CLIENT_SECRET"
  )

  local kv
  for kv in "$@"; do
    args+=(--data-urlencode "$kv")
  done

  "${args[@]}"
}

# Parse response payload and append one compact line to the result table.
record_result() {
  local sequence="$1"
  local raw="$2"
  local parsed

  parsed="$(python3 - "$raw" <<'PY'
import json, sys
raw = sys.argv[1]
try:
    payload = json.loads(raw)
except Exception:
    print("N/A\tINVALID\tInvalid JSON response")
    raise SystemExit(0)
resp = payload.get("response", {})
ok = resp.get("ok")
status = str(resp.get("status", ""))
err = str(resp.get("errorMessage", "") or "")
if len(err) > 180:
    err = err[:177] + "..."
if ok is True:
    print("OK\t" + status + "\t" + err)
elif ok is False:
    print("KO\t" + status + "\t" + err)
else:
    print("N/A\t" + status + "\t" + err)
PY
)"

  printf '%s\t%s\n' "$sequence" "$parsed" >> "$RESULTS_FILE"
}

# Extract eventId from CreateMeetingEvent response for chained calls.
extract_event_id() {
  local raw="$1"
  python3 - "$raw" <<'PY'
import json, sys
raw = sys.argv[1]
try:
    payload = json.loads(raw)
except Exception:
    print("")
    raise SystemExit(0)
print(payload.get("response", {}).get("data", {}).get("eventId", "") or "")
PY
}

# Run one sequence and immediately persist summarized output.
run_sequence() {
  local sequence="$1"
  shift
  local raw
  raw="$(call_sequence "$sequence" "$@")"
  record_result "$sequence" "$raw"
  printf '%s' "$raw"
}

echo "Starting smoke campaign against: $C8O_BASE_URL"
echo "Organizer: $ORGANIZER_USER_ID"
echo

# 1) Baseline read/probe calls.
run_sequence "ValidateGraphPermissions" \
  "userId=$ORGANIZER_USER_ID" \
  "checksJson=$CHECKS_JSON" >/dev/null

run_sequence "GetUserPresence" \
  "userId=$ORGANIZER_USER_ID" >/dev/null

run_sequence "ListUserChats" \
  "userId=$ORGANIZER_USER_ID" \
  "top=2" >/dev/null

run_sequence "ListMeetingEvents" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "top=3" \
  "provider=graph" >/dev/null

run_sequence "SuggestMeetingSlots" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "attendeesJson=$ATTENDEES_JSON" \
  "windowStartIso=$WINDOW_START_ISO" \
  "windowEndIso=$WINDOW_END_ISO" \
  "timeZone=$TIME_ZONE" \
  "meetingDurationMinutes=30" >/dev/null

# 2) Event creation flow (create -> read/update -> cleanup cancel).
CREATE_RAW="$(run_sequence "CreateMeetingEvent" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "subject=Codex smoke test" \
  "startIso=$START_ISO" \
  "endIso=$END_ISO" \
  "timeZone=$TIME_ZONE" \
  "attendeesJson=$ATTENDEES_JSON" \
  "bodyHtml=<p>Codex smoke test</p>" \
  "isOnlineMeeting=true" \
  "provider=graph")"

EVENT_ID="$(extract_event_id "$CREATE_RAW")"
if [[ -z "$EVENT_ID" ]]; then
  EVENT_ID="dummy-event-id"
fi

run_sequence "GetMeetingEvent" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "eventId=$EVENT_ID" \
  "provider=graph" >/dev/null

run_sequence "FindMeetingEvent" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "eventId=$EVENT_ID" >/dev/null

run_sequence "ListMeetingInstances" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "eventId=$EVENT_ID" \
  "windowStartIso=$WINDOW_START_ISO" \
  "windowEndIso=$WINDOW_END_ISO" >/dev/null

run_sequence "AttachMeetingCustomMetadata" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "eventId=$EVENT_ID" \
  "extensionId=com.convertigo.meeting" \
  "metadataJson=$METADATA_JSON" \
  "mergeMode=merge" >/dev/null

run_sequence "UpdateMeetingEvent" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "eventId=$EVENT_ID" \
  "subject=Codex smoke test updated" \
  "provider=graph" \
  "sendUpdates=none" >/dev/null

run_sequence "RespondToMeetingEvent" \
  "userId=$ORGANIZER_USER_ID" \
  "eventId=$EVENT_ID" \
  "responseAction=tentativelyAccept" \
  "sendResponse=false" >/dev/null

run_sequence "CancelMeetingEvent" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "eventId=$EVENT_ID" \
  "cancelComment=Codex cleanup" \
  "sendCancellation=false" \
  "provider=graph" >/dev/null

# 3) Teams/online meeting/files/subscription related calls.
run_sequence "CreateOnlineMeeting" \
  "userId=$ORGANIZER_USER_ID" \
  "subject=Codex online smoke" \
  "startDateTimeIso=$START_ISO" \
  "endDateTimeIso=$END_ISO" >/dev/null

run_sequence "GetOnlineMeetingByJoinUrl" \
  "userId=$ORGANIZER_USER_ID" \
  "joinWebUrl=https://teams.microsoft.com/l/meetup-join/19%3Ameeting_dummy%40thread.v2/0?context=%7B%7D" >/dev/null

run_sequence "UpdateOnlineMeetingSettings" \
  "userId=$ORGANIZER_USER_ID" \
  "onlineMeetingId=$TEST_ONLINE_MEETING_ID" \
  "settingsJson=$SETTINGS_JSON" >/dev/null

run_sequence "ListMeetingRecordings" \
  "userId=$ORGANIZER_USER_ID" \
  "onlineMeetingId=$TEST_ONLINE_MEETING_ID" \
  "top=1" >/dev/null

run_sequence "GetMeetingRecording" \
  "userId=$ORGANIZER_USER_ID" \
  "onlineMeetingId=$TEST_ONLINE_MEETING_ID" \
  "recordingId=$TEST_RECORDING_ID" >/dev/null

run_sequence "GetMeetingTranscripts" \
  "userId=$ORGANIZER_USER_ID" \
  "onlineMeetingId=$TEST_ONLINE_MEETING_ID" \
  "top=1" >/dev/null

run_sequence "CreateTeam" \
  "displayName=Codex Smoke Team" \
  "templateName=standard" \
  "visibility=Private" >/dev/null

run_sequence "CreateTeamChannel" \
  "teamId=$TEST_TEAM_ID" \
  "displayName=general-smoke" >/dev/null

run_sequence "ListTeamChannels" \
  "teamId=$TEST_TEAM_ID" \
  "top=1" >/dev/null

run_sequence "AddTeamMember" \
  "teamId=$TEST_TEAM_ID" \
  "userId=$ORGANIZER_USER_ID" \
  "rolesCsv=member" >/dev/null

run_sequence "RemoveTeamMember" \
  "teamId=$TEST_TEAM_ID" \
  "memberId=$TEST_MEMBER_ID" >/dev/null

run_sequence "SendChannelMessage" \
  "teamId=$TEST_TEAM_ID" \
  "channelId=$TEST_CHANNEL_ID" \
  "message=Codex smoke channel message" >/dev/null

run_sequence "SendChatMessage" \
  "chatId=$TEST_CHAT_ID" \
  "message=Codex smoke chat message" >/dev/null

run_sequence "ShareDriveItemToChatOrChannel" \
  "targetType=chat" \
  "chatId=$TEST_CHAT_ID" \
  "driveItemWebUrl=$TEST_DRIVE_ITEM_WEB_URL" \
  "message=Codex shared link" >/dev/null

run_sequence "UploadMeetingAttachment" \
  "userId=$ORGANIZER_USER_ID" \
  "fileName=codex-smoke.txt" \
  "fileContentBase64=$FILE_B64" >/dev/null

run_sequence "SubscribeMeetingChanges" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "notificationUrl=$TEST_NOTIFICATION_URL" \
  "expirationDateTimeIso=$EXPIRATION_ISO" \
  "changeType=created,updated,deleted" >/dev/null

run_sequence "RenewMeetingSubscription" \
  "subscriptionId=$TEST_SUBSCRIPTION_ID" \
  "expirationDateTimeIso=$EXPIRATION_ISO" >/dev/null

run_sequence "UnsubscribeMeetingChanges" \
  "subscriptionId=$TEST_SUBSCRIPTION_ID" >/dev/null

run_sequence "PlanAndCreateMeeting" \
  "organizerUserId=$ORGANIZER_USER_ID" \
  "subject=Codex plan smoke" \
  "attendeesJson=$ATTENDEES_JSON" \
  "searchWindowStartIso=$WINDOW_START_ISO" \
  "searchWindowEndIso=$WINDOW_END_ISO" \
  "timeZone=$TIME_ZONE" \
  "meetingDurationMinutes=30" \
  "strategy=earliest" \
  "strictSlotSelection=true" >/dev/null

# 4) Print summary table and aggregate totals.
echo "Sequence\tResult\tStatus\tError"
cat "$RESULTS_FILE"

read -r TOTAL_COUNT OK_COUNT KO_COUNT <<EOF
$(python3 - "$RESULTS_FILE" <<'PY'
import sys
p = sys.argv[1]
total = ok = ko = 0
with open(p, "r", encoding="utf-8") as f:
    for line in f:
        if not line.strip():
            continue
        total += 1
        cols = line.rstrip("\n").split("\t")
        if len(cols) >= 2:
            if cols[1] == "OK":
                ok += 1
            elif cols[1] == "KO":
                ko += 1
print(f"{total} {ok} {ko}")
PY
)
EOF

echo
echo "Summary: total=${TOTAL_COUNT} ok=${OK_COUNT} ko=${KO_COUNT}"
echo "Event used for event-flow chain: ${EVENT_ID}"
