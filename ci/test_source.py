"""Check assessment requirements and executable JavaScript without extra Python packages."""
from html.parser import HTMLParser
from pathlib import Path
import json
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent

class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tags = []
        self.scripts = []
        self.in_script = False
    def handle_starttag(self, tag, attrs):
        self.tags.append((tag, dict(attrs)))
        if tag == "script":
            self.in_script = True
            self.scripts.append("")
    def handle_endtag(self, tag):
        if tag == "script":
            self.in_script = False
    def handle_data(self, data):
        if self.in_script:
            self.scripts[-1] += data

for name, replicas, port in [
    ("q1-notice-board", 2, 30001),
    ("q2-student-feedback", 3, 30002),
    ("q3-placement-portal", 3, 30003),
]:
    directory = ROOT / name
    text = (directory / "index.html").read_text(encoding="utf-8")
    page = Page()
    page.feed(text)
    assert any(tag == "html" and attrs.get("lang") == "en" for tag, attrs in page.tags)
    assert any(tag == "meta" and attrs.get("name") == "viewport" for tag, attrs in page.tags)
    for token in json.loads((directory / "test-config.json").read_text())["tokens"]:
        assert token in text, (name, token)
    manifest = (directory / "deployment.yaml").read_text()
    assert f"replicas: {replicas}" in manifest
    assert f"nodePort: {port}" in manifest
    assert "type: NodePort" in manifest
    assert "alert(" not in text, "Blocking/fake success alert found"
    if name.startswith("q1"):
        assert sum(tag == "article" for tag, _ in page.tags) >= 3
        assert sum(tag == "time" and bool(attrs.get("datetime")) for tag, attrs in page.tags) >= 3
    if name.startswith("q2"):
        for field in ["courseName", "facultyName", "studentName", "regNo", "department", "comments"]:
            assert any(attrs.get("id") == field and "required" in attrs for _, attrs in page.tags), field
            assert any(tag == "label" and attrs.get("for") == field for tag, attrs in page.tags), field
        ratings = {attrs.get("value") for tag, attrs in page.tags if tag == "input" and attrs.get("name") == "rating"}
        assert ratings == {"1", "2", "3", "4", "5"}
    for script in page.scripts:
        with tempfile.TemporaryDirectory() as temp:
            source = Path(temp) / "check.js"
            source.write_text(script, encoding="utf-8")
            subprocess.run(["node", "--check", str(source)], check=True)
    print(f"PASS {name}: required content, HTML semantics, JavaScript syntax, replicas and NodePort")
