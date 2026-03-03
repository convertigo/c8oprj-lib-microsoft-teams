


# Lib_Microsoft_Teams

Mashup Sequencer project


For more technical informations : [documentation](./project.md)

- [Installation](#installation)
- [Sequences](#sequences)
    - [AttachMeetingCustomMetadata](#attachmeetingcustommetadata)
    - [BuildGraphFlatJar](#buildgraphflatjar)
    - [CancelMeetingEvent](#cancelmeetingevent)
    - [CreateMeetingEvent](#createmeetingevent)
    - [GetMeetingEvent](#getmeetingevent)
    - [PlanAndCreateMeeting](#planandcreatemeeting)
    - [SuggestMeetingSlots](#suggestmeetingslots)
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
     Lib_Microsoft_Teams=/Users/charlesg/dev/convertigo/studios/Studio_8.4_stable/Lib_Microsoft_Teams/.git:branch=master
     ```
     </td></tr>
     <tr><td>To simply use</td><td>

     ```
     Lib_Microsoft_Teams=/Users/charlesg/dev/convertigo/studios/Studio_8.4_stable/Lib_Microsoft_Teams//archive/master.zip
     ```
     </td></tr>
    </table>
3. Click the `Finish` button. This will automatically import the __Lib_Microsoft_Teams__ project


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



