"""
render_excalidraw.py — Render an .excalidraw file to PNG using Playwright.

Usage:
    uv run python render_excalidraw.py <path-to-file.excalidraw>

First-time setup:
    uv sync
    uv run playwright install chromium

Output: PNG saved next to the input .excalidraw file.
"""

import asyncio
import json
import sys
import threading
import http.server
import functools
from pathlib import Path

try:
    from playwright.async_api import async_playwright
except ImportError:
    print("Playwright not installed. Run: uv sync && uv run playwright install chromium")
    sys.exit(1)


HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: #ffffff; }
  canvas { display: block; }
</style>
</head>
<body>
<script type="module">
  import { exportToCanvas } from "https://esm.sh/@excalidraw/excalidraw";

  const data = __EXCALIDRAW_DATA__;

  try {
    await document.fonts.ready;
    const canvas = await exportToCanvas({
      elements: data.elements,
      appState: {
        ...data.appState,
        exportWithDarkMode: false,
        exportBackground: true,
        exportPadding: 40,
      },
      files: data.files || {},
      getDimensions: (w, h) => ({ width: w * 2, height: h * 2, scale: 2 }),
    });
    document.body.appendChild(canvas);
    document.title = "READY";
  } catch(e) {
    document.title = "ERROR:" + e.message;
  }
</script>
</body>
</html>"""


def start_server(directory: Path, port: int):
    handler = functools.partial(
        http.server.SimpleHTTPRequestHandler,
        directory=str(directory)
    )
    server = http.server.HTTPServer(("127.0.0.1", port), handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server


async def render(excalidraw_path: Path) -> Path:
    data = json.loads(excalidraw_path.read_text(encoding="utf-8"))
    html = HTML_TEMPLATE.replace("__EXCALIDRAW_DATA__", json.dumps(data))

    html_filename = excalidraw_path.stem + ".tmp.html"
    html_path = excalidraw_path.parent / html_filename
    html_path.write_text(html, encoding="utf-8")

    output_path = excalidraw_path.with_suffix(".png")

    port = 18734
    server = start_server(excalidraw_path.parent, port)

    try:
        async with async_playwright() as p:
            browser = await p.chromium.launch()
            page = await browser.new_page(viewport={"width": 400, "height": 400})
            await page.goto(f"http://127.0.0.1:{port}/{html_filename}")
            await page.wait_for_function(
                "document.title.startsWith('READY') || document.title.startsWith('ERROR')",
                timeout=30000
            )
            title = await page.title()
            if title.startswith("ERROR"):
                raise RuntimeError(f"Render failed: {title}")
            # Resize viewport to match actual canvas dimensions
            size = await page.evaluate(
                "() => ({ w: document.querySelector('canvas').width, h: document.querySelector('canvas').height })"
            )
            await page.set_viewport_size({"width": size["w"], "height": size["h"]})
            await page.screenshot(path=str(output_path), full_page=False)
            await browser.close()
    finally:
        server.shutdown()
        html_path.unlink(missing_ok=True)

    print(f"Rendered: {output_path}")
    return output_path


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: uv run python {sys.argv[0]} <file.excalidraw>")
        sys.exit(1)

    path = Path(sys.argv[1]).resolve()
    if not path.exists():
        print(f"File not found: {path}")
        sys.exit(1)

    asyncio.run(render(path))
