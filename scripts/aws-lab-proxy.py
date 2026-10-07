"""Temporary loopback CONNECT relay for AWS CLI/TF when Windows DNS fails.

Run in Ubuntu WSL. TLS stays end-to-end; this does not install a certificate,
log credentials, alter Windows DNS, or accept non-AWS destinations.
"""
import select
import socket
import socketserver


class Relay(socketserver.StreamRequestHandler):
    def handle(self):
        line = self.rfile.readline(8192).decode("ascii", "replace").strip()
        parts = line.split()
        if len(parts) != 3 or parts[0] != "CONNECT":
            self.wfile.write(b"HTTP/1.1 405 Method Not Allowed\r\n\r\n")
            return
        host, separator, port = parts[1].rpartition(":")
        if not separator or port != "443" or not host.endswith(".amazonaws.com"):
            self.wfile.write(b"HTTP/1.1 403 Forbidden\r\n\r\n")
            return
        while self.rfile.readline(8192) not in (b"\r\n", b"\n", b""):
            pass
        try:
            upstream = socket.create_connection((host, 443), timeout=20)
        except OSError:
            self.wfile.write(b"HTTP/1.1 502 Bad Gateway\r\n\r\n")
            return
        with upstream:
            self.wfile.write(b"HTTP/1.1 200 Connection Established\r\n\r\n")
            self.wfile.flush()
            sockets = [self.connection, upstream]
            while True:
                readable, _, _ = select.select(sockets, [], [], 120)
                if not readable:
                    return
                for source in readable:
                    data = source.recv(65536)
                    if not data:
                        return
                    destination = upstream if source is self.connection else self.connection
                    destination.sendall(data)


class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


with Server(("127.0.0.1", 18081), Relay) as server:
    print("AWS-only lab relay listening on loopback port 18081", flush=True)
    server.serve_forever()
