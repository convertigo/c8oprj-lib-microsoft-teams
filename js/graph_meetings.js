// Shared helpers for Microsoft Graph meeting sequences (Rhino compatible).

function gm_isBlank(value) {
  return value === null || value === undefined || String(value).trim().length === 0;
}

function gm_safeString(value) {
  return value === null || value === undefined ? "" : String(value);
}

function gm_defaultString(value, defaultValue) {
  return gm_isBlank(value) ? defaultValue : String(value);
}

var gm_graphClassCache = {};
var gm_graphPreferredLoader = null;
var gm_graphFallbackLoader = null;
var gm_graphJarCheckedPaths = [];
var gm_graphLoadErrors = [];

function gm_tryLoadClass(className, loader) {
  try {
    if (loader !== null && loader !== undefined) {
      return java.lang.Class.forName(String(className), true, loader);
    }
    return java.lang.Class.forName(String(className));
  } catch (loadError) {
    try {
      var loaderLabel = loader === null || loader === undefined ? "<default>" : String(loader);
      gm_graphLoadErrors.push(loaderLabel + " -> " + String(loadError.getClass().getName()) + ": " + String(loadError.getMessage()));
    } catch (ignoreStoreLoadError) {
    }
    return null;
  }
}

function gm_guessProjectName() {
  try {
    if (typeof context !== "undefined" && context !== null && context.requestedObject && context.requestedObject.getProject) {
      var requestedProject = context.requestedObject.getProject();
      if (requestedProject !== null && requestedProject !== undefined && requestedProject.getName) {
        return String(requestedProject.getName());
      }
    }
  } catch (ignoreRequestedObjectProject) {
  }
  try {
    if (typeof context !== "undefined" && context !== null) {
      if (context.projectName !== null && context.projectName !== undefined) {
        return String(context.projectName);
      }
    }
  } catch (ignoreContextProperty) {
  }
  try {
    if (typeof context !== "undefined" && context !== null && context.getProjectName) {
      return String(context.getProjectName());
    }
  } catch (ignoreContextMethod) {
  }
  try {
    if (typeof context !== "undefined" && context !== null && context.getProject) {
      var projectObject = context.getProject();
      if (projectObject !== null && projectObject !== undefined && projectObject.getName) {
        return String(projectObject.getName());
      }
    }
  } catch (ignoreContextProject) {
  }
  try {
    if (typeof project !== "undefined" && project !== null && project.getName) {
      return String(project.getName());
    }
  } catch (ignoreProjectName) {
  }
  return "";
}

function gm_getProjectDirectory(projectName) {
  var engine = Packages.com.twinsoft.convertigo.engine.Engine.theApp;
  var manager = engine.databaseObjectsManager;
  var projectObject = null;
  var targetName = gm_defaultString(projectName, "");

  if (typeof context !== "undefined" && context !== null && context.requestedObject && context.requestedObject.getProject) {
    try {
      projectObject = context.requestedObject.getProject();
    } catch (ignoreRequestedObjectProject) {
      projectObject = null;
    }
  }

  if (projectObject === null && !gm_isBlank(targetName)) {
    try {
      projectObject = manager.getOriginalProjectByName(String(targetName));
    } catch (ignoreOriginalLookup) {
      projectObject = null;
    }
  }

  if (projectObject === null && !gm_isBlank(targetName)) {
    try {
      projectObject = manager.getProjectByName(String(targetName));
    } catch (ignoreProjectLookup) {
      projectObject = null;
    }
  }

  if (projectObject !== null) {
    try {
      if (projectObject.getDirFile) {
        var dirFile = projectObject.getDirFile();
        if (dirFile !== null) {
          return dirFile;
        }
      }
    } catch (ignoreDirFile) {
    }
    try {
      if (projectObject.getDirPath) {
        var dirPath = projectObject.getDirPath();
        if (!gm_isBlank(dirPath)) {
          return new java.io.File(String(dirPath));
        }
      }
    } catch (ignoreDirPath) {
    }
  }

  if (!gm_isBlank(targetName)) {
    try {
      var projectDirPath = engine.projectDir(String(targetName));
      if (!gm_isBlank(projectDirPath)) {
        return new java.io.File(String(projectDirPath));
      }
    } catch (ignoreEngineProjectDir) {
    }
  }

  return null;
}

function gm_findGraphJar() {
  var candidates = new java.util.ArrayList();
  gm_graphJarCheckedPaths = [];

  candidates.add(new java.io.File(".//libs/microsoft-graph-teams-flat.jar"));
  candidates.add(new java.io.File("./libs/microsoft-graph-teams-flat.jar"));
  candidates.add(new java.io.File(java.lang.System.getProperty("user.dir"), "libs/microsoft-graph-teams-flat.jar"));

  var projectName = gm_guessProjectName();
  var projectDir = gm_getProjectDirectory(projectName);
  if (projectDir !== null) {
    candidates.add(new java.io.File(projectDir, "libs/microsoft-graph-teams-flat.jar"));
  }

  var i;
  for (i = 0; i < candidates.size(); i++) {
    var candidate = candidates.get(i);
    try {
      gm_graphJarCheckedPaths.push(String(candidate.getAbsolutePath()));
    } catch (ignorePath) {
    }
    if (candidate !== null && candidate.exists() && candidate.isFile()) {
      return candidate;
    }
  }
  return null;
}

function gm_getGraphFallbackLoader() {
  if (gm_graphFallbackLoader !== null) {
    return gm_graphFallbackLoader;
  }

  var graphJar = gm_findGraphJar();
  if (graphJar === null) {
    return null;
  }

  var parentLoader = null;
  try {
    parentLoader = java.lang.Thread.currentThread().getContextClassLoader();
  } catch (ignoreParentLoader) {
  }

  try {
    var urlArray = java.lang.reflect.Array.newInstance(java.net.URL, 1);
    java.lang.reflect.Array.set(urlArray, 0, graphJar.toURI().toURL());
    gm_graphFallbackLoader = new java.net.URLClassLoader(urlArray, parentLoader);
    return gm_graphFallbackLoader;
  } catch (ignoreFallbackLoaderError) {
    return null;
  }
}

function gm_getGraphClass(className) {
  var key = String(className);
  if (Object.prototype.hasOwnProperty.call(gm_graphClassCache, key)) {
    return gm_graphClassCache[key];
  }
  gm_graphLoadErrors = [];

  var clazz = null;
  if (gm_graphPreferredLoader !== null) {
    clazz = gm_tryLoadClass(key, gm_graphPreferredLoader);
  }

  if (clazz === null) {
    var contextLoader = null;
    try {
      contextLoader = java.lang.Thread.currentThread().getContextClassLoader();
    } catch (ignoreContextLoader) {
    }
    clazz = gm_tryLoadClass(key, contextLoader);
  }

  if (clazz === null) {
    clazz = gm_tryLoadClass(key, null);
  }

  if (clazz === null) {
    var fallbackLoader = gm_getGraphFallbackLoader();
    if (fallbackLoader !== null) {
      clazz = gm_tryLoadClass(key, fallbackLoader);
      if (clazz !== null) {
        gm_graphPreferredLoader = fallbackLoader;
      }
    }
  }

  if (clazz === null) {
    var checked = gm_graphJarCheckedPaths.length === 0 ? "none" : gm_graphJarCheckedPaths.join(", ");
    var details = gm_graphLoadErrors.length === 0 ? "none" : gm_graphLoadErrors.join(" | ");
    throw new java.lang.RuntimeException(
      "Graph SDK class not found: " + key + ". Ensure libs/microsoft-graph-teams-flat.jar is loaded. Checked: " + checked + ". Load errors: " + details
    );
  }

  gm_graphClassCache[key] = clazz;
  return clazz;
}

function gm_newGraphObject(className) {
  var clazz = gm_getGraphClass(className);
  return clazz.getDeclaredConstructor().newInstance();
}

function gm_isGraphInstance(value, className) {
  if (value === null || value === undefined) {
    return false;
  }
  return gm_getGraphClass(className).isInstance(value);
}

function gm_enumForValue(className, value, defaultValue) {
  var normalized = gm_defaultString(value, defaultValue);
  var enumClass = gm_getGraphClass(className);

  try {
    var forValueMethod = enumClass.getMethod("forValue", java.lang.String.class);
    var enumValue = forValueMethod.invoke(null, String(normalized));
    if (enumValue !== null) {
      return enumValue;
    }
  } catch (ignoreForValue) {
  }

  var constants = enumClass.getEnumConstants();
  if (constants !== null) {
    var target = String(normalized).toLowerCase();
    var i;
    for (i = 0; i < constants.length; i++) {
      var candidate = constants[i];
      try {
        if (String(candidate.getValue()).toLowerCase() === target) {
          return candidate;
        }
      } catch (ignoreValueAccessor) {
      }
      if (String(candidate.name()).toLowerCase() === target) {
        return candidate;
      }
    }
  }

  throw new java.lang.IllegalArgumentException("Invalid value '" + normalized + "' for enum " + className);
}

function gm_require(name, value) {
  if (gm_isBlank(value)) {
    throw new java.lang.IllegalArgumentException("Missing required input: " + name);
  }
  return String(value);
}

function gm_toBoolean(value, defaultValue) {
  if (gm_isBlank(value)) {
    return defaultValue;
  }
  var normalized = String(value).toLowerCase();
  return normalized === "true" || normalized === "1" || normalized === "yes" || normalized === "y";
}

function gm_parseInteger(name, value, defaultValue) {
  if (gm_isBlank(value)) {
    return defaultValue;
  }
  var parsed = parseInt(String(value), 10);
  if (isNaN(parsed)) {
    throw new java.lang.IllegalArgumentException("Invalid integer for " + name + ": " + value);
  }
  return parsed;
}

function gm_parseDouble(name, value, defaultValue) {
  if (gm_isBlank(value)) {
    return defaultValue;
  }
  var parsed = parseFloat(String(value));
  if (isNaN(parsed)) {
    throw new java.lang.IllegalArgumentException("Invalid decimal for " + name + ": " + value);
  }
  return parsed;
}

function gm_readAll(inputStream) {
  if (inputStream === null) {
    return "";
  }
  var scanner = new java.util.Scanner(inputStream, "UTF-8").useDelimiter("\\A");
  try {
    return scanner.hasNext() ? String(scanner.next()) : "";
  } finally {
    try {
      scanner.close();
    } catch (ignore) {
    }
  }
}

function gm_urlEncode(value) {
  return java.net.URLEncoder.encode(String(value), "UTF-8");
}

function gm_acquireAppToken(tenantId, clientId, clientSecret, scope) {
  var endpoint = "https://login.microsoftonline.com/" + gm_require("tenantId", tenantId) + "/oauth2/v2.0/token";
  var payload =
    "client_id=" + gm_urlEncode(gm_require("clientId", clientId)) +
    "&client_secret=" + gm_urlEncode(gm_require("clientSecret", clientSecret)) +
    "&scope=" + gm_urlEncode(gm_defaultString(scope, "https://graph.microsoft.com/.default")) +
    "&grant_type=client_credentials";

  var url = new java.net.URL(endpoint);
  var connection = url.openConnection();
  connection.setRequestMethod("POST");
  connection.setDoOutput(true);
  connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
  connection.setRequestProperty("Accept", "application/json");

  var output = connection.getOutputStream();
  try {
    output.write(new java.lang.String(payload).getBytes("UTF-8"));
  } finally {
    output.close();
  }

  var statusCode = connection.getResponseCode();
  var body = gm_readAll(statusCode >= 200 && statusCode < 300 ? connection.getInputStream() : connection.getErrorStream());
  if (statusCode < 200 || statusCode >= 300) {
    throw new java.lang.RuntimeException("Token endpoint failed (" + statusCode + "): " + body);
  }

  var parsed = JSON.parse(body);
  if (!parsed || gm_isBlank(parsed.access_token)) {
    throw new java.lang.RuntimeException("Token endpoint returned no access_token");
  }

  return {
    mode: "application",
    token: String(parsed.access_token)
  };
}

function gm_resolveToken(accessToken, tenantId, clientId, clientSecret) {
  if (!gm_isBlank(accessToken)) {
    return {
      mode: "delegated",
      token: String(accessToken)
    };
  }
  return gm_acquireAppToken(tenantId, clientId, clientSecret, "https://graph.microsoft.com/.default");
}

function gm_newGraphClientWithBearer(accessToken) {
  try {
    // Resolve a core model first so GraphServiceClient and model classes stay on the same classloader.
    gm_getGraphClass("com.microsoft.graph.models.Event");

    var authProviderClass = gm_getGraphClass("com.microsoft.kiota.authentication.AuthenticationProvider");
    var authProvider = new JavaAdapter(authProviderClass, {
      authenticateRequest: function(requestInformation, additionalAuthenticationContext) {
        requestInformation.headers.add("Authorization", "Bearer " + accessToken);
      }
    });

    var graphClientClass = gm_getGraphClass("com.microsoft.graph.serviceclient.GraphServiceClient");
    return graphClientClass.getDeclaredConstructor(authProviderClass).newInstance(authProvider);
  } catch (dynamicClientError) {
    var fallbackAuthProvider = new JavaAdapter(Packages.com.microsoft.kiota.authentication.AuthenticationProvider, {
      authenticateRequest: function(requestInformation, additionalAuthenticationContext) {
        requestInformation.headers.add("Authorization", "Bearer " + accessToken);
      }
    });
    return new Packages.com.microsoft.graph.serviceclient.GraphServiceClient(fallbackAuthProvider);
  }
}

function gm_newDateTimeTimeZone(dateTimeIso, timeZone) {
  var value = gm_newGraphObject("com.microsoft.graph.models.DateTimeTimeZone");
  value.setDateTime(String(dateTimeIso));
  value.setTimeZone(String(timeZone));
  return value;
}

function gm_dttzToObject(dateTimeTimeZone) {
  if (dateTimeTimeZone === null) {
    return null;
  }
  return {
    dateTime: gm_safeString(dateTimeTimeZone.getDateTime()),
    timeZone: gm_safeString(dateTimeTimeZone.getTimeZone())
  };
}

function gm_newBodyHtml(html) {
  var body = gm_newGraphObject("com.microsoft.graph.models.ItemBody");
  body.setContentType(gm_enumForValue("com.microsoft.graph.models.BodyType", "html", "html"));
  body.setContent(String(html));
  return body;
}

function gm_parseAttendeeType(typeValue) {
  var normalized = gm_defaultString(typeValue, "required").toLowerCase();
  return gm_enumForValue("com.microsoft.graph.models.AttendeeType", normalized, "required");
}

function gm_parseAttendees(attendeesJson) {
  if (gm_isBlank(attendeesJson)) {
    throw new java.lang.IllegalArgumentException("Missing required input: attendeesJson");
  }

  var parsed = JSON.parse(String(attendeesJson));
  if (!(parsed instanceof Array)) {
    throw new java.lang.IllegalArgumentException("attendeesJson must be a JSON array");
  }

  var attendees = new java.util.ArrayList();
  var i;
  for (i = 0; i < parsed.length; i++) {
    var item = parsed[i];
    if (!item) {
      continue;
    }
    var address = item.email || item.address;
    if (gm_isBlank(address)) {
      continue;
    }

    var attendee = gm_newGraphObject("com.microsoft.graph.models.Attendee");
    var emailAddress = gm_newGraphObject("com.microsoft.graph.models.EmailAddress");
    emailAddress.setAddress(String(address));
    if (!gm_isBlank(item.name)) {
      emailAddress.setName(String(item.name));
    }
    attendee.setEmailAddress(emailAddress);
    attendee.setType(gm_parseAttendeeType(item.type));
    attendees.add(attendee);
  }

  if (attendees.isEmpty()) {
    throw new java.lang.IllegalArgumentException("attendeesJson contains no usable attendee");
  }
  return attendees;
}

function gm_getScheduleEmails(organizerUserId, attendeesJson) {
  var emails = new java.util.ArrayList();
  emails.add(String(organizerUserId));

  if (!gm_isBlank(attendeesJson)) {
    var parsed = JSON.parse(String(attendeesJson));
    if (parsed instanceof Array) {
      var i;
      for (i = 0; i < parsed.length; i++) {
        var item = parsed[i];
        if (!item) {
          continue;
        }
        var address = item.email || item.address;
        if (!gm_isBlank(address)) {
          emails.add(String(address));
        }
      }
    }
  }
  return emails;
}

function gm_enumValue(enumValue) {
  if (enumValue === null || enumValue === undefined) {
    return "";
  }
  try {
    return String(enumValue.getValue());
  } catch (ignore) {
    return String(enumValue);
  }
}

function gm_errorClass(error) {
  try {
    if (error && error.javaException) {
      return String(error.javaException.getClass().getName());
    }
    if (error && error.getClass) {
      return String(error.getClass().getName());
    }
  } catch (ignore) {
  }
  return "";
}

function gm_responseOk(graphOperation, tokenMode, requiredPermission, data) {
  return {
    ok: true,
    status: "OK",
    graphOperation: graphOperation,
    tokenMode: tokenMode,
    requiredPermission: requiredPermission,
    data: data
  };
}

function gm_responseError(graphOperation, tokenMode, requiredPermission, error) {
  var message = "";
  try {
    message = String(error.message);
  } catch (ignore) {
    message = String(error);
  }
  return {
    ok: false,
    status: "ERROR",
    graphOperation: graphOperation,
    tokenMode: tokenMode,
    requiredPermission: requiredPermission,
    errorClass: gm_errorClass(error),
    errorMessage: message
  };
}

function gm_jsToJava(value) {
  if (value === null || value === undefined) {
    return null;
  }
  if (value instanceof Array) {
    var list = new java.util.ArrayList();
    var i;
    for (i = 0; i < value.length; i++) {
      list.add(gm_jsToJava(value[i]));
    }
    return list;
  }
  if (typeof value === "object") {
    var map = new java.util.HashMap();
    var key;
    for (key in value) {
      if (Object.prototype.hasOwnProperty.call(value, key)) {
        map.put(String(key), gm_jsToJava(value[key]));
      }
    }
    return map;
  }
  if (typeof value === "boolean") {
    return java.lang.Boolean.valueOf(value ? "true" : "false");
  }
  if (typeof value === "number") {
    var asString = String(value);
    return asString.indexOf(".") >= 0 ? new java.lang.Double(asString) : new java.lang.Long(asString);
  }
  return String(value);
}

function gm_parseMetadataJson(metadataJson) {
  if (gm_isBlank(metadataJson)) {
    return {};
  }
  var metadata = JSON.parse(String(metadataJson));
  if (metadata === null || metadata === undefined || metadata instanceof Array || typeof metadata !== "object") {
    throw new java.lang.IllegalArgumentException("metadataJson must be a JSON object");
  }
  return metadata;
}

function gm_mergeObjects(baseObject, overrideObject) {
  var merged = {};
  var key;
  for (key in baseObject) {
    if (Object.prototype.hasOwnProperty.call(baseObject, key)) {
      merged[key] = baseObject[key];
    }
  }
  for (key in overrideObject) {
    if (Object.prototype.hasOwnProperty.call(overrideObject, key)) {
      merged[key] = overrideObject[key];
    }
  }
  return merged;
}

function gm_extensionAdditionalDataToObject(additionalData) {
  var result = {};
  if (additionalData === null || additionalData === undefined) {
    return result;
  }
  var iterator = additionalData.entrySet().iterator();
  while (iterator.hasNext()) {
    var entry = iterator.next();
    result[String(entry.getKey())] = entry.getValue();
  }
  return result;
}

function gm_upsertOpenExtension(graphClient, organizerUserId, eventId, extensionId, metadataJson, mergeMode) {
  var metadataObject = gm_parseMetadataJson(metadataJson);
  var normalizedMergeMode = gm_defaultString(mergeMode, "merge").toLowerCase();

  var eventBuilder = graphClient.users().byUserId(String(organizerUserId)).events().byEventId(String(eventId));
  var extensionBuilder = eventBuilder.extensions().byExtensionId(String(extensionId));

  var existing = null;
  try {
    existing = extensionBuilder.get();
  } catch (ignoreMissing) {
    existing = null;
  }

  var finalMetadata = metadataObject;
  if (existing !== null && normalizedMergeMode === "merge") {
    finalMetadata = gm_mergeObjects(gm_extensionAdditionalDataToObject(existing.getAdditionalData()), metadataObject);
  }

  var extension = gm_newGraphObject("com.microsoft.graph.models.OpenTypeExtension");
  extension.setId(String(extensionId));
  extension.setExtensionName(String(extensionId));
  extension.setAdditionalData(gm_jsToJava(finalMetadata));

  var persisted;
  if (existing === null) {
    persisted = eventBuilder.extensions().post(extension);
  } else {
    persisted = extensionBuilder.patch(extension);
  }

  return {
    action: existing === null ? "created" : "updated",
    extensionId: gm_safeString(persisted.getId())
  };
}

function gm_parseIsoToEpochMillis(dateTimeIso, fallbackTimeZone) {
  var text = gm_require("dateTimeIso", dateTimeIso);
  try {
    return java.time.OffsetDateTime.parse(text).toInstant().toEpochMilli();
  } catch (ignoreOffset) {
  }
  try {
    return java.time.ZonedDateTime.parse(text).toInstant().toEpochMilli();
  } catch (ignoreZoned) {
  }
  try {
    var zone = java.time.ZoneId.of(gm_defaultString(fallbackTimeZone, "UTC"));
    return java.time.LocalDateTime.parse(text).atZone(zone).toInstant().toEpochMilli();
  } catch (ignoreLocal) {
  }
  throw new java.lang.IllegalArgumentException("Invalid ISO-8601 datetime: " + text);
}

function gm_epochMillisToIsoLocal(epochMillis, timeZone) {
  var zone = java.time.ZoneId.of(gm_defaultString(timeZone, "UTC"));
  var instant = java.time.Instant.ofEpochMilli(new java.lang.Long(String(epochMillis)));
  var zoned = java.time.ZonedDateTime.ofInstant(instant, zone);
  var formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
  return String(zoned.format(formatter));
}

function gm_dttzToEpochMillis(dateTimeTimeZone, fallbackTimeZone) {
  if (dateTimeTimeZone === null || dateTimeTimeZone === undefined) {
    return -1;
  }
  var dateTimeValue = gm_safeString(dateTimeTimeZone.getDateTime());
  if (gm_isBlank(dateTimeValue)) {
    return -1;
  }
  var zone = gm_defaultString(dateTimeTimeZone.getTimeZone(), fallbackTimeZone);
  return gm_parseIsoToEpochMillis(dateTimeValue, zone);
}

function gm_isBusyStatus(statusValue) {
  var normalized = gm_defaultString(statusValue, "busy").toLowerCase();
  return normalized !== "free" && normalized !== "unknown";
}

function gm_collectBusyIntervals(scheduleValues, fallbackTimeZone) {
  var intervals = [];
  if (scheduleValues === null || scheduleValues === undefined) {
    return intervals;
  }

  var si;
  for (si = 0; si < scheduleValues.size(); si++) {
    var scheduleInfo = scheduleValues.get(si);
    if (scheduleInfo === null) {
      continue;
    }
    var busyItems = scheduleInfo.getScheduleItems();
    if (busyItems === null) {
      continue;
    }

    var bi;
    for (bi = 0; bi < busyItems.size(); bi++) {
      var busy = busyItems.get(bi);
      if (busy === null || !gm_isBusyStatus(gm_enumValue(busy.getStatus()))) {
        continue;
      }

      var startMs = gm_dttzToEpochMillis(busy.getStart(), fallbackTimeZone);
      var endMs = gm_dttzToEpochMillis(busy.getEnd(), fallbackTimeZone);
      if (startMs >= 0 && endMs > startMs) {
        intervals.push([startMs, endMs]);
      }
    }
  }

  intervals.sort(function(a, b) {
    return a[0] - b[0];
  });

  var merged = [];
  var i;
  for (i = 0; i < intervals.length; i++) {
    var current = intervals[i];
    if (merged.length === 0) {
      merged.push(current);
      continue;
    }
    var last = merged[merged.length - 1];
    if (current[0] <= last[1]) {
      if (current[1] > last[1]) {
        last[1] = current[1];
      }
    } else {
      merged.push(current);
    }
  }

  return merged;
}

function gm_findFirstAvailableSlot(scheduleValues, windowStartIso, windowEndIso, timeZone, durationMinutes, stepMinutes) {
  var startMs = gm_parseIsoToEpochMillis(windowStartIso, timeZone);
  var endMs = gm_parseIsoToEpochMillis(windowEndIso, timeZone);
  if (endMs <= startMs) {
    throw new java.lang.IllegalArgumentException("windowEndIso must be after windowStartIso");
  }

  var meetingMinutes = durationMinutes < 5 ? 5 : durationMinutes;
  var checkStepMinutes = stepMinutes < 5 ? 5 : stepMinutes;
  var durationMs = meetingMinutes * 60 * 1000;
  var stepMs = checkStepMinutes * 60 * 1000;
  var busyIntervals = gm_collectBusyIntervals(scheduleValues, timeZone);

  var cursor = startMs;
  while (cursor + durationMs <= endMs) {
    var slotEnd = cursor + durationMs;
    var hasConflict = false;

    var i;
    for (i = 0; i < busyIntervals.length; i++) {
      var busy = busyIntervals[i];
      if (busy[0] >= slotEnd) {
        break;
      }
      if (busy[0] < slotEnd && cursor < busy[1]) {
        hasConflict = true;
        break;
      }
    }

    if (!hasConflict) {
      return {
        startIso: gm_epochMillisToIsoLocal(cursor, timeZone),
        endIso: gm_epochMillisToIsoLocal(slotEnd, timeZone)
      };
    }

    cursor += stepMs;
  }

  return null;
}

function gm_getGraphBaseUrl(graphClient) {
  var baseUrl = "https://graph.microsoft.com/v1.0";
  try {
    var adapter = graphClient.getRequestAdapter();
    if (adapter !== null && !gm_isBlank(adapter.getBaseUrl())) {
      baseUrl = String(adapter.getBaseUrl());
    }
  } catch (ignore) {
  }
  while (baseUrl.length > 0 && baseUrl.charAt(baseUrl.length - 1) === "/") {
    baseUrl = baseUrl.substring(0, baseUrl.length - 1);
  }
  return baseUrl;
}

function gm_normalizeSendUpdatesMode(sendUpdatesMode, defaultValue) {
  var normalized = gm_defaultString(sendUpdatesMode, gm_defaultString(defaultValue, "all")).toLowerCase();
  if (normalized === "none") {
    return "none";
  }
  if (normalized === "externalonly" || normalized === "external_only") {
    return "externalOnly";
  }
  return "all";
}

function gm_patchEventWithSendUpdates(graphClient, organizerUserId, eventId, patchEvent, sendUpdatesMode) {
  var builder = graphClient.users().byUserId(String(organizerUserId)).events().byEventId(String(eventId));
  if (gm_isBlank(sendUpdatesMode)) {
    return {
      event: builder.patch(patchEvent),
      sendUpdatesApplied: ""
    };
  }

  var appliedMode = gm_normalizeSendUpdatesMode(sendUpdatesMode, "all");
  var rawUrl = gm_getGraphBaseUrl(graphClient) +
    "/users/" + gm_urlEncode(organizerUserId) +
    "/events/" + gm_urlEncode(eventId) +
    "?sendUpdates=" + gm_urlEncode(appliedMode);

  return {
    event: builder.withUrl(rawUrl).patch(patchEvent),
    sendUpdatesApplied: appliedMode
  };
}

function gm_emailAddressToObject(emailAddress) {
  if (emailAddress === null || emailAddress === undefined) {
    return null;
  }
  return {
    address: gm_safeString(emailAddress.getAddress()),
    name: gm_safeString(emailAddress.getName())
  };
}

function gm_recipientToObject(recipient) {
  if (recipient === null || recipient === undefined) {
    return null;
  }
  return gm_emailAddressToObject(recipient.getEmailAddress());
}

function gm_attendeeToObject(attendee) {
  if (attendee === null || attendee === undefined) {
    return null;
  }
  return {
    type: gm_enumValue(attendee.getType()),
    email: gm_recipientToObject(attendee)
  };
}

function gm_attendeesToArray(attendeeList) {
  var values = [];
  if (attendeeList === null || attendeeList === undefined) {
    return values;
  }
  var i;
  for (i = 0; i < attendeeList.size(); i++) {
    var mapped = gm_attendeeToObject(attendeeList.get(i));
    if (mapped !== null) {
      values.push(mapped);
    }
  }
  return values;
}

function gm_itemBodyToObject(body) {
  if (body === null || body === undefined) {
    return null;
  }
  return {
    contentType: gm_enumValue(body.getContentType()),
    content: gm_safeString(body.getContent())
  };
}

function gm_locationToObject(location) {
  if (location === null || location === undefined) {
    return null;
  }
  return {
    displayName: gm_safeString(location.getDisplayName()),
    locationEmailAddress: gm_safeString(location.getLocationEmailAddress()),
    locationType: gm_enumValue(location.getLocationType()),
    locationUri: gm_safeString(location.getLocationUri()),
    uniqueId: gm_safeString(location.getUniqueId()),
    uniqueIdType: gm_enumValue(location.getUniqueIdType())
  };
}

function gm_onlineMeetingInfoToObject(onlineMeeting) {
  if (onlineMeeting === null || onlineMeeting === undefined) {
    return null;
  }
  return {
    conferenceId: gm_safeString(onlineMeeting.getConferenceId()),
    joinUrl: gm_safeString(onlineMeeting.getJoinUrl()),
    quickDial: gm_safeString(onlineMeeting.getQuickDial()),
    tollNumber: gm_safeString(onlineMeeting.getTollNumber())
  };
}

function gm_extensionToObject(extension) {
  if (extension === null || extension === undefined) {
    return null;
  }
  var value = {
    id: gm_safeString(extension.getId()),
    odataType: gm_safeString(extension.getOdataType()),
    additionalData: gm_extensionAdditionalDataToObject(extension.getAdditionalData())
  };
  if (gm_isGraphInstance(extension, "com.microsoft.graph.models.OpenTypeExtension")) {
    value.extensionName = gm_safeString(extension.getExtensionName());
  }
  return value;
}

function gm_extensionsToArray(extensionList) {
  var values = [];
  if (extensionList === null || extensionList === undefined) {
    return values;
  }
  var i;
  for (i = 0; i < extensionList.size(); i++) {
    var mapped = gm_extensionToObject(extensionList.get(i));
    if (mapped !== null) {
      values.push(mapped);
    }
  }
  return values;
}
