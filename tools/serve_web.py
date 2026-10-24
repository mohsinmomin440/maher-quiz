import http.server
import socketserver
import os
import sys

PORT = 8080
DIRECTORY = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'build', 'web'))

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache')
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

Handler.extensions_map.update({
    '.wasm': 'application/wasm',
    '.js': 'application/javascript',
    '.json': 'application/json',
})

print(f"Serving Maher Quiz App from: {DIRECTORY}")
print(f"Listening on http://localhost:{PORT}")
sys.stdout.flush()

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
