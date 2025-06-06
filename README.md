# http_sandbox_viewer

A developer-friendly HTTP request/response viewer for Flutter apps.  
**Easily inspect, modify, and re-send Dio + Retrofit requests from an in-app dashboard.**

> Inspired by [drift_db_viewer](https://pub.dev/packages/drift_db_viewer)

---

## ✨ Features

- 📡 Capture HTTP requests/responses via Dio interceptor  
- 🧪 View request headers, body, and status  
- 🔁 Re-execute any request with editable parameters  
- 🧭 Simple in-app dashboard UI — no external tools required  
- 🚫 No additional dependencies required for users  

---

## 🚀 Getting Started

### 1. Add dependency

```yaml
dependencies:
  http_sandbox_viewer:

Note: No need to add flutter_hooks or other dependencies — it’s all bundled!

⸻

2. Setup in Dio

final httpLogInterceptor = HttpLogInterceptor();

final dio = Dio()..interceptors.add(httpLogInterceptor);


⸻

3. Open the dashboard

Anywhere in your app:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const HttpDashboardViewer(),
  ),
);


⸻

📷 Screenshots (Coming Soon)

Request List Detail View Re-send
(WIP) (WIP) (WIP)


⸻

🔧 Planned Features
 • Support for http and chopper
 • Export logs as JSON
 • Request “favorites” and presets
 • Timeline view with status color indicators

⸻

🧪 Example Project

An example app using Dio + Retrofit is available in the /example directory.

⸻

MIT License © 2025 [Pregum ]
