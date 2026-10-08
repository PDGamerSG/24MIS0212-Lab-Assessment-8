"""Functional and responsive checks for the live Kubernetes webpages."""
import argparse
import json
from pathlib import Path
from playwright.sync_api import sync_playwright

parser = argparse.ArgumentParser()
parser.add_argument("--question", type=int, choices=[1, 2, 3], required=True)
parser.add_argument("--version", default="final")
args = parser.parse_args()
root = Path(__file__).resolve().parent.parent
output = root / "evidence" / "browser"
output.mkdir(parents=True, exist_ok=True)
script = (root / "ci" / "browser-tests.js").read_text(encoding="utf-8")
results = []
with sync_playwright() as playwright:
    browser = playwright.chromium.launch(headless=True)
    page = browser.new_page()
    for width in [1280, 375]:
        page.set_viewport_size({"width": width, "height": 900})
        page_errors = []
        page.on("pageerror", lambda error: page_errors.append(str(error)))
        page.goto(f"http://localhost:{30000 + args.question}", wait_until="networkidle")
        result = page.evaluate("async () => {" + script + "; return await runAssessmentBrowserTests(); }")
        assert not page_errors, page_errors
        result["version"] = args.version
        results.append(result)
        if args.question == 2:
            page.reload(wait_until="networkidle")
            # The test restores storage, so the final summary must return to its empty state.
            summary = page.locator("#ratingSummary")
            if summary.count():
                assert "No feedback yet" in summary.inner_text()
                for field, value in {
                    "courseName": "Agile Development",
                    "facultyName": "Demo Faculty",
                    "studentName": "Test Student",
                    "regNo": "TEST002",
                    "comments": "Persistence test",
                }.items():
                    page.locator("#" + field).fill(value)
                page.locator("#department").select_option(label="SCOPE")
                page.locator('input[name="rating"][value="4"]').check()
                page.get_by_role("button", name="Submit Feedback").click()
                assert "1 response(s)" in summary.inner_text()
                assert "4.0/5" in summary.inner_text()
                page.reload(wait_until="networkidle")
                assert "4.0/5" in page.locator("#ratingSummary").inner_text()
                result["results"].append("PASS: Rating calculation and persistence after reload")
                page.evaluate("localStorage.removeItem('assessment8-feedback')")
                page.reload(wait_until="networkidle")
        page.screenshot(path=str(output / f"q{args.question}-{args.version}-{width}.png"), full_page=True)
        print(f"PASS Q{args.question} {args.version} at {width}px: {len(result['results'])} functional checks")
    browser.close()
(output / f"q{args.question}-{args.version}.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
