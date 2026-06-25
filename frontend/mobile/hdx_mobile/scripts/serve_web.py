#!/usr/bin/env python3
"""Serve Flutter web build with SPA fallback (all routes -> index.html)."""

from __future__ import annotations

import argparse
import os
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path


class SPARequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, directory: str | None = None, **kwargs):
        super().__init__(*args, directory=directory, **kwargs)

    def do_GET(self):
        requested = self.translate_path(self.path.split('?', 1)[0])
        if requested.endswith(os.sep):
            requested = requested.rstrip(os.sep)
        if not os.path.isfile(requested):
            self.path = '/index.html'
        return super().do_GET()

    def log_message(self, format: str, *args) -> None:
        if args and str(args[0]).startswith('GET /index.html'):
            path = args[0].split(' ', 1)[0]
            if path != 'GET /index.html':
                super().log_message('GET %s -> index.html (SPA)', path)
                return
        super().log_message(format, *args)


def main() -> None:
    parser = argparse.ArgumentParser(description='Serve Flutter web (SPA fallback)')
    parser.add_argument('--port', type=int, default=8080)
    parser.add_argument(
        '--dir',
        type=Path,
        default=Path(__file__).resolve().parent.parent / 'build' / 'web',
        help='Path to build/web output',
    )
    args = parser.parse_args()
    web_dir = args.dir.resolve()
    if not web_dir.is_dir():
        raise SystemExit(f'Web build not found: {web_dir}\nRun: flutter build web --release')

    os.chdir(web_dir)
    server = ThreadingHTTPServer(('0.0.0.0', args.port), SPARequestHandler)
    print(f'Serving {web_dir} on http://127.0.0.1:{args.port} (SPA mode)')
    server.serve_forever()


if __name__ == '__main__':
    main()
