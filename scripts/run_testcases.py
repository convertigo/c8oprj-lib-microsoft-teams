#!/usr/bin/env python3
"""
Logical end-to-end test plan orchestrator for Lib_Microsoft_Teams sequences.

The plan runs in phases:
1) Permission and capability discovery
2) Core meeting lifecycle (mandatory)
3) Planning flows (optional)
4) Optional feature checks gated by capabilities and provided IDs

This script calls Convertigo over HTTP using:
- a provided Convertigo session (JSESSIONID / X-Convertigo-Authenticated), or
- an automatic login sequence call (default: ClientSDKtesting/login).
Graph credentials are optional here: if not provided, sequences rely on server-side symbols/defaults.
"""

from __future__ import annotations

import datetime as dt
import json
import os
import re
import sys
import traceback
import urllib.parse
import urllib.request
from typing import Any, Callable, Dict, List, Optional


def _env(name: str, default: Optional[str] = None, required: bool = False) -> str:
    value = os.getenv(name, default)
    if required and (value is None or value == ""):
        raise RuntimeError(f"Missing required environment variable: {name}")
    return "" if value is None else value


def _env_bool(name: str, default: str) -> bool:
    return _env(name, default).strip().lower() in {"1", "true", "yes", "y", "on"}


# Convertigo session/auth context.
TEST_SERVER_ENDPOINT = _env("TEST_SERVER_ENDPOINT", "")
C8O_SERVER_URL = _env("C8O_SERVER_URL", TEST_SERVER_ENDPOINT or "http://localhost:18080")
C8O_PROJECT = _env("C8O_PROJECT", "Lib_Microsoft_Teams")
C8O_BASE_URL = _env(
    "C8O_BASE_URL",
    f"{C8O_SERVER_URL}/convertigo/projects/{C8O_PROJECT}/.json",
)
C8O_ADMIN_INSTANCE = _env("C8O_ADMIN_INSTANCE", "")
C8O_XSRF_TOKEN = _env("C8O_XSRF_TOKEN", "")
C8O_JSESSIONID = _env("C8O_JSESSIONID", "")
C8O_XAUTH_TOKEN = _env("C8O_XAUTH_TOKEN", "")
C8O_AUTO_LOGIN = _env_bool("C8O_AUTO_LOGIN", "true")
C8O_LOGIN_PROJECT = _env("C8O_LOGIN_PROJECT", "ClientSDKtesting")
C8O_LOGIN_SEQUENCE = _env("C8O_LOGIN_SEQUENCE", "login")
C8O_LOGIN_BASE_URL = _env(
    "C8O_LOGIN_BASE_URL",
    f"{C8O_SERVER_URL}/convertigo/projects/{C8O_LOGIN_PROJECT}/.json",
)
C8O_LOGIN_EXTRA_FORM = _env("C8O_LOGIN_EXTRA_FORM", "")

# Token mode: delegated (ACCESS_TOKEN) or application (tenant/client/secret).
ACCESS_TOKEN = _env("ACCESS_TOKEN", "")
AZ_TENANT_ID = _env("AZ_TENANT_ID", "")
AZ_CLIENT_ID = _env("AZ_CLIENT_ID", "")
AZ_CLIENT_SECRET = _env("AZ_CLIENT_SECRET", "")
if any([AZ_TENANT_ID, AZ_CLIENT_ID, AZ_CLIENT_SECRET]) and not all(
    [AZ_TENANT_ID, AZ_CLIENT_ID, AZ_CLIENT_SECRET]
):
    raise RuntimeError("If AZ_* variables are used, provide all 3: AZ_TENANT_ID/AZ_CLIENT_ID/AZ_CLIENT_SECRET")

if ACCESS_TOKEN:
    TOKEN_MODE = "delegated_explicit"
elif AZ_TENANT_ID and AZ_CLIENT_ID and AZ_CLIENT_SECRET:
    TOKEN_MODE = "application_explicit"
else:
    TOKEN_MODE = "server_symbols_or_defaults"

# Primary business context.
ORGANIZER_USER_ID = _env("ORGANIZER_USER_ID", "michelm@convertigo.onmicrosoft.com")
TIME_ZONE = _env("TIME_ZONE", "Europe/Paris")

# Optional contexts for additional phases.
TEAM_ID = _env("TEAM_ID", "")
CHANNEL_ID = _env("CHANNEL_ID", "")
CHAT_ID = _env("CHAT_ID", "")
TARGET_MEMBER_USER_ID = _env("TARGET_MEMBER_USER_ID", ORGANIZER_USER_ID)
SERIES_MASTER_EVENT_ID = _env("SERIES_MASTER_EVENT_ID", "")
RESPOND_EVENT_ID = _env("RESPOND_EVENT_ID", "")
RESPOND_EVENT_USER_ID = _env("RESPOND_EVENT_USER_ID", ORGANIZER_USER_ID)
TEAM_DISPLAY_NAME_PREFIX = _env("TEAM_DISPLAY_NAME_PREFIX", "C8O TestPlan Team")
TEAM_CHANNEL_DISPLAY_NAME = _env("TEAM_CHANNEL_DISPLAY_NAME", "c8o-test-channel")
TEAM_CHANNEL_MEMBERSHIP_TYPE = _env("TEAM_CHANNEL_MEMBERSHIP_TYPE", "standard")
WEBHOOK_URL = _env("WEBHOOK_URL", "")
RUN_TEAM_WRITES = _env("RUN_TEAM_WRITES", "false").lower() == "true"
RUN_MESSAGE_WRITES = _env("RUN_MESSAGE_WRITES", "false").lower() == "true"
RUN_EVENT_RESPONSE_WRITES = _env("RUN_EVENT_RESPONSE_WRITES", "false").lower() == "true"
REPORT_FILE = _env("REPORT_FILE", "build/logical-test-plan-report.json")

# Mutable session state used by call_sequence.
SESSION: Dict[str, str] = {
    "jsessionid": C8O_JSESSIONID,
    "xauth": C8O_XAUTH_TOKEN,
}


def _json_dumps(value: Any) -> str:
    return json.dumps(value, separators=(",", ":"), ensure_ascii=True)


def _parse_form_pairs(raw_pairs: str) -> Dict[str, str]:
    parsed: Dict[str, str] = {}
    if raw_pairs.strip() == "":
        return parsed
    for chunk in raw_pairs.split("&"):
        if chunk == "":
            continue
        if "=" in chunk:
            key, value = chunk.split("=", 1)
        else:
            key, value = chunk, ""
        if key:
            parsed[key] = value
    return parsed


def _decode_payload(raw: str) -> Dict[str, Any]:
    try:
        return json.loads(raw)
    except Exception:
        return {"_raw": raw}


def _payload_is_login_ok(payload: Dict[str, Any]) -> bool:
    # login sequence may return either {"document":{"ok":"true"}} or {"response":{"ok":true}}
    doc = payload.get("document")
    if isinstance(doc, dict):
        return str(doc.get("ok", "")).lower() == "true"
    resp = payload.get("response")
    return isinstance(resp, dict) and resp.get("ok") is True


def _auto_login() -> None:
    form: Dict[str, str] = {"__sequence": C8O_LOGIN_SEQUENCE}
    form.update(_parse_form_pairs(C8O_LOGIN_EXTRA_FORM))
    body = urllib.parse.urlencode(form).encode("utf-8")

    headers = {
        "Accept": "*/*",
        "Content-Type": "application/x-www-form-urlencoded",
    }
    if C8O_ADMIN_INSTANCE:
        headers["Admin-Instance"] = C8O_ADMIN_INSTANCE
    if C8O_XSRF_TOKEN:
        headers["x-xsrf-token"] = C8O_XSRF_TOKEN

    req = urllib.request.Request(
        C8O_LOGIN_BASE_URL,
        data=body,
        method="POST",
        headers=headers,
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        raw = resp.read().decode("utf-8", errors="replace")
        set_cookies = resp.headers.get_all("Set-Cookie", [])
        xauth = resp.headers.get("X-Convertigo-Authenticated", "")

    payload = _decode_payload(raw)
    if not _payload_is_login_ok(payload):
        raise RuntimeError(
            f"Auto-login failed on {C8O_LOGIN_PROJECT}/{C8O_LOGIN_SEQUENCE}: {response_error(payload)}"
        )

    jsessionid = ""
    for cookie in set_cookies:
        match = re.search(r"(?i)\bJSESSIONID=([^;]+)", cookie)
        if match:
            jsessionid = match.group(1)
            break
    if jsessionid == "":
        raise RuntimeError("Auto-login failed: missing JSESSIONID in Set-Cookie headers")

    SESSION["jsessionid"] = jsessionid
    SESSION["xauth"] = xauth


def _ensure_session() -> None:
    if SESSION.get("jsessionid", "") != "":
        return
    if C8O_AUTO_LOGIN:
        _auto_login()


def call_sequence(sequence: str, params: Dict[str, Any]) -> Dict[str, Any]:
    """Execute one Convertigo sequence call and return parsed JSON payload."""
    _ensure_session()

    form: Dict[str, str] = {"__sequence": sequence}
    for key, value in params.items():
        if value is None:
            continue
        form[key] = str(value)

    # Inject explicit auth fields only when provided by environment.
    # Otherwise, sequence variables should resolve to server-side symbols/defaults.
    if TOKEN_MODE == "delegated_explicit":
        form.setdefault("accessToken", ACCESS_TOKEN)
    elif TOKEN_MODE == "application_explicit":
        form.setdefault("tenantId", AZ_TENANT_ID)
        form.setdefault("clientId", AZ_CLIENT_ID)
        form.setdefault("clientSecret", AZ_CLIENT_SECRET)

    body = urllib.parse.urlencode(form).encode("utf-8")
    headers = {
        "Accept": "*/*",
        "Content-Type": "application/x-www-form-urlencoded",
    }
    if C8O_ADMIN_INSTANCE:
        headers["Admin-Instance"] = C8O_ADMIN_INSTANCE
    if C8O_XSRF_TOKEN:
        headers["x-xsrf-token"] = C8O_XSRF_TOKEN
    if SESSION.get("jsessionid", ""):
        headers["Cookie"] = f"introjs-dontShowAgain=true; JSESSIONID={SESSION['jsessionid']}"
    if SESSION.get("xauth", ""):
        headers["X-Convertigo-Authenticated"] = SESSION["xauth"]

    req = urllib.request.Request(
        C8O_BASE_URL,
        data=body,
        method="POST",
        headers=headers,
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        raw = resp.read().decode("utf-8", errors="replace")
    return _decode_payload(raw)


def response_ok(payload: Dict[str, Any]) -> bool:
    resp = payload.get("response")
    return isinstance(resp, dict) and resp.get("ok") is True


def response_error(payload: Dict[str, Any]) -> str:
    if isinstance(payload.get("error"), dict):
        return str(payload["error"].get("message", "Convertigo error"))
    resp = payload.get("response")
    if not isinstance(resp, dict):
        raw = payload.get("_raw", "")
        return "Invalid payload" if not raw else raw[:240]
    msg = str(resp.get("errorMessage", "") or "")
    if msg:
        return msg
    return str(resp.get("status", "ERROR"))


def response_data(payload: Dict[str, Any]) -> Dict[str, Any]:
    resp = payload.get("response")
    if not isinstance(resp, dict):
        return {}
    data = resp.get("data")
    return data if isinstance(data, dict) else {}


def _extract_first_item_id(data: Dict[str, Any]) -> str:
    items = data.get("items")
    if isinstance(items, list) and len(items) > 0 and isinstance(items[0], dict):
        return str(items[0].get("id", "") or "")
    return ""


def _extract_team_id_from_data(data: Dict[str, Any]) -> str:
    # CreateTeam can be asynchronous and may return id in multiple shapes.
    for key in ("teamId", "id"):
        value = str(data.get(key, "") or "")
        if value:
            return value

    team_obj = data.get("team")
    if isinstance(team_obj, dict):
        value = str(team_obj.get("id", "") or "")
        if value:
            return value

    operation_location = str(data.get("operationLocation", "") or "")
    if operation_location:
        # Supports both /teams/{guid} and /teams('guid') styles.
        patterns = [
            r"/teams/([0-9a-fA-F-]{36})(?:[/?]|$)",
            r"/teams\('([0-9a-fA-F-]{36})'\)",
            r"/teams\(%27([0-9a-fA-F-]{36})%27\)",
        ]
        for pattern in patterns:
            match = re.search(pattern, operation_location)
            if match:
                return match.group(1)

    return ""


class TestPlan:
    def __init__(self) -> None:
        self.results: List[Dict[str, Any]] = []
        self.ctx: Dict[str, Any] = {
            "created_event_id": "",
            "listed_event_id": "",
            "created_online_meeting_id": "",
            "created_online_meeting_join_url": "",
            "first_recording_id": "",
            "created_team_id": "",
            "created_team_channel_id": "",
            "created_team_member_id": "",
            "created_subscription_id": "",
            "capabilities": {},
        }
        self.mandatory_failed = False

    def add_result(
        self,
        phase: str,
        step: str,
        outcome: str,
        mandatory: bool,
        details: str = "",
    ) -> None:
        self.results.append(
            {
                "phase": phase,
                "step": step,
                "outcome": outcome,
                "mandatory": mandatory,
                "details": details,
            }
        )
        tag = "MANDATORY" if mandatory else "OPTIONAL"
        if outcome == "PASS":
            print(f"[PASS] [{phase}] {step} ({tag})")
        elif outcome == "SKIP":
            print(f"[SKIP] [{phase}] {step} ({tag}) {details}")
        else:
            print(f"[FAIL] [{phase}] {step} ({tag}) {details}")
            if mandatory:
                self.mandatory_failed = True

    def run_step(
        self,
        phase: str,
        step: str,
        sequence: str,
        params: Dict[str, Any],
        mandatory: bool = False,
        enabled: bool = True,
        validator: Optional[Callable[[Dict[str, Any]], bool]] = None,
        on_success: Optional[Callable[[Dict[str, Any], Dict[str, Any]], None]] = None,
    ) -> bool:
        if not enabled:
            self.add_result(phase, step, "SKIP", mandatory, "disabled by context/capabilities")
            return False

        try:
            payload = call_sequence(sequence, params)
            ok = response_ok(payload) if validator is None else bool(validator(payload))
            if ok:
                if on_success is not None:
                    on_success(payload, self.ctx)
                self.add_result(phase, step, "PASS", mandatory)
                return True
            self.add_result(phase, step, "FAIL", mandatory, response_error(payload))
            return False
        except Exception as exc:
            self.add_result(phase, step, "FAIL", mandatory, f"{exc.__class__.__name__}: {exc}")
            return False

    def capability_ok(self, name: str) -> bool:
        caps = self.ctx.get("capabilities", {})
        if not isinstance(caps, dict):
            return False
        return caps.get(name, "") == "OK"

    def write_report(self) -> None:
        os.makedirs(os.path.dirname(REPORT_FILE) or ".", exist_ok=True)
        payload = {
            "timestamp": dt.datetime.now(dt.timezone.utc).isoformat(),
            "project": C8O_PROJECT,
            "baseUrl": C8O_BASE_URL,
            "organizerUserId": ORGANIZER_USER_ID,
            "tokenMode": TOKEN_MODE,
            "convertigoSession": {
                "hasJSessionId": bool(SESSION.get("jsessionid")),
                "hasXAuthToken": bool(SESSION.get("xauth")),
                "autoLoginEnabled": C8O_AUTO_LOGIN,
                "loginProject": C8O_LOGIN_PROJECT,
                "loginSequence": C8O_LOGIN_SEQUENCE,
            },
            "results": self.results,
            "context": self.ctx,
            "summary": self.summary(),
        }
        with open(REPORT_FILE, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2, ensure_ascii=False)

    def summary(self) -> Dict[str, int]:
        total = len(self.results)
        passed = sum(1 for r in self.results if r["outcome"] == "PASS")
        failed = sum(1 for r in self.results if r["outcome"] == "FAIL")
        skipped = sum(1 for r in self.results if r["outcome"] == "SKIP")
        mandatory_failed = sum(
            1 for r in self.results if r["outcome"] == "FAIL" and bool(r["mandatory"])
        )
        return {
            "total": total,
            "passed": passed,
            "failed": failed,
            "skipped": skipped,
            "mandatoryFailed": mandatory_failed,
        }


def main() -> int:
    plan = TestPlan()
    now = dt.datetime.now(dt.timezone.utc)
    start = (now + dt.timedelta(days=2)).replace(minute=0, second=0, microsecond=0)
    end = start + dt.timedelta(minutes=30)
    window_start = start - dt.timedelta(hours=1)
    window_end = start + dt.timedelta(days=2)
    expiration = now + dt.timedelta(hours=8)
    attendees_json = _json_dumps(
        [{"email": ORGANIZER_USER_ID, "name": "Organizer", "type": "required"}]
    )

    print(f"Logical test plan for project {C8O_PROJECT}")
    print(f"Organizer user: {ORGANIZER_USER_ID}")
    print(f"Token mode: {TOKEN_MODE}")
    if SESSION.get("jsessionid", ""):
        print("Convertigo session: provided by environment")
    elif C8O_AUTO_LOGIN:
        _ensure_session()
        print(f"Convertigo session: auto-login OK via {C8O_LOGIN_PROJECT}/{C8O_LOGIN_SEQUENCE}")
    else:
        print("Convertigo session: none (authenticated sequences may fail)")
    print()

    # Phase 1: Discover granted capabilities with a lightweight probe sequence.
    def save_caps(payload: Dict[str, Any], ctx: Dict[str, Any]) -> None:
        caps: Dict[str, str] = {}
        for item in response_data(payload).get("results", []):
            if isinstance(item, dict):
                caps[str(item.get("check", ""))] = str(item.get("status", ""))
        ctx["capabilities"] = caps

    plan.run_step(
        "phase-1-capabilities",
        "ValidateGraphPermissions",
        "ValidateGraphPermissions",
        {
            "userId": ORGANIZER_USER_ID,
            "checksJson": _json_dumps(
                ["calendar", "onlineMeetings", "joinedTeams", "chats", "presence", "drive"]
            ),
        },
        mandatory=False,
        on_success=save_caps,
    )

    # Phase 2: Core meeting lifecycle (mandatory for business scope).
    subject_base = f"C8O TestPlan {start.strftime('%Y%m%d%H%M')}"

    def save_event_id(payload: Dict[str, Any], ctx: Dict[str, Any]) -> None:
        ctx["created_event_id"] = str(response_data(payload).get("eventId", ""))

    plan.run_step(
        "phase-2-core-meeting",
        "CreateMeetingEvent",
        "CreateMeetingEvent",
        {
            "organizerUserId": ORGANIZER_USER_ID,
            "subject": subject_base,
            "startIso": start.strftime("%Y-%m-%dT%H:%M:%S"),
            "endIso": end.strftime("%Y-%m-%dT%H:%M:%S"),
            "timeZone": TIME_ZONE,
            "attendeesJson": attendees_json,
            "bodyHtml": "<p>Logical test plan</p>",
            "isOnlineMeeting": "true",
            "provider": "graph",
        },
        mandatory=True,
        on_success=save_event_id,
    )

    event_id = str(plan.ctx.get("created_event_id", ""))
    has_event = bool(event_id)

    def save_listed_event_id(payload: Dict[str, Any], ctx: Dict[str, Any]) -> None:
        ctx["listed_event_id"] = _extract_first_item_id(response_data(payload))

    plan.run_step(
        "phase-2-core-meeting",
        "GetMeetingEvent",
        "GetMeetingEvent",
        {"organizerUserId": ORGANIZER_USER_ID, "eventId": event_id, "provider": "graph"},
        mandatory=True,
        enabled=has_event,
    )
    plan.run_step(
        "phase-2-core-meeting",
        "ListMeetingEvents",
        "ListMeetingEvents",
        {
            "organizerUserId": ORGANIZER_USER_ID,
            "windowStartIso": window_start.strftime("%Y-%m-%dT%H:%M:%S"),
            "windowEndIso": window_end.strftime("%Y-%m-%dT%H:%M:%S"),
            "top": "10",
            "provider": "graph",
        },
        mandatory=False,
        on_success=save_listed_event_id,
    )

    series_master_event_id = (
        SERIES_MASTER_EVENT_ID
        or str(plan.ctx.get("listed_event_id", ""))
        or event_id
    )
    plan.run_step(
        "phase-2-core-meeting",
        "ListMeetingInstances",
        "ListMeetingInstances",
        {
            "organizerUserId": ORGANIZER_USER_ID,
            "eventId": series_master_event_id,
            "windowStartIso": window_start.strftime("%Y-%m-%dT%H:%M:%S"),
            "windowEndIso": window_end.strftime("%Y-%m-%dT%H:%M:%S"),
            "top": "10",
        },
        mandatory=False,
        enabled=bool(series_master_event_id),
    )
    plan.run_step(
        "phase-2-core-meeting",
        "FindMeetingEvent",
        "FindMeetingEvent",
        {"organizerUserId": ORGANIZER_USER_ID, "eventId": event_id},
        mandatory=True,
        enabled=has_event,
    )
    plan.run_step(
        "phase-2-core-meeting",
        "UpdateMeetingEvent",
        "UpdateMeetingEvent",
        {
            "organizerUserId": ORGANIZER_USER_ID,
            "eventId": event_id,
            "subject": subject_base + " Updated",
            "sendUpdates": "none",
            "provider": "graph",
        },
        mandatory=True,
        enabled=has_event,
    )
    plan.run_step(
        "phase-2-core-meeting",
        "AttachMeetingCustomMetadata",
        "AttachMeetingCustomMetadata",
        {
            "organizerUserId": ORGANIZER_USER_ID,
            "eventId": event_id,
            "extensionId": "com.convertigo.meeting",
            "metadataJson": _json_dumps({"testPlan": True, "at": start.isoformat()}),
            "mergeMode": "merge",
        },
        mandatory=False,
        enabled=has_event,
    )

    respond_event_id = RESPOND_EVENT_ID or event_id
    plan.run_step(
        "phase-2-core-meeting",
        "RespondToMeetingEvent",
        "RespondToMeetingEvent",
        {
            "userId": RESPOND_EVENT_USER_ID,
            "eventId": respond_event_id,
            "responseAction": "tentativelyAccept",
            "sendResponse": "false",
            "comment": "C8O logical test response",
        },
        mandatory=False,
        enabled=RUN_EVENT_RESPONSE_WRITES and has_event and bool(respond_event_id),
    )
    plan.run_step(
        "phase-2-core-meeting",
        "CancelMeetingEvent",
        "CancelMeetingEvent",
        {
            "organizerUserId": ORGANIZER_USER_ID,
            "eventId": event_id,
            "cancelComment": "Logical test plan cleanup",
            "sendCancellation": "false",
            "provider": "graph",
        },
        mandatory=True,
        enabled=has_event,
    )

    # Phase 3: Planning (optional but useful functional validation).
    plan.run_step(
        "phase-3-planning",
        "SuggestMeetingSlots",
        "SuggestMeetingSlots",
        {
            "organizerUserId": ORGANIZER_USER_ID,
            "attendeesJson": attendees_json,
            "windowStartIso": window_start.strftime("%Y-%m-%dT%H:%M:%S"),
            "windowEndIso": window_end.strftime("%Y-%m-%dT%H:%M:%S"),
            "timeZone": TIME_ZONE,
            "meetingDurationMinutes": "30",
        },
        mandatory=False,
    )
    plan.run_step(
        "phase-3-planning",
        "PlanAndCreateMeeting",
        "PlanAndCreateMeeting",
        {
            "organizerUserId": ORGANIZER_USER_ID,
            "subject": "C8O Planned Meeting",
            "attendeesJson": attendees_json,
            "searchWindowStartIso": window_start.strftime("%Y-%m-%dT%H:%M:%S"),
            "searchWindowEndIso": window_end.strftime("%Y-%m-%dT%H:%M:%S"),
            "timeZone": TIME_ZONE,
            "meetingDurationMinutes": "30",
            "strategy": "earliest",
            "strictSlotSelection": "true",
        },
        mandatory=False,
    )

    # Phase 4: Online meeting optional path.
    online_enabled = plan.capability_ok("onlineMeetings")

    def save_online(payload: Dict[str, Any], ctx: Dict[str, Any]) -> None:
        data = response_data(payload)
        ctx["created_online_meeting_id"] = str(data.get("onlineMeetingId", ""))
        ctx["created_online_meeting_join_url"] = str(data.get("joinWebUrl", ""))

    plan.run_step(
        "phase-4-online-meeting",
        "CreateOnlineMeeting",
        "CreateOnlineMeeting",
        {
            "userId": ORGANIZER_USER_ID,
            "subject": "C8O Online Meeting",
            "startDateTimeIso": start.strftime("%Y-%m-%dT%H:%M:%S"),
            "endDateTimeIso": end.strftime("%Y-%m-%dT%H:%M:%S"),
        },
        mandatory=False,
        enabled=online_enabled,
        on_success=save_online,
    )

    online_meeting_id = str(plan.ctx.get("created_online_meeting_id", ""))
    join_url = str(plan.ctx.get("created_online_meeting_join_url", ""))

    def save_first_recording_id(payload: Dict[str, Any], ctx: Dict[str, Any]) -> None:
        ctx["first_recording_id"] = _extract_first_item_id(response_data(payload))

    plan.run_step(
        "phase-4-online-meeting",
        "UpdateOnlineMeetingSettings",
        "UpdateOnlineMeetingSettings",
        {
            "userId": ORGANIZER_USER_ID,
            "onlineMeetingId": online_meeting_id,
            "settingsJson": _json_dumps({"allowMeetingChat": "enabled"}),
        },
        mandatory=False,
        enabled=online_enabled and bool(online_meeting_id),
    )
    plan.run_step(
        "phase-4-online-meeting",
        "GetOnlineMeetingByJoinUrl",
        "GetOnlineMeetingByJoinUrl",
        {"userId": ORGANIZER_USER_ID, "joinWebUrl": join_url},
        mandatory=False,
        enabled=online_enabled and bool(join_url),
    )
    plan.run_step(
        "phase-4-online-meeting",
        "ListMeetingRecordings",
        "ListMeetingRecordings",
        {"userId": ORGANIZER_USER_ID, "onlineMeetingId": online_meeting_id, "top": "1"},
        mandatory=False,
        enabled=online_enabled and bool(online_meeting_id),
        on_success=save_first_recording_id,
    )
    plan.run_step(
        "phase-4-online-meeting",
        "GetMeetingRecording",
        "GetMeetingRecording",
        {
            "userId": ORGANIZER_USER_ID,
            "onlineMeetingId": online_meeting_id,
            "recordingId": str(plan.ctx.get("first_recording_id", "")),
        },
        mandatory=False,
        enabled=online_enabled and bool(online_meeting_id) and bool(plan.ctx.get("first_recording_id")),
    )
    plan.run_step(
        "phase-4-online-meeting",
        "GetMeetingTranscripts",
        "GetMeetingTranscripts",
        {"userId": ORGANIZER_USER_ID, "onlineMeetingId": online_meeting_id, "top": "1"},
        mandatory=False,
        enabled=online_enabled and bool(online_meeting_id),
    )

    # Phase 5: Team/channel/chat/presence optional paths.
    plan.run_step(
        "phase-5-collaboration",
        "GetUserPresence",
        "GetUserPresence",
        {"userId": ORGANIZER_USER_ID},
        mandatory=False,
        enabled=plan.capability_ok("presence"),
    )
    plan.run_step(
        "phase-5-collaboration",
        "ListUserChats",
        "ListUserChats",
        {"userId": ORGANIZER_USER_ID, "top": "5"},
        mandatory=False,
        enabled=plan.capability_ok("chats"),
    )

    def save_created_team(payload: Dict[str, Any], ctx: Dict[str, Any]) -> None:
        ctx["created_team_id"] = _extract_team_id_from_data(response_data(payload))

    def save_created_team_channel(payload: Dict[str, Any], ctx: Dict[str, Any]) -> None:
        data = response_data(payload)
        ctx["created_team_channel_id"] = str(data.get("channelId", "") or data.get("id", "") or "")

    team_writes_enabled = plan.capability_ok("joinedTeams") and RUN_TEAM_WRITES
    plan.run_step(
        "phase-5-collaboration",
        "CreateTeam",
        "CreateTeam",
        {
            "displayName": f"{TEAM_DISPLAY_NAME_PREFIX} {start.strftime('%Y%m%d%H%M')}",
            "description": "Team created by logical test plan",
            "visibility": "Private",
            "templateName": "standard",
            "ownerUserIdsJson": _json_dumps([ORGANIZER_USER_ID]),
        },
        mandatory=False,
        enabled=team_writes_enabled,
        on_success=save_created_team,
    )

    effective_team_id = str(plan.ctx.get("created_team_id", "")) or TEAM_ID
    plan.run_step(
        "phase-5-collaboration",
        "CreateTeamChannel",
        "CreateTeamChannel",
        {
            "teamId": effective_team_id,
            "displayName": TEAM_CHANNEL_DISPLAY_NAME,
            "description": "Channel created by logical test plan",
            "membershipType": TEAM_CHANNEL_MEMBERSHIP_TYPE,
        },
        mandatory=False,
        enabled=team_writes_enabled and bool(effective_team_id),
        on_success=save_created_team_channel,
    )

    effective_channel_id = str(plan.ctx.get("created_team_channel_id", "")) or CHANNEL_ID
    plan.run_step(
        "phase-5-collaboration",
        "ListTeamChannels",
        "ListTeamChannels",
        {"teamId": effective_team_id, "top": "5"},
        mandatory=False,
        enabled=plan.capability_ok("joinedTeams") and bool(effective_team_id),
    )

    # Optional destructive team membership checks.
    def save_member(payload: Dict[str, Any], ctx: Dict[str, Any]) -> None:
        ctx["created_team_member_id"] = str(response_data(payload).get("memberId", ""))

    plan.run_step(
        "phase-5-collaboration",
        "AddTeamMember",
        "AddTeamMember",
        {"teamId": effective_team_id, "userId": TARGET_MEMBER_USER_ID, "rolesCsv": "member"},
        mandatory=False,
        enabled=team_writes_enabled and bool(effective_team_id),
        on_success=save_member,
    )
    plan.run_step(
        "phase-5-collaboration",
        "RemoveTeamMember",
        "RemoveTeamMember",
        {"teamId": effective_team_id, "memberId": str(plan.ctx.get("created_team_member_id", ""))},
        mandatory=False,
        enabled=bool(effective_team_id) and bool(plan.ctx.get("created_team_member_id")),
    )

    # Message sending usually requires delegated token in non-migration scenarios.
    delegated_mode = bool(ACCESS_TOKEN)
    plan.run_step(
        "phase-5-collaboration",
        "SendChatMessage",
        "SendChatMessage",
        {"chatId": CHAT_ID, "message": "C8O logical test message"},
        mandatory=False,
        enabled=delegated_mode and RUN_MESSAGE_WRITES and bool(CHAT_ID),
    )
    plan.run_step(
        "phase-5-collaboration",
        "SendChannelMessage",
        "SendChannelMessage",
        {
            "teamId": effective_team_id,
            "channelId": effective_channel_id,
            "message": "C8O logical test message",
        },
        mandatory=False,
        enabled=delegated_mode and RUN_MESSAGE_WRITES and bool(effective_team_id) and bool(effective_channel_id),
    )
    plan.run_step(
        "phase-5-collaboration",
        "ShareDriveItemToChatOrChannel",
        "ShareDriveItemToChatOrChannel",
        {
            "targetType": "chat",
            "chatId": CHAT_ID,
            "driveItemWebUrl": "https://contoso.sharepoint.com/:x:/r/sites/demo/Shared%20Documents/file.txt",
            "message": "C8O logical plan shared link",
        },
        mandatory=False,
        enabled=delegated_mode and RUN_MESSAGE_WRITES and bool(CHAT_ID),
    )

    # Phase 6: Files and subscriptions optional paths.
    plan.run_step(
        "phase-6-files-webhooks",
        "UploadMeetingAttachment",
        "UploadMeetingAttachment",
        {
            "userId": ORGANIZER_USER_ID,
            "fileName": "c8o-logical-plan.txt",
            "fileContentBase64": "YzhvIGxvZ2ljYWwgdGVzdA==",
            "parentPath": "/",
            "contentType": "text/plain",
        },
        mandatory=False,
        enabled=plan.capability_ok("drive"),
    )

    def save_subscription(payload: Dict[str, Any], ctx: Dict[str, Any]) -> None:
        # Sequence may expose subscription id either directly or in raw payload.
        data = response_data(payload)
        value = str(data.get("subscriptionId", "")) or str(data.get("id", ""))
        if not value and isinstance(data.get("raw"), dict):
            value = str(data["raw"].get("id", ""))
        ctx["created_subscription_id"] = value

    plan.run_step(
        "phase-6-files-webhooks",
        "SubscribeMeetingChanges",
        "SubscribeMeetingChanges",
        {
            "organizerUserId": ORGANIZER_USER_ID,
            "notificationUrl": WEBHOOK_URL,
            "expirationDateTimeIso": expiration.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "changeType": "created,updated,deleted",
        },
        mandatory=False,
        enabled=bool(WEBHOOK_URL),
        on_success=save_subscription,
    )
    plan.run_step(
        "phase-6-files-webhooks",
        "RenewMeetingSubscription",
        "RenewMeetingSubscription",
        {
            "subscriptionId": str(plan.ctx.get("created_subscription_id", "")),
            "expirationDateTimeIso": expiration.strftime("%Y-%m-%dT%H:%M:%SZ"),
        },
        mandatory=False,
        enabled=bool(plan.ctx.get("created_subscription_id")),
    )
    plan.run_step(
        "phase-6-files-webhooks",
        "UnsubscribeMeetingChanges",
        "UnsubscribeMeetingChanges",
        {"subscriptionId": str(plan.ctx.get("created_subscription_id", ""))},
        mandatory=False,
        enabled=bool(plan.ctx.get("created_subscription_id")),
    )

    summary = plan.summary()
    plan.write_report()
    print()
    print(
        "Summary: total={total} pass={passed} fail={failed} skip={skipped} mandatoryFail={mandatoryFailed}".format(
            **summary
        )
    )
    print(f"Report: {REPORT_FILE}")

    return 1 if plan.mandatory_failed else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"Fatal error: {exc}", file=sys.stderr)
        traceback.print_exc()
        sys.exit(2)
