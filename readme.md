


# Lib_Microsoft_Teams

Mashup Sequencer project

[![Build, Deploy and Tests](https://github.com/convertigo/c8oprj-lib-microsoft-teams/actions/workflows/build-and-release.yml/badge.svg?branch=8.0.0.0)](https://github.com/convertigo/c8oprj-lib-microsoft-teams/actions/workflows/build-and-release.yml)

For more technical informations : [documentation](./project.md)

- [Installation](#installation)
- [Configuration Symbols](#configuration-symbols)
- [Authentication Model](#authentication-model)
- [Test Script (Endpoint-Only)](#test-script-(endpoint-only))
- [Required Azure Permissions](#required-azure-permissions)
- [Known Limitations](#known-limitations)
- [Payload Examples](#payload-examples)
- [Sequences](#sequences)
    - [AddTeamMember](#addteammember)
    - [AttachMeetingCustomMetadata](#attachmeetingcustommetadata)
    - [BuildGraphFlatJar](#buildgraphflatjar)
    - [CancelMeetingEvent](#cancelmeetingevent)
    - [CreateMeetingEvent](#createmeetingevent)
    - [CreateOnlineMeeting](#createonlinemeeting)
    - [CreateTeam](#createteam)
    - [CreateTeamChannel](#createteamchannel)
    - [FindMeetingEvent](#findmeetingevent)
    - [GetMeetingEvent](#getmeetingevent)
    - [GetMeetingRecording](#getmeetingrecording)
    - [GetMeetingTranscripts](#getmeetingtranscripts)
    - [GetOnlineMeetingByJoinUrl](#getonlinemeetingbyjoinurl)
    - [GetUserPresence](#getuserpresence)
    - [ListMeetingEvents](#listmeetingevents)
    - [ListMeetingInstances](#listmeetinginstances)
    - [ListMeetingRecordings](#listmeetingrecordings)
    - [ListTeamChannels](#listteamchannels)
    - [ListUserChats](#listuserchats)
    - [PlanAndCreateMeeting](#planandcreatemeeting)
    - [RemoveTeamMember](#removeteammember)
    - [RenewMeetingSubscription](#renewmeetingsubscription)
    - [RespondToMeetingEvent](#respondtomeetingevent)
    - [SendChannelMessage](#sendchannelmessage)
    - [SendChatMessage](#sendchatmessage)
    - [ShareDriveItemToChatOrChannel](#sharedriveitemtochatorchannel)
    - [SubscribeMeetingChanges](#subscribemeetingchanges)
    - [SuggestMeetingSlots](#suggestmeetingslots)
    - [UnsubscribeMeetingChanges](#unsubscribemeetingchanges)
    - [UpdateMeetingEvent](#updatemeetingevent)
    - [UpdateOnlineMeetingSettings](#updateonlinemeetingsettings)
    - [UploadMeetingAttachment](#uploadmeetingattachment)
    - [ValidateGraphPermissions](#validategraphpermissions)


## Installation

1. In your Convertigo Studio click on ![](https://github.com/convertigo/convertigo/blob/develop/eclipse-plugin-studio/icons/studio/project_import.gif?raw=true "Import a project in treeview") to import a project in the treeview
2. In the import wizard

   ![](https://github.com/convertigo/convertigo/blob/develop/eclipse-plugin-studio/tomcat/webapps/convertigo/templates/ftl/project_import_wzd.png?raw=true "Import Project")
   
   paste the text below into the `Project remote URL` field:
   <table>
     <tr><td>Usage</td><td>Click the copy button at the end of the line</td></tr>
     <tr><td>To contribute</td><td>

     ```
     Lib_Microsoft_Teams=https://github.com/convertigo/c8oprj-lib-microsoft-teams.git:branch=8.0.0.0
     ```
     </td></tr>
     <tr><td>To simply use</td><td>

     ```
     Lib_Microsoft_Teams=https://github.com/convertigo/c8oprj-lib-microsoft-teams/archive/8.0.0.0.zip
     ```
     </td></tr>
    </table>
3. Click the `Finish` button. This will automatically import the __Lib_Microsoft_Teams__ project


## Configuration Symbols

These symbols can be set at project level and reused by all sequences.
In a standard deployment, they are configured once on the server and not passed on each request.

<table>
<tr><th>Symbol</th><th>Required</th><th>Secret</th><th>Purpose</th></tr>
<tr><td><code>${Microsoft_AzGraph.tenantId}</code></td><td>Yes for app-mode (server-side)</td><td>No</td><td>Azure Entra tenant ID.</td></tr>
<tr><td><code>${Microsoft_AzGraph.clientId}</code></td><td>Yes for app-mode (server-side)</td><td>No</td><td>Application (client) ID.</td></tr>
<tr><td><code>${Microsoft_AzGraph.clientSecret.secret}</code></td><td>Yes for app-mode (server-side)</td><td>Yes</td><td>Application client secret.</td></tr>
<tr><td><code>${Lib_Microsoft_Teams.ewsUrl}</code></td><td>Optional (for `provider=ews` or `provider=auto` fallback)</td><td>No</td><td>EWS endpoint URL for Exchange on-premises.</td></tr>
<tr><td><code>${Lib_Microsoft_Teams.ewsUsername}</code></td><td>Optional (for `provider=ews` or `provider=auto` fallback)</td><td>No</td><td>EWS technical username.</td></tr>
<tr><td><code>${Lib_Microsoft_Teams.ewsPassword.secret}</code></td><td>Optional (for `provider=ews` or `provider=auto` fallback)</td><td>Yes</td><td>EWS technical password.</td></tr>
<tr><td><code>${Lib_Microsoft_Teams.ewsImpersonateUserId}</code></td><td>Optional</td><td>No</td><td>EWS impersonation mailbox; defaults to organizer when omitted.</td></tr>
</table>

## Authentication Model

- Default mode (recommended for backend use): rely on server-side symbols (`tenantId`, `clientId`, `clientSecret`) and do not pass credentials in calls.
- Delegated override: pass `accessToken`; tenant/client/secret are ignored.
- Application override: pass tenant/client/secret explicitly in request variables.
- Sequence responses expose `tokenMode` (`delegated` or `application`) for diagnostics.

## Test Script (Endpoint-Only)

The logical test-plan script supports endpoint-only execution for the common case where Graph symbols are already configured on the target Convertigo server.

Minimal usage:
```bash
TEST_SERVER_ENDPOINT=http://localhost:18080 python3 ./scripts/run_testcases.py
```

Behavior:
- The script logs in automatically by default through `ClientSDKtesting/login`.
- It reuses returned `JSESSIONID` and `X-Convertigo-Authenticated` for authenticated sequences.
- No `AZ_TENANT_ID`, `AZ_CLIENT_ID`, or `AZ_CLIENT_SECRET` is required in this mode.

Optional overrides:
- `C8O_LOGIN_PROJECT` and `C8O_LOGIN_SEQUENCE` to target another login sequence.
- `C8O_LOGIN_EXTRA_FORM` when the login sequence expects additional variables (`k1=v1&k2=v2`).
- `ACCESS_TOKEN` or `AZ_*` variables only when you want to bypass server-side symbols for a specific run.

## Required Azure Permissions

Grant Microsoft Graph permissions, then click `Grant admin consent` in Azure.

<table>
<tr><th>Functional scope</th><th>Sequences</th><th>Graph permissions (Application)</th><th>Notes</th></tr>
<tr><td>Meeting CRUD</td><td><code>CreateMeetingEvent</code>, <code>GetMeetingEvent</code>, <code>FindMeetingEvent</code>, <code>UpdateMeetingEvent</code>, <code>CancelMeetingEvent</code>, <code>AttachMeetingCustomMetadata</code>, <code>ListMeetingEvents</code>, <code>ListMeetingInstances</code>, <code>PlanAndCreateMeeting</code></td><td><code>Calendars.ReadWrite</code> (+ optional <code>Calendars.Read</code>)</td><td><code>ListMeetingInstances</code> requires a recurring series master id.</td></tr>
<tr><td>Availability and slot suggestion</td><td><code>SuggestMeetingSlots</code>, <code>PlanAndCreateMeeting</code></td><td><code>Calendars.ReadWrite</code> (or <code>Calendars.Read.Shared</code> for delegated scenarios)</td><td>Uses free/busy APIs under Graph calendar permissions.</td></tr>
<tr><td>Online meetings</td><td><code>CreateOnlineMeeting</code>, <code>GetOnlineMeetingByJoinUrl</code>, <code>UpdateOnlineMeetingSettings</code></td><td><code>OnlineMeetings.ReadWrite.All</code> (+ optional <code>OnlineMeetings.Read.All</code>)</td><td>For app-only access, tenant policy may be required (Application Access Policy).</td></tr>
<tr><td>Recordings and transcripts</td><td><code>ListMeetingRecordings</code>, <code>GetMeetingRecording</code>, <code>GetMeetingTranscripts</code></td><td><code>OnlineMeetingRecording.Read.All</code>, <code>OnlineMeetingTranscript.Read.All</code></td><td>Availability depends on tenant compliance and meeting policy.</td></tr>
<tr><td>Team lifecycle and members</td><td><code>CreateTeam</code>, <code>CreateTeamChannel</code>, <code>ListTeamChannels</code>, <code>AddTeamMember</code>, <code>RemoveTeamMember</code></td><td><code>Team.Create</code>, <code>Group.ReadWrite.All</code>, <code>TeamMember.ReadWrite.All</code>, <code>Channel.Create</code>, <code>Channel.ReadBasic.All</code>, <code>ChannelSettings.Read.All</code></td><td>Some tenant configs also require <code>User.Read.All</code> and/or <code>Directory.Read.All</code>.</td></tr>
<tr><td>Chats and channel messages</td><td><code>ListUserChats</code>, <code>SendChatMessage</code>, <code>SendChannelMessage</code>, <code>ShareDriveItemToChatOrChannel</code></td><td><code>Chat.Read.All</code> (read), message send in app-only is restricted</td><td>Normal message send is usually delegated (<code>ChatMessage.Send</code>, <code>ChannelMessage.Send</code>). App-only send is limited to migration scenarios (<code>Teamwork.Migrate.All</code>).</td></tr>
<tr><td>Presence</td><td><code>GetUserPresence</code>, <code>ValidateGraphPermissions</code> (presence check)</td><td><code>Presence.Read.All</code></td><td>Presence endpoints commonly return 403 when permission is missing.</td></tr>
<tr><td>Drive upload</td><td><code>UploadMeetingAttachment</code>, <code>ShareDriveItemToChatOrChannel</code></td><td><code>Files.ReadWrite.All</code></td><td>Mailbox/user must have OneDrive provisioned and accessible.</td></tr>
<tr><td>Webhooks</td><td><code>SubscribeMeetingChanges</code>, <code>RenewMeetingSubscription</code>, <code>UnsubscribeMeetingChanges</code></td><td><code>Subscriptions.ReadWrite.All</code></td><td><code>notificationUrl</code> must be publicly reachable and answer Graph validation challenge.</td></tr>
<tr><td>Diagnostic probe</td><td><code>ValidateGraphPermissions</code></td><td>Depends on enabled checks: <code>Calendars.Read</code>, <code>OnlineMeetings.Read.All</code>, <code>Team.ReadBasic.All</code>, <code>Files.Read</code>, <code>Presence.Read.All</code>, <code>Chat.Read.All</code></td><td>Use it to quickly identify missing grants per scope.</td></tr>
</table>

Recommended baseline for app-only scenarios:
- <code>Calendars.ReadWrite</code>
- <code>OnlineMeetings.ReadWrite.All</code>
- <code>OnlineMeetingRecording.Read.All</code>
- <code>OnlineMeetingTranscript.Read.All</code>
- <code>Team.Create</code>
- <code>Group.ReadWrite.All</code>
- <code>TeamMember.ReadWrite.All</code>
- <code>Channel.Create</code>
- <code>Channel.ReadBasic.All</code>
- <code>ChannelSettings.Read.All</code>
- <code>Chat.Read.All</code>
- <code>Presence.Read.All</code>
- <code>Files.ReadWrite.All</code>
- <code>Subscriptions.ReadWrite.All</code>
- <code>User.Read.All</code>
- <code>Directory.Read.All</code>

## Known Limitations

- Some events/mailboxes do not support listing event extensions (`/events/{id}/extensions`) and Graph returns: `The OData request is not supported.`
- In `GetMeetingEvent`, keep `includeExtensions=true` with `failIfExtensionsUnsupported=false` to return event data and get:
  - `extensionsUnsupported=true`
  - `extensionsUnsupportedError` with the Graph message
- Set `failIfExtensionsUnsupported=true` only when extension listing is mandatory.

## Payload Examples

`attendeesJson` example:
```json
[
  { "email": "alice@contoso.com", "name": "Alice", "type": "required" },
  { "email": "bob@contoso.com", "name": "Bob", "type": "optional" }
]
```

`customMetadataJson` example:
```json
{
  "businessId": "REQ-2026-00042",
  "sourceApp": "MyPortal",
  "labels": ["customer", "priority-high"]
}
```
## Sequences

### AddTeamMember

Adds a user as member or owner to a Microsoft Teams team. (Graph permissions TeamMember.ReadWrite.All|Group.ReadWrite.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>rolesCsv</td><td>Optional comma-separated member roles, use owner for team owners.</td>
</tr>
<tr>
<td>teamId</td><td>Target Teams team identifier.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>userId</td><td>User id or UPN to add as team member.</td>
</tr>
</table>

### AttachMeetingCustomMetadata

Attaches custom business metadata to a meeting event via Graph extensions. (Graph permissions Calendars.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>eventId</td><td>Target Outlook event id receiving metadata.</td>
</tr>
<tr>
<td>extensionId</td><td>Open extension identifier to create or update.</td>
</tr>
<tr>
<td>mergeMode</td><td>merge keeps existing keys, replace overwrites extension payload.</td>
</tr>
<tr>
<td>metadataJson</td><td>JSON object persisted in extension additionalData.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) owning the event.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### BuildGraphFlatJar

Builds a flat JAR for Microsoft Graph Java SDK and stores it under .//libs

### CancelMeetingEvent

Cancels an existing Outlook/Teams meeting event. (Graph permissions Calendars.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>cancelComment</td><td>Cancellation comment sent to attendees when sendCancellation is true.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>eventId</td><td>Target Outlook event id to cancel.</td>
</tr>
<tr>
<td>ewsImpersonateUserId</td><td>Optional mailbox used for EWS impersonation, defaults to organizerUserId.</td>
</tr>
<tr>
<td>ewsPassword</td><td>EWS technical password used for Exchange on-prem authentication.</td>
</tr>
<tr>
<td>ewsUrl</td><td>EWS endpoint URL used when provider is ews or auto fallback.</td>
</tr>
<tr>
<td>ewsUsername</td><td>EWS technical username used for Exchange on-prem authentication.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) used to cancel the event.</td>
</tr>
<tr>
<td>provider</td><td>Backend provider selection graph|ews|auto.</td>
</tr>
<tr>
<td>sendCancellation</td><td>true sends official cancellation, false deletes event without cancellation message.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### CreateMeetingEvent

Creates an Outlook calendar event with Teams online meeting link. (Graph permissions Calendars.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>attendeesJson</td><td>JSON array of attendees [{email,name,type}] where type is required|optional|resource.</td>
</tr>
<tr>
<td>bodyHtml</td><td>Optional HTML body/description for the meeting invitation.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>customMetadataJson</td><td>Optional custom metadata JSON persisted as open extension.</td>
</tr>
<tr>
<td>endIso</td><td>Meeting end in ISO-8601 format (for example 2026-03-03T11:00:00).</td>
</tr>
<tr>
<td>ewsImpersonateUserId</td><td>Optional mailbox used for EWS impersonation, defaults to organizerUserId.</td>
</tr>
<tr>
<td>ewsPassword</td><td>EWS technical password used for Exchange on-prem authentication.</td>
</tr>
<tr>
<td>ewsUrl</td><td>EWS endpoint URL used when provider is ews or auto fallback.</td>
</tr>
<tr>
<td>ewsUsername</td><td>EWS technical username used for Exchange on-prem authentication.</td>
</tr>
<tr>
<td>idempotencyKey</td><td>Optional transaction id used for idempotent event creation.</td>
</tr>
<tr>
<td>isOnlineMeeting</td><td>true to generate a Teams online meeting link on the event.</td>
</tr>
<tr>
<td>metadataExtensionId</td><td>Open extension identifier used when customMetadataJson is provided.</td>
</tr>
<tr>
<td>onlineMeetingProvider</td><td>Online meeting provider value (teamsForBusiness by default).</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) used to create the event.</td>
</tr>
<tr>
<td>provider</td><td>Backend provider selection graph|ews|auto.</td>
</tr>
<tr>
<td>startIso</td><td>Meeting start in ISO-8601 format (for example 2026-03-03T10:00:00).</td>
</tr>
<tr>
<td>subject</td><td>Meeting subject shown in calendar and invitation.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>timeZone</td><td>Time zone used for start and end values.</td>
</tr>
</table>

### CreateOnlineMeeting

Creates a Microsoft Teams online meeting for a user mailbox. (Graph permissions OnlineMeetings.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>endDateTimeIso</td><td>Meeting end datetime in ISO-8601 format with timezone or offset.</td>
</tr>
<tr>
<td>externalId</td><td>Optional external business identifier for idempotent correlation.</td>
</tr>
<tr>
<td>participantsJson</td><td>Optional JSON array of attendees [{upn|email,role}].</td>
</tr>
<tr>
<td>startDateTimeIso</td><td>Meeting start datetime in ISO-8601 format with timezone or offset.</td>
</tr>
<tr>
<td>subject</td><td>Online meeting subject displayed in Teams.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>userId</td><td>Target organizer mailbox (user id or UPN) that owns the online meeting.</td>
</tr>
</table>

### CreateTeam

Creates a Microsoft Teams team from the standard template. (Graph permissions Team.Create|Group.ReadWrite.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>description</td><td>Optional team description.</td>
</tr>
<tr>
<td>displayName</td><td>Team display name.</td>
</tr>
<tr>
<td>ownerUserIdsJson</td><td>Optional JSON array of owner user ids or UPNs.</td>
</tr>
<tr>
<td>templateName</td><td>Teams template name (standard by default).</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>visibility</td><td>Team visibility value Private or Public.</td>
</tr>
</table>

### CreateTeamChannel

Creates a channel in an existing Microsoft Teams team. (Graph permissions Channel.Create|Channel.ReadWrite.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>description</td><td>Optional channel description.</td>
</tr>
<tr>
<td>displayName</td><td>Channel display name.</td>
</tr>
<tr>
<td>membershipType</td><td>Channel membership type standard, private or shared.</td>
</tr>
<tr>
<td>teamId</td><td>Target Teams team identifier.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### FindMeetingEvent

Finds meeting events by event id, iCalUId, transactionId and optional metadata extension values. (Graph permissions Calendars.Read|Calendars.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>eventId</td><td>Optional direct event id lookup value.</td>
</tr>
<tr>
<td>iCalUId</td><td>Optional iCalUId lookup value.</td>
</tr>
<tr>
<td>includeAttendees</td><td>true includes attendee arrays in matched events.</td>
</tr>
<tr>
<td>includeBody</td><td>true includes body payload in matched events.</td>
</tr>
<tr>
<td>includeMetadataExtension</td><td>true fetches metadata extension object for each matched event.</td>
</tr>
<tr>
<td>maxResults</td><td>Maximum number of matching events returned.</td>
</tr>
<tr>
<td>metadataExtensionId</td><td>Open extension identifier used for metadata lookup.</td>
</tr>
<tr>
<td>metadataKey</td><td>Optional metadata key to match in extension additionalData.</td>
</tr>
<tr>
<td>metadataValue</td><td>Optional metadata value to match in extension additionalData.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) owning searched events.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>transactionId</td><td>Optional transaction id lookup value.</td>
</tr>
<tr>
<td>windowEndIso</td><td>Optional end datetime for list-based lookup (ISO-8601), required with windowStartIso.</td>
</tr>
<tr>
<td>windowStartIso</td><td>Optional start datetime for list-based lookup (ISO-8601), required with windowEndIso.</td>
</tr>
</table>

### GetMeetingEvent

Retrieves a Teams/Outlook meeting event with attendees, slot details and optional custom metadata extension. (Graph permissions Calendars.Read|Calendars.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>eventId</td><td>Target Outlook event id to read.</td>
</tr>
<tr>
<td>ewsImpersonateUserId</td><td>Optional mailbox used for EWS impersonation, defaults to organizerUserId.</td>
</tr>
<tr>
<td>ewsPassword</td><td>EWS technical password used for Exchange on-prem authentication.</td>
</tr>
<tr>
<td>ewsUrl</td><td>EWS endpoint URL used when provider is ews or auto fallback.</td>
</tr>
<tr>
<td>ewsUsername</td><td>EWS technical username used for Exchange on-prem authentication.</td>
</tr>
<tr>
<td>failIfExtensionsUnsupported</td><td>true returns error when listing extensions is not supported for the targeted event.</td>
</tr>
<tr>
<td>failIfMetadataMissing</td><td>true returns error if metadataExtensionId is provided but not found.</td>
</tr>
<tr>
<td>includeAttendees</td><td>true includes attendee list in response payload.</td>
</tr>
<tr>
<td>includeBody</td><td>true includes event body (HTML/text) in response payload.</td>
</tr>
<tr>
<td>includeExtensions</td><td>true loads all open extensions available on the event.</td>
</tr>
<tr>
<td>metadataExtensionId</td><td>Optional extension id to fetch directly in metadataExtension field.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) owning the event.</td>
</tr>
<tr>
<td>provider</td><td>Backend provider selection graph|ews|auto.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### GetMeetingRecording

Retrieves one Teams meeting recording metadata entry. (Graph permissions OnlineMeetingRecording.Read.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>onlineMeetingId</td><td>Target online meeting identifier.</td>
</tr>
<tr>
<td>recordingId</td><td>Target meeting recording identifier.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>userId</td><td>User id or UPN owning the online meeting.</td>
</tr>
</table>

### GetMeetingTranscripts

Lists transcripts for a Teams online meeting. (Graph permissions OnlineMeetingTranscript.Read.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>onlineMeetingId</td><td>Target online meeting identifier.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>top</td><td>Maximum number of transcripts returned.</td>
</tr>
<tr>
<td>userId</td><td>User id or UPN owning the online meeting.</td>
</tr>
</table>

### GetOnlineMeetingByJoinUrl

Retrieves an online meeting by its Teams joinWebUrl. (Graph permissions OnlineMeetings.Read|OnlineMeetings.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>joinWebUrl</td><td>Teams meeting join URL used for lookup.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>userId</td><td>Target organizer mailbox (user id or UPN) that owns the online meeting.</td>
</tr>
</table>

### GetUserPresence

Retrieves real-time Teams presence for a user. (Graph permissions Presence.Read.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>userId</td><td>Target user id or UPN for presence lookup.</td>
</tr>
</table>

### ListMeetingEvents

Lists Outlook meeting events for an organizer mailbox, optionally scoped by a calendar window. (Graph permissions Calendars.Read|Calendars.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>ewsImpersonateUserId</td><td>Optional mailbox used for EWS impersonation, defaults to organizerUserId.</td>
</tr>
<tr>
<td>ewsPassword</td><td>EWS technical password used for Exchange on-prem authentication.</td>
</tr>
<tr>
<td>ewsUrl</td><td>EWS endpoint URL used when provider is ews or auto fallback.</td>
</tr>
<tr>
<td>ewsUsername</td><td>EWS technical username used for Exchange on-prem authentication.</td>
</tr>
<tr>
<td>filter</td><td>Optional OData filter expression appended to the list query.</td>
</tr>
<tr>
<td>includeAttendees</td><td>true includes attendee arrays in each returned event.</td>
</tr>
<tr>
<td>includeBody</td><td>true includes event body in each returned event.</td>
</tr>
<tr>
<td>includeCancelled</td><td>true keeps cancelled events in the response.</td>
</tr>
<tr>
<td>orderBy</td><td>Optional OData order by expression.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) used to list events.</td>
</tr>
<tr>
<td>provider</td><td>Backend provider selection graph|ews|auto.</td>
</tr>
<tr>
<td>skip</td><td>Optional page offset for events listing.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>top</td><td>Maximum number of events returned in one page.</td>
</tr>
<tr>
<td>windowEndIso</td><td>Optional end datetime for calendarView listing (ISO-8601), requires windowStartIso.</td>
</tr>
<tr>
<td>windowStartIso</td><td>Optional start datetime for calendarView listing (ISO-8601), requires windowEndIso.</td>
</tr>
</table>

### ListMeetingInstances

Lists recurring meeting instances for a series master event in a specific time window. (Graph permissions Calendars.Read|Calendars.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>eventId</td><td>Series master event id used to list recurring instances.</td>
</tr>
<tr>
<td>includeAttendees</td><td>true includes attendee arrays in each instance.</td>
</tr>
<tr>
<td>includeBody</td><td>true includes body payload in each instance.</td>
</tr>
<tr>
<td>includeCancelled</td><td>true keeps cancelled instances in the response.</td>
</tr>
<tr>
<td>orderBy</td><td>Optional OData order by expression for instances listing.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) owning the recurring event.</td>
</tr>
<tr>
<td>skip</td><td>Optional page offset for instances listing.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>top</td><td>Maximum number of instances returned in one page.</td>
</tr>
<tr>
<td>windowEndIso</td><td>End datetime of the instances lookup window (ISO-8601).</td>
</tr>
<tr>
<td>windowStartIso</td><td>Start datetime of the instances lookup window (ISO-8601).</td>
</tr>
</table>

### ListMeetingRecordings

Lists recordings for a Teams online meeting. (Graph permissions OnlineMeetingRecording.Read.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>onlineMeetingId</td><td>Target online meeting identifier.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>top</td><td>Maximum number of recordings returned.</td>
</tr>
<tr>
<td>userId</td><td>User id or UPN owning the online meeting.</td>
</tr>
</table>

### ListTeamChannels

Lists channels for a Microsoft Teams team. (Graph permissions Channel.ReadBasic.All|Channel.Read.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>teamId</td><td>Target Teams team identifier.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>top</td><td>Maximum number of channels returned.</td>
</tr>
</table>

### ListUserChats

Lists Teams chats for a target user mailbox. (Graph permissions Chat.Read|Chat.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>top</td><td>Maximum number of chats returned per request.</td>
</tr>
<tr>
<td>userId</td><td>Target user mailbox (user id or UPN) whose chats must be listed.</td>
</tr>
</table>

### PlanAndCreateMeeting

Plans an available slot and creates an Outlook/Teams meeting event in one backend call. (Graph permissions Calendars.ReadWrite|freeBusy)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>attendeesJson</td><td>JSON array of attendees [{email,name,type}] where type is required|optional|resource.</td>
</tr>
<tr>
<td>bodyHtml</td><td>Optional HTML body/description for the meeting invitation.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
</tr>
<tr>
<td>customMetadataJson</td><td>Optional custom metadata JSON persisted as open extension.</td>
</tr>
<tr>
<td>idempotencyKey</td><td>Optional transaction id used for idempotent event creation.</td>
</tr>
<tr>
<td>isOnlineMeeting</td><td>true to generate a Teams online meeting link on the event.</td>
</tr>
<tr>
<td>maxCandidates</td><td>Maximum returned suggestions for findMeetingTimes strategy.</td>
</tr>
<tr>
<td>meetingDurationMinutes</td><td>Requested meeting duration in minutes (minimum 5).</td>
</tr>
<tr>
<td>metadataExtensionId</td><td>Open extension identifier used when customMetadataJson is provided.</td>
</tr>
<tr>
<td>minimumAttendeePercentage</td><td>Minimum attendee fit percentage expected for findMeetingTimes.</td>
</tr>
<tr>
<td>onlineMeetingProvider</td><td>Online meeting provider value (teamsForBusiness by default).</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) used to create the event.</td>
</tr>
<tr>
<td>preferredEndIso</td><td>Optional preferred end datetime (ISO-8601). Required with preferredStartIso.</td>
</tr>
<tr>
<td>preferredStartIso</td><td>Optional preferred start datetime (ISO-8601). If set, planning lookup is skipped.</td>
</tr>
<tr>
<td>searchWindowEndIso</td><td>Search window end datetime used when preferred slot is not provided.</td>
</tr>
<tr>
<td>searchWindowStartIso</td><td>Search window start datetime used when preferred slot is not provided.</td>
</tr>
<tr>
<td>selectCandidateIndex</td><td>Preferred candidate index to select when findMeetingTimes returns suggestions.</td>
</tr>
<tr>
<td>slotStepMinutes</td><td>Slot scanning step in minutes when strategy uses getSchedule.</td>
</tr>
<tr>
<td>strategy</td><td>Slot planning strategy auto|findMeetingTimes|getSchedule.</td>
</tr>
<tr>
<td>strictSlotSelection</td><td>true fails when no free slot is found, false falls back to search window start.</td>
</tr>
<tr>
<td>subject</td><td>Meeting subject shown in calendar and invitation.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>timeZone</td><td>Time zone used for planning window and created meeting slot values.</td>
</tr>
</table>

### RemoveTeamMember

Removes a member from a Microsoft Teams team. (Graph permissions TeamMember.ReadWrite.All|Group.ReadWrite.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>memberId</td><td>Team member identifier to remove.</td>
</tr>
<tr>
<td>teamId</td><td>Target Teams team identifier.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### RenewMeetingSubscription

Renews an existing Microsoft Graph meeting subscription expiration datetime. (Graph permissions Subscriptions.ReadWrite.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>expirationDateTimeIso</td><td>New subscription expiration datetime in ISO-8601 offset format.</td>
</tr>
<tr>
<td>subscriptionId</td><td>Existing Graph subscription id to renew.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### RespondToMeetingEvent

Sends attendee response (accept, decline, tentative) for a meeting event. (Graph permissions Calendars.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>comment</td><td>Optional attendee comment sent with meeting response.</td>
</tr>
<tr>
<td>eventId</td><td>Target meeting event id for the attendee response.</td>
</tr>
<tr>
<td>responseAction</td><td>Response action value accept, decline or tentativelyAccept.</td>
</tr>
<tr>
<td>sendResponse</td><td>true sends response message to organizer, false updates status silently.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>userId</td><td>Target attendee mailbox (user id or UPN) sending the meeting response.</td>
</tr>
</table>

### SendChannelMessage

Sends a Teams message to a team channel. (Graph permissions ChannelMessage.Send|ChannelMessage.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>channelId</td><td>Target Teams channel identifier.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>contentType</td><td>Message content type, usually html or text.</td>
</tr>
<tr>
<td>importance</td><td>Optional message importance value normal, high or urgent.</td>
</tr>
<tr>
<td>message</td><td>Message content to send to the channel.</td>
</tr>
<tr>
<td>subject</td><td>Optional message subject.</td>
</tr>
<tr>
<td>teamId</td><td>Target Teams team identifier.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### SendChatMessage

Sends a Teams message to a chat thread. (Graph permissions ChatMessage.Send|Chat.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>chatId</td><td>Target Teams chat identifier.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>contentType</td><td>Message content type, usually html or text.</td>
</tr>
<tr>
<td>importance</td><td>Optional message importance value normal, high or urgent.</td>
</tr>
<tr>
<td>message</td><td>Message content to send to the chat.</td>
</tr>
<tr>
<td>subject</td><td>Optional message subject.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### ShareDriveItemToChatOrChannel

Shares a Drive item link by posting it into a Teams chat or channel. (Graph permissions ChatMessage.Send|ChannelMessage.Send)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>channelId</td><td>Target channel id when targetType is channel.</td>
</tr>
<tr>
<td>chatId</td><td>Target chat id when targetType is chat.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>driveItemWebUrl</td><td>Shareable Drive item web URL.</td>
</tr>
<tr>
<td>message</td><td>Optional message prefix posted before the link.</td>
</tr>
<tr>
<td>targetType</td><td>Share target type chat or channel.</td>
</tr>
<tr>
<td>teamId</td><td>Target team id when targetType is channel.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### SubscribeMeetingChanges

Creates a Microsoft Graph webhook subscription for meeting events. (Graph permissions Subscriptions.ReadWrite.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>changeType</td><td>Change types to subscribe (created,updated,deleted).</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>clientState</td><td>Optional client state echoed back in notifications.</td>
</tr>
<tr>
<td>encryptionCertificate</td><td>Base64 certificate used when includeResourceData=true.</td>
</tr>
<tr>
<td>encryptionCertificateId</td><td>Certificate identifier used when includeResourceData=true.</td>
</tr>
<tr>
<td>expirationDateTimeIso</td><td>Subscription expiration datetime in ISO-8601 offset format.</td>
</tr>
<tr>
<td>includeResourceData</td><td>true requests encrypted resource payloads in notifications.</td>
</tr>
<tr>
<td>lifecycleNotificationUrl</td><td>Optional lifecycle callback URL for reauthorization and missed notifications.</td>
</tr>
<tr>
<td>notificationUrl</td><td>HTTPS callback URL receiving Graph change notifications.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Organizer mailbox used to build the default events resource path.</td>
</tr>
<tr>
<td>resource</td><td>Optional Graph resource path. Default is users/{organizer}/events.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### SuggestMeetingSlots

Suggests available meeting slots using Microsoft Graph findMeetingTimes/getSchedule. (Graph permissions Calendars.Read.Shared|Calendars.ReadWrite|freeBusy)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>attendeesJson</td><td>JSON array of attendees [{email,name,type}] used for suggestion or schedule lookup.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>maxCandidates</td><td>Maximum returned suggestions for findMeetingTimes strategy.</td>
</tr>
<tr>
<td>meetingDurationMinutes</td><td>Requested meeting duration in minutes (minimum 5).</td>
</tr>
<tr>
<td>minimumAttendeePercentage</td><td>Minimum attendee fit percentage expected for suggestions.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Organizer mailbox (user id or UPN) used as reference calendar.</td>
</tr>
<tr>
<td>strategy</td><td>Strategy value findMeetingTimes or getSchedule (auto fallback to getSchedule for app token).</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>timeZone</td><td>Time zone used by search window datetimes.</td>
</tr>
<tr>
<td>windowEndIso</td><td>Search window end datetime in ISO-8601 format.</td>
</tr>
<tr>
<td>windowStartIso</td><td>Search window start datetime in ISO-8601 format.</td>
</tr>
</table>

### UnsubscribeMeetingChanges

Deletes an existing Microsoft Graph meeting subscription. (Graph permissions Subscriptions.ReadWrite.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>subscriptionId</td><td>Existing Graph subscription id to delete.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### UpdateMeetingEvent

Updates an existing Outlook/Teams meeting event. (Graph permissions Calendars.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>attendeesJson</td><td>Optional JSON array of attendees [{email,name,type}] to replace current attendees.</td>
</tr>
<tr>
<td>bodyHtml</td><td>Optional updated HTML body/description.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>customMetadataJson</td><td>Optional custom metadata JSON persisted as open extension.</td>
</tr>
<tr>
<td>endIso</td><td>Optional updated end datetime in ISO-8601 format.</td>
</tr>
<tr>
<td>eventId</td><td>Target Outlook event id to update.</td>
</tr>
<tr>
<td>ewsImpersonateUserId</td><td>Optional mailbox used for EWS impersonation, defaults to organizerUserId.</td>
</tr>
<tr>
<td>ewsPassword</td><td>EWS technical password used for Exchange on-prem authentication.</td>
</tr>
<tr>
<td>ewsUrl</td><td>EWS endpoint URL used when provider is ews or auto fallback.</td>
</tr>
<tr>
<td>ewsUsername</td><td>EWS technical username used for Exchange on-prem authentication.</td>
</tr>
<tr>
<td>mergeMode</td><td>Metadata merge mode when extension exists (merge or replace).</td>
</tr>
<tr>
<td>metadataExtensionId</td><td>Open extension identifier used when customMetadataJson is provided.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) used to patch the event.</td>
</tr>
<tr>
<td>provider</td><td>Backend provider selection graph|ews|auto.</td>
</tr>
<tr>
<td>sendUpdates</td><td>Update mode none|externalOnly|all, transmitted to Graph when payloadUpdated is true.</td>
</tr>
<tr>
<td>startIso</td><td>Optional updated start datetime in ISO-8601 format.</td>
</tr>
<tr>
<td>subject</td><td>Optional updated meeting subject.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>timeZone</td><td>Time zone used for updated start and end values.</td>
</tr>
</table>

### UpdateOnlineMeetingSettings

Updates online meeting settings using a JSON patch payload. (Graph permissions OnlineMeetings.ReadWrite)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>onlineMeetingId</td><td>Target online meeting identifier.</td>
</tr>
<tr>
<td>settingsJson</td><td>JSON object containing mutable online meeting properties to patch.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>userId</td><td>Target organizer mailbox (user id or UPN) that owns the online meeting.</td>
</tr>
</table>

### UploadMeetingAttachment

Uploads a binary attachment into the user OneDrive for later sharing in Teams. (Graph permissions Files.ReadWrite.All)

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>contentType</td><td>MIME type sent to Graph for the uploaded content.</td>
</tr>
<tr>
<td>fileContentBase64</td><td>Base64-encoded file bytes for upload.</td>
</tr>
<tr>
<td>fileName</td><td>File name to create or replace in OneDrive.</td>
</tr>
<tr>
<td>parentPath</td><td>OneDrive folder path under root where file is uploaded.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>userId</td><td>Target user id or UPN owning the OneDrive destination.</td>
</tr>
</table>

### ValidateGraphPermissions

Validates Graph permissions by probing key Teams/Outlook endpoints. (Graph permissions Mixed (see checks array))

**variables**

<table>
<tr>
<th>name</th><th>comment</th>
</tr>
<tr>
<td>accessToken</td><td>Optional delegated bearer token. If provided, tenant/client/secret are ignored.</td>
</tr>
<tr>
<td>checksJson</td><td>Optional JSON array of checks names presence,chats,calendar,onlineMeetings,joinedTeams,drive.</td>
</tr>
<tr>
<td>clientId</td><td>Azure Entra application client id used for app-only token acquisition.</td>
</tr>
<tr>
<td>clientSecret</td><td></td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
<tr>
<td>userId</td><td>User id or UPN used as target for permission probes.</td>
</tr>
</table>


