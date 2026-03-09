<#-- This FTL template helps generating the readme.md file of your project -->
<#-- see FTL language documentation : https://freemarker.apache.org/docs/index.html -->

<#-- GLOBALS -->
<#global lineBreak = settings.lineBreak />
<#global locale = "US" />
<#global dictionnary = {
		"installation":	{"US": "Installation"			, "FR": "Installation"},
		"more.info": 	{"US": "For more technical informations"	, "FR": "Pour plus d'informations techniques"},
		"connectors": 	{"US": "Connectors"				, "FR": "Connecteurs"},
		"transactions": {"US": "Transactions"			, "FR": "Transactions"},
		"sequences": 	{"US": "Sequences"				, "FR": "Séquences"},
		"references": 	{"US": "References"				, "FR": "Références"},
		"urlmapper": 	{"US": "Rest Web Service"		, "FR": "Service Web REST"},
		"mappings": 	{"US": "Mappings"				, "FR": "Mappages"},
		"operations": 	{"US": "Operations"				, "FR": "Operations"},
		"parameters": 	{"US": "Parameters"				, "FR": "Paramètres"},
		"mobileapp": 	{"US": "Mobile Application"		, "FR": "Application Mobile"},
		"mobilelib": 	{"US": "Mobile Library"			, "FR": "Librairie Mobile"},
		"pages": 		{"US": "Pages"					, "FR": "Pages"},
		"actions": 		{"US": "Shared Actions"			, "FR": "Actions partagées"},
		"components": 	{"US": "Shared Components"		, "FR": "Composants partagés"},
		"variables": 	{"US": "variables"				, "FR": "variables"},
		"events": 		{"US": "events"					, "FR": "évènements"}
	}
/>
<#-- please modify the global show values as needed -->
<#global show = {
	"toc"			: true,
	"installation"	: true,
	
	"connectors"	: false,
	"transactions"	: true,
	"sequences"		: !has(project, "urlmapper") && !has(project, "mobileapp"),
	
	"references"	: false,
	
	"urlmapper"		: true,
	"mappings"		: true,
	"operations"	: true,
	"parameters"	: true,
	
	"mobileapp"		: true,
	"pages"			: !project.name?starts_with("lib_"),
	"actions"		: true,
	"components"	: true,
	
	"variables"		: true,
	"events"		: true
	} 
/>

<#-- FUNCTIONS -->
<#-- on: returns the show flag for the given key -->
<#function on key>
  <#return show[key]?? && show[key]>
</#function>

<#-- on: test if given dbo has the given key with non empty size -->
<#function has dbo key>
  <#return dbo[key]?? && (dbo[key]?size > 0) >
</#function>

<#-- anchor: generates an anchor link for the given text -->
<#function anchor anchors text>
  <#assign a = ""+ text?lower_case?replace(" ", "-")?replace("/", "")>
  <#if anchors?seq_contains(a)>
  	<#assign f = anchors?filter(s -> s?matches(""+ a + "-(\\d+)"))>
  	<#assign a = ""+ a + "-" + (f?size+1)>
  </#if>
  <#assign anchors += [""+a]>
  <#return a>
</#function>

<#-- on: returns the dictionnary value for the given key -->
<#function help key>
  <#if has(dictionnary, key)>
    <#return dictionnary[key][locale]!key>
  </#if>
  <#return key>
</#function>

<#-- toHttpsRemoteUrl: rewrites git SSH GitHub remote URLs to HTTPS -->
<#function toHttpsRemoteUrl url>
  <#assign value = (url!"")?trim>
  <#assign value = value?replace("=ssh://git@github.com/", "=https://github.com/")>
  <#assign value = value?replace("=git@github.com:", "=https://github.com/")>
  <#assign value = value?replace("ssh://git@github.com/", "https://github.com/")>
  <#assign value = value?replace("git@github.com:", "https://github.com/")>
  <#return value>
</#function>

<#-- MACROS -->
<#-- header: generates a header with given text as heading and add it to TOC with its anchor link -->
<#macro header toc anchors heading text>
${heading} ${text}${lineBreak}
<#assign a = anchor(anchors, text)>
<#if (heading?keep_before_last("#")?length > 0)>
<#assign toc += "" + heading?keep_before_last("##")?replace("#","    ") + "-" + " ["+text+"](#"+ a +")" + lineBreak>
</#if>
</#macro>

<#-- comment: add given text -->
<#macro comment text>
<#if (text?length > 0) >
${text}${lineBreak}
</#if>
</#macro>

<#-- table: generates a table with given headers and rows -->
<#macro table title headers rows>
<#if (rows?size > 0)>
${title}${lineBreak}
<table>
<tr>
<#list headers as header><th>${header}</th></#list>
</tr>
<#list rows as i>
<tr>
<#list headers as header><td>${i[header]}</td></#list>
</tr>
</#list>
</table>${lineBreak}
</#if>
</#macro>

<#-- installation : add project installation instructions if any -->
<#macro installation>
<#if locale == "US">
1. In your Convertigo Studio click on ![](https://github.com/convertigo/convertigo/blob/develop/eclipse-plugin-studio/icons/studio/project_import.gif?raw=true "Import a project in treeview") to import a project in the treeview
2. In the import wizard

   ![](https://github.com/convertigo/convertigo/blob/develop/eclipse-plugin-studio/tomcat/webapps/convertigo/templates/ftl/project_import_wzd.png?raw=true "Import Project")
   
   paste the text below into the `Project remote URL` field:
   <table>
     <tr><td>Usage</td><td>Click the copy button at the end of the line</td></tr>
     <tr><td>To contribute</td><td>${lineBreak}
     ```
     ${toHttpsRemoteUrl(project.contributeUrl)}
     ```
     </td></tr>
     <tr><td>To simply use</td><td>${lineBreak}
     ```
     ${toHttpsRemoteUrl(project.usageUrl)}
     ```
     </td></tr>
    </table>
3. Click the `Finish` button. This will automatically import the __${project.name}__ project
</#if>
<#if locale == "FR">
1. Dans votre Studio Convertigo, cliquez sur ![](https://github.com/convertigo/convertigo/blob/develop/eclipse-plugin-studio/icons/studio/project_import.gif?raw=true "Import a project in treeview") pour importer un projet dans l'arborescence
2. Dans l'assistant d'importation

   ![](https://github.com/convertigo/convertigo/blob/develop/eclipse-plugin-studio/tomcat/webapps/convertigo/templates/ftl/project_import_wzd.png?raw=true "Import Project")
   
   collez le texte ci-dessous dans le champ `Project remote URL`:
   <table>
     <tr><td>Usage</td><td>Cliquez sur le bouton de copie en fin de ligne</td></tr>
     <tr><td>Pour contribuer</td><td>${lineBreak}
     ```
     ${lineBreak}${toHttpsRemoteUrl(project.contributeUrl)}
     ```
     </td></tr>
     <tr><td>Pour simplement utiliser</td><td>${lineBreak}
     ```
     ${lineBreak}${toHttpsRemoteUrl(project.usageUrl)}
     ```
     </td></tr>
    </table>
3. Cliquez sur le bouton `Finish`. Cela importera automatiquement le projet __${project.name}__
</#if>
${lineBreak}
</#macro>

<#-- DEFAULT PROJECT TEMPLATE -->

<#-- anchors variable for TOC : do not modify -->
<#assign anchors = [""]>
<#-- toc variable : do not modify -->
<#assign toc = "">

<#-- Please modify below templates as needed -->

<#-- intro variable : add project header and comment -->
<#assign intro>
<@header toc=toc anchors=anchors heading="#" text=project.label />
<@comment text=project.comment />
[![Build, Deploy and Tests](https://github.com/convertigo/c8oprj-lib-microsoft-teams/actions/workflows/build-and-release.yml/badge.svg?branch=8.0.0.0)](https://github.com/convertigo/c8oprj-lib-microsoft-teams/actions/workflows/build-and-release.yml)
<#-- you can add your text or own macro call here to add something -->
<#--
This is text i want to add after the project comment
<@my_own_macro my_var='xxxx xxxxx xxxxx'>
-->
</#assign>

<#-- content variable : add project sub-beans header and comment -->
<#-- you can add your text or own macro call anywhere -->
<#assign content>
<#if on("installation") && (project.url?length > 0) && (project.url != project.name)>
	<@header toc=toc anchors=anchors heading="##" text=help("installation") />
	<@installation />
</#if>
<#if locale == "US">
	<@header toc=toc anchors=anchors heading="##" text="Configuration Symbols" />
These symbols can be set at project level and reused by all sequences.
In a standard deployment, they are configured once on the server and not passed on each request.

<table>
<tr><th>Symbol</th><th>Required</th><th>Secret</th><th>Purpose</th></tr>
<tr><td><code><#noparse>${Microsoft_AzGraph.tenantId}</#noparse></code></td><td>Yes for app-mode (server-side)</td><td>No</td><td>Azure Entra tenant ID.</td></tr>
<tr><td><code><#noparse>${Microsoft_AzGraph.clientId}</#noparse></code></td><td>Yes for app-mode (server-side)</td><td>No</td><td>Application (client) ID.</td></tr>
<tr><td><code><#noparse>${Microsoft_AzGraph.clientSecret.secret}</#noparse></code></td><td>Yes for app-mode (server-side)</td><td>Yes</td><td>Application client secret.</td></tr>
<tr><td><code><#noparse>${lib_Microsoft_Teams.ewsUrl}</#noparse></code></td><td>Optional (for `provider=ews` or `provider=auto` fallback)</td><td>No</td><td>EWS endpoint URL for Exchange on-premises.</td></tr>
<tr><td><code><#noparse>${lib_Microsoft_Teams.ewsUsername}</#noparse></code></td><td>Optional (for `provider=ews` or `provider=auto` fallback)</td><td>No</td><td>EWS technical username.</td></tr>
<tr><td><code><#noparse>${lib_Microsoft_Teams.ewsPassword.secret}</#noparse></code></td><td>Optional (for `provider=ews` or `provider=auto` fallback)</td><td>Yes</td><td>EWS technical password.</td></tr>
<tr><td><code><#noparse>${lib_Microsoft_Teams.ewsImpersonateUserId}</#noparse></code></td><td>Optional</td><td>No</td><td>EWS impersonation mailbox; defaults to organizer when omitted.</td></tr>
</table>

	<@header toc=toc anchors=anchors heading="##" text="Authentication Model" />
- Default mode (recommended for backend use): rely on server-side symbols (`tenantId`, `clientId`, `clientSecret`) and do not pass credentials in calls.
- Delegated override: pass `accessToken`; tenant/client/secret are ignored.
- Application override: pass tenant/client/secret explicitly in request variables.
- Sequence responses expose `tokenMode` (`delegated` or `application`) for diagnostics.

	<@header toc=toc anchors=anchors heading="##" text="Test Script (Endpoint-Only)" />
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
- `RUN_TEAM_WRITES=true` to allow `CreateTeam`, `CreateTeamChannel`, `AddTeamMember`, `RemoveTeamMember`.
- `RUN_MESSAGE_WRITES=true` to allow `SendChatMessage`, `SendChannelMessage`, `ShareDriveItemToChatOrChannel`.
- `RUN_EVENT_RESPONSE_WRITES=true` to allow `RespondToMeetingEvent`.
- `RUN_ONLINE_MEETING_TESTS=true` to allow `CreateOnlineMeeting` when the tenant policy is configured for application access.
- `RUN_FILE_WRITES=false` to block `UploadMeetingAttachment` when file writes must be disabled.
- `TEAM_ID`, `CHANNEL_ID`, `CHAT_ID`, `TARGET_MEMBER_USER_ID`, `SERIES_MASTER_EVENT_ID`, `ONLINE_MEETING_ID`, `ONLINE_MEETING_JOIN_URL`, `RECORDING_ID`, `DRIVE_ITEM_WEB_URL`, `SUBSCRIPTION_ID`, `WEBHOOK_URL` to provide existing runtime artifacts when the scenario cannot create them.

	<@header toc=toc anchors=anchors heading="##" text="Required Azure Permissions" />
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

	<@header toc=toc anchors=anchors heading="##" text="Known Limitations" />
- Some events/mailboxes do not support listing event extensions (`/events/{id}/extensions`) and Graph returns: `The OData request is not supported.`
- In `GetMeetingEvent`, keep `includeExtensions=true` with `failIfExtensionsUnsupported=false` to return event data and get:
  - `extensionsUnsupported=true`
  - `extensionsUnsupportedError` with the Graph message
- Set `failIfExtensionsUnsupported=true` only when extension listing is mandatory.

	<@header toc=toc anchors=anchors heading="##" text="Payload Examples" />
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
</#if>
<#if on("references") && has(project,"references")>
  	<@header toc=toc anchors=anchors heading="##" text=help("references") />
  	<#list project.references as reference>
    	<@header toc=toc anchors=anchors heading="###" text=reference.label />
    	<@comment text=reference.comment />
  	</#list>
</#if>
<#if on("sequences") && has(project,"sequences")>
  	<@header toc=toc anchors=anchors heading="##" text=help("sequences") />
  	<#list project.sequences as sequence>
    	<@header toc=toc anchors=anchors heading="###" text=sequence.label />
    	<@comment text=sequence.comment />
    	<#if on("variables") && has(sequence,"variables")>
      		<@table title="**"+help("variables")+"**" headers=["name","comment"] rows=sequence.variables />
    	</#if>
  </#list>
</#if>
<#if on("connectors") && has(project,"connectors")>
  	<@header toc=toc anchors=anchors heading="##" text=help("connectors") />
  	<#list project.connectors as connector>
    	<@header toc=toc anchors=anchors heading="###" text=connector.label />
    	<@comment text=connector.comment />
    	<#if on("transactions") && has(connector,"transactions")>
      		<@header toc=toc anchors=anchors heading="####" text=help("transactions") />
      		<#list connector.transactions as transaction>
        		<@header toc=toc anchors=anchors heading="#####" text=transaction.label />
        		<@comment text=transaction.comment />
        		<#if on("variables") && has(transaction,"variables")>
          			<@table title="**"+help("variables")+"**" headers=["name","comment"] rows=transaction.variables />
        		</#if>
      		</#list>
    	</#if>
  	</#list>
</#if>
<#if on("urlmapper") && has(project,"urlmapper")>
  	<@header toc=toc anchors=anchors heading="##" text=help("urlmapper") />
  	<@comment text=project.urlmapper.comment />
  	<#if on("mappings") && has(project.urlmapper,"mappings")>
	  	<@header toc=toc anchors=anchors heading="###" text=help("mappings") />
	  	<#list project.urlmapper.mappings as mapping>
	    	<@header toc=toc anchors=anchors heading="####" text=mapping.label />
	    	<@comment text=mapping.comment />
	    	<#if on("operations") && has(mapping,"operations")>
	      		<@header toc=toc anchors=anchors heading="#####" text=help("operations") />
	      		<#list mapping.operations as operation>
	        		<@header toc=toc anchors=anchors heading="######" text=operation.label />
	        		<@comment text=operation.comment />
	        		<#if on("parameters") && has(operation,"parameters")>
	          			<@table title="**"+help("parameters")+"**" headers=["name","comment"] rows=operation.parameters />
	        		</#if>
	      		</#list>
	    	</#if>
	  </#list>
	</#if>
</#if>
<#if on("mobileapp") && has(project,"mobileapp")>
	<#assign appname = (project.mobileapp.applicationName?length > 0)
			?string(project.mobileapp.applicationName, (project.name?starts_with("lib_"))?string(help("mobilelib"),help("mobileapp"))) />
  	<@header toc=toc anchors=anchors heading="##" text=appname />
  	<@comment text=project.mobileapp.comment />
  	<#if on("pages") && has(project.mobileapp,"pages")>
	  	<@header toc=toc anchors=anchors heading="###" text=help("pages") />
	  	<#list project.mobileapp.pages as page>
	    	<@header toc=toc anchors=anchors heading="####" text=page.label />
	    	<@comment text=page.comment />
 	  </#list>
	</#if>
  	<#if on("actions") && has(project.mobileapp,"actions")>
	  	<@header toc=toc anchors=anchors heading="###" text=help("actions") />
	  	<#list project.mobileapp.actions as action>
	    	<@header toc=toc anchors=anchors heading="####" text=action.label />
	    	<@comment text=action.comment />
    		<#if on("variables") && has(action,"variables")>
      			<@table title="**"+help("variables")+"**" headers=["name","comment"] rows=action.variables />
    		</#if>
	  </#list>
	</#if>
  	<#if on("components") && has(project.mobileapp,"components")>
	  	<@header toc=toc anchors=anchors heading="###" text=help("components") />
	  	<#list project.mobileapp.components as component>
	    	<@header toc=toc anchors=anchors heading="####" text=component.label />
	    	<@comment text=component.comment />
    		<#if on("variables") && has(component,"variables")>
      			<@table title="**"+help("variables")+"**" headers=["name","comment"] rows=component.variables />
    		</#if>
    		<#if on("events") && has(component,"events")>
      			<@table title="**"+help("events")+"**" headers=["name","comment"] rows=component.events />
    		</#if>
	  </#list>
	</#if>
</#if>
</#assign>


<#-- output project name and comment -->
${intro}
<#-- output project.md link -->
${help("more.info")} : [documentation](./project.md)

<#-- output table of content -->
<#if on("toc")>${toc}</#if>

<#-- output project content -->
${content}
