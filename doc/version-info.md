# Version Information

This document explains how the version information for the Migration Planner UI application can be accessed.

## Overview

The Migration Planner UI exposes comprehensive version information through the browser console and window object. This includes:

1. **UI Version**: Migration Planner UI version name and git commit
2. **API Version**: Migration Planner API version name and git commit (fetched from `/api/migration-assessment/info` endpoint)
3. **Build Information**: Build timestamp

## Accessing Version Information

### Method 1: Browser Console (Automatic)

When the application loads, version information is automatically logged to the browser console. Note that API version information is fetched asynchronously from the `/api/migration-assessment/info` endpoint:

```
Migration Planner Version Information:
**  migration-planner-ui-app :
    - Version Name: 1.0.0
    - Git Commit: abc123def456...
**  migration-planner :
    - Version Name: 1.2.3
    - Git Commit: def789abc123...
**  Build Time: 2025-09-17T10:30:15.123Z
**  Access via: window.__MIGRATION_PLANNER_VERSION__
```

### Method 2: Window Object (Programmatic Access)

Developers can access version information programmatically via the global window object:

```javascript
// Access the complete version object
const versionInfo = window.__MIGRATION_PLANNER_VERSION__;

console.log('UI Version:', versionInfo.ui.versionName);
console.log('UI Git Commit:', versionInfo.ui.gitCommit);
console.log('API Version:', versionInfo.api.versionName);
console.log('API Git Commit:', versionInfo.api.gitCommit);
console.log('Build Time:', versionInfo.buildTime);
```

### Method 3: Import in Code

For use within the application code:

```typescript
import { getVersionInfo, logVersionInfo } from './common/version';

// Get version info object
const versionInfo = getVersionInfo();

// Log version info to console
logVersionInfo();
```

## Version Information Structure

The version information object has the following structure:

```typescript
interface VersionInfo {
  ui: {
    name: string;        // "migration-planner-ui-app"
    versionName: string; // UI version from package.json or MIGRATION_PLANNER_UI_VERSION
    gitCommit: string;   // Git commit hash
  };
  api: {
    name: string;        // "migration-planner"
    versionName: string; // API version from API info endpoint
    gitCommit: string;   // API git commit hash (from API)
  };
  buildTime: string;     // ISO timestamp of build
}
```

## Environment Variables

The following environment variables control version information during build:

- `MIGRATION_PLANNER_UI_VERSION`: Override UI version (defaults to package.json version or "unknown")
- `MIGRATION_PLANNER_UI_GIT_COMMIT`: Git commit hash (defaults to "unknown" if not set)
- `MIGRATION_PLANNER_UI_BUILD_TIME`: Build timestamp (defaults to "unknown" if not set)

### Default Values

When environment variables are not provided:
- **MIGRATION_PLANNER_UI_GIT_COMMIT**: `"unknown"` - indicates git commit was not provided during build
- **MIGRATION_PLANNER_UI_BUILD_TIME**: `"unknown"` - indicates build time was not provided during build
- **MIGRATION_PLANNER_UI_VERSION**: Uses version from `package.json` or "unknown"
- **API_VERSION**: Fetched from API info endpoint or "unknown"

## Build Integration

Version information is automatically injected during build processes:

### Standalone Build
```bash
make build-standalone
```

### Federated Build
```bash
make build
```

Both builds will:
1. Use `MIGRATION_PLANNER_UI_GIT_COMMIT` environment variable (or "unknown" if not set)
2. Use `MIGRATION_PLANNER_UI_BUILD_TIME` environment variable (or "unknown" if not set)
3. Use `MIGRATION_PLANNER_UI_VERSION` environment variable (or package.json version if not set)
4. Inject these values into the application
