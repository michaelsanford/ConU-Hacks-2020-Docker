import http.server
import socketserver
from http import HTTPStatus


class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        print("Request received!")
        self.send_response(HTTPStatus.OK)
        self.end_headers()
        self.wfile.write(b'Hello ConU 2020!')


httpd = socketserver.TCPServer(('', 8080), Handler)
httpd.serve_forever()
