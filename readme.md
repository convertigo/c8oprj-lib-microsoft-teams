


# Lib_Microsoft_Teams

Mashup Sequencer project


For more technical informations : [documentation](./project.md)

- [Installation](#installation)
- [Configuration Symbols](#configuration-symbols)
- [Authentication Model](#authentication-model)
- [Required Azure Permissions](#required-azure-permissions)
- [Known Limitations](#known-limitations)
- [Payload Examples](#payload-examples)
- [Sequences](#sequences)
    - [AttachMeetingCustomMetadata](#attachmeetingcustommetadata)
    - [BuildGraphFlatJar](#buildgraphflatjar)
    - [CancelMeetingEvent](#cancelmeetingevent)
    - [CreateMeetingEvent](#createmeetingevent)
    - [FindMeetingEvent](#findmeetingevent)
    - [GetMeetingEvent](#getmeetingevent)
    - [ListMeetingEvents](#listmeetingevents)
    - [ListMeetingInstances](#listmeetinginstances)
    - [PlanAndCreateMeeting](#planandcreatemeeting)
    - [RenewMeetingSubscription](#renewmeetingsubscription)
    - [RespondToMeetingEvent](#respondtomeetingevent)
    - [SubscribeMeetingChanges](#subscribemeetingchanges)
    - [SuggestMeetingSlots](#suggestmeetingslots)
    - [UnsubscribeMeetingChanges](#unsubscribemeetingchanges)
    - [UpdateMeetingEvent](#updatemeetingevent)


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

<table>
<tr><th>Symbol</th><th>Required</th><th>Secret</th><th>Purpose</th></tr>
<tr><td><code>${Lib_Microsoft_Teams.tenantId}</code></td><td>Yes (app-only)</td><td>No</td><td>Azure Entra tenant ID.</td></tr>
<tr><td><code>${Lib_Microsoft_Teams.clientId}</code></td><td>Yes (app-only)</td><td>No</td><td>Application (client) ID.</td></tr>
<tr><td><code>${Lib_Microsoft_Teams.clientSecret.secret}</code></td><td>Yes (app-only)</td><td>Yes</td><td>Application client secret.</td></tr>
</table>

## Authentication Model

- Delegated mode: pass `accessToken`; tenant/client/secret are ignored.
- Application mode: leave `accessToken` empty and provide tenant/client/secret.
- Sequence responses expose `tokenMode` (`delegated` or `application`) for diagnostics.

## Required Azure Permissions

Grant application permissions (or delegated equivalents) to Microsoft Graph:

<table>
<tr><th>Functional scope</th><th>Recommended permissions</th></tr>
<tr><td>Create/update/cancel meeting events</td><td><code>Calendars.ReadWrite</code></td></tr>
<tr><td>Read meeting events</td><td><code>Calendars.Read</code> or <code>Calendars.ReadWrite</code></td></tr>
<tr><td>Find availability / suggested slots</td><td><code>Calendars.Read.Shared</code> and/or <code>Calendars.ReadWrite</code> (free/busy usage)</td></tr>
</table>

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

### AttachMeetingCustomMetadata

Attaches custom business metadata to a meeting event via Graph extensions.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
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

Cancels an existing Outlook/Teams meeting event.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
</tr>
<tr>
<td>eventId</td><td>Target Outlook event id to cancel.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) used to cancel the event.</td>
</tr>
<tr>
<td>sendCancellation</td><td>true sends official cancellation, false deletes event without cancellation message.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### CreateMeetingEvent

Creates an Outlook calendar event with Teams online meeting link.

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
<td>endIso</td><td>Meeting end in ISO-8601 format (for example 2026-03-03T11:00:00).</td>
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

### FindMeetingEvent

Finds meeting events by event id, iCalUId, transactionId and optional metadata extension values.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
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

Retrieves a Teams/Outlook meeting event with attendees, slot details and optional custom metadata extension.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
</tr>
<tr>
<td>eventId</td><td>Target Outlook event id to read.</td>
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
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### ListMeetingEvents

Lists Outlook meeting events for an organizer mailbox, optionally scoped by a calendar window.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
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

Lists recurring meeting instances for a series master event in a specific time window.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
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

### PlanAndCreateMeeting

Plans an available slot and creates an Outlook/Teams meeting event in one backend call.

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

### RenewMeetingSubscription

Renews an existing Microsoft Graph meeting subscription expiration datetime.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
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

Sends attendee response (accept, decline, tentative) for a meeting event.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
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

### SubscribeMeetingChanges

Creates a Microsoft Graph webhook subscription for meeting events.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
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

Suggests available meeting slots using Microsoft Graph findMeetingTimes/getSchedule.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
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

Deletes an existing Microsoft Graph meeting subscription.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
</tr>
<tr>
<td>subscriptionId</td><td>Existing Graph subscription id to delete.</td>
</tr>
<tr>
<td>tenantId</td><td>Azure Entra tenant id used for app-only token acquisition.</td>
</tr>
</table>

### UpdateMeetingEvent

Updates an existing Outlook/Teams meeting event.

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
<td>clientSecret</td><td>Azure Entra application client secret used for app-only token acquisition.</td>
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
<td>mergeMode</td><td>Metadata merge mode when extension exists (merge or replace).</td>
</tr>
<tr>
<td>metadataExtensionId</td><td>Open extension identifier used when customMetadataJson is provided.</td>
</tr>
<tr>
<td>organizerUserId</td><td>Target organizer mailbox (user id or UPN) used to patch the event.</td>
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


