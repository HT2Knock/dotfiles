import AppKit
import ApplicationServices

// Chromium keeps its accessibility tree off until something asks for the
// enhanced user interface. No hints are found in such an app before that
// request. Setting the attribute on the application element turns the tree
// on. Chromium answers "not implemented" when it did the work, so the result
// code carries no meaning here.
//
// Usage: warm-ax <bundle-id>

guard CommandLine.arguments.count > 1 else {
    FileHandle.standardError.write(Data("usage: warm-ax <bundle-id>\n".utf8))
    exit(2)
}

let bundleID = CommandLine.arguments[1]

guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first else {
    // The app is not running, so there is nothing to warm.
    exit(0)
}

let axApp = AXUIElementCreateApplication(app.processIdentifier)
_ = AXUIElementSetAttributeValue(axApp, "AXEnhancedUserInterface" as CFString, kCFBooleanTrue)
