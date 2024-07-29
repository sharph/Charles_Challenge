import os
import socket
import ssl
import unittest
import urllib
import urllib.request


class TestWebservice(unittest.TestCase):
    URL = ""

    def setUp(self):
        self.ctx = ssl.create_default_context()
        self.ctx.check_hostname = False
        self.ctx.verify_mode = ssl.CERT_NONE

    def test_hello_world_available(self):
        res = urllib.request.urlopen(self.URL, timeout=10, context=self.ctx)
        self.assertIn(b"Hello World!", res.read())

    def test_http_redirects_to_https(self):
        assert self.URL.startswith("https://")
        http = f"http://{self.URL[8:]}"
        res = urllib.request.urlopen(http, timeout=10, context=self.ctx)
        self.assertTrue(res.geturl().startswith("https://"))

    def test_non_http_timesout(self):
        assert self.URL.startswith("https://")
        with self.assertRaises(TimeoutError):
            host = self.URL.split("/")[2]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(2)
            s.connect((host, 1234))
        s.close()


def main():
    TestWebservice.URL = os.getenv("URL")
    unittest.main()


if __name__ == "__main__":
    main()
