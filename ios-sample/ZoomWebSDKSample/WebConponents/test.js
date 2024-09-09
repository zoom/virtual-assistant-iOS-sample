
function detectWebView() {
  try {
    const userAgent = navigator.userAgent;

    // Detect iOS WebView
    const isIOSWebView = /(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/i.test(
      userAgent,
    );

    // Detect Android WebView
    const isAndroidWebView =
      /Android.*(wv|.0.0.0)/i.test(userAgent) ||
      /Version\/[\d.]+.*Chrome\/[.0-9]* Mobile/i.test(userAgent);

    // Detect Windows WebView2
    const isWindowsWebView2 =
      /wv2/i.test(userAgent) ||
      (/Edge\/\d+/i.test(userAgent) && !/Chrome/i.test(userAgent));

    // Detect macOS WebView
    const isMacOSWebView = (function () {
      // WKWebView and Legacy WebView detection
      if (
        navigator.platform === "MacIntel" &&
        window?.webkit &&
        window?.webkit.messageHandlers
      ) {
        return true; // WKWebView
      }
      return false;
    })();

    // Detect other WebViews
    const isStandalone = (window.navigator)?.standalone;
    const isPWA = window.matchMedia("(display-mode: standalone)").matches;

    if (isIOSWebView) {
      return "iOS WebView";
    } else if (isAndroidWebView) {
      return "Android WebView";
    } else if (isWindowsWebView2) {
      return "Windows WebView2";
    } else if (isMacOSWebView) {
      return "macOS WebView";
    } else if (isStandalone || isPWA) {
      return "PWA";
    } else {
      return "Browser";
    }
  } catch (e) {
    return "N/A";
  }
}


function CurrentUserAgent() {
    return navigator.userAgent;
}

