async function runAssessmentBrowserTests() {
  const results = [];
  function check(condition, message) {
    if (!condition) throw new Error(message);
    results.push("PASS: " + message);
  }
  check(document.documentElement.lang === "en", "Page language");
  check(document.querySelector("h1"), "Page heading");
  check(
    document.documentElement.scrollWidth <= innerWidth + 1,
    "No horizontal overflow",
  );
  const text = document.body.innerText;
  if (text.includes("College Notice Board")) {
    check(
      document.querySelectorAll("article.notice").length >= 3,
      "At least three notices",
    );
    check(
      document.querySelectorAll("time[datetime]").length >= 3,
      "Dated notices",
    );
    check(
      text.includes("College:") &&
        text.includes("Department:") &&
        text.includes("Contact:"),
      "College, department and contact",
    );
  } else if (text.includes("Student Feedback")) {
    const key = "assessment8-feedback",
      previous = localStorage.getItem(key);
    try {
      localStorage.removeItem(key);
      const form = document.getElementById("feedbackForm");
      form.reset();
      check(!form.checkValidity(), "Blank required fields reject submission");
      const before = localStorage.getItem(key);
      form.requestSubmit();
      check(
        localStorage.getItem(key) === before,
        "Invalid form does not save a record",
      );
      for (const [id, value] of Object.entries({
        courseName: "Agile Development",
        facultyName: "Demo Faculty",
        studentName: "Test Student",
        regNo: "TEST001",
        department: "SCOPE",
        comments: "Containers and Kubernetes lab feedback",
      }))
        document.getElementById(id).value = value;
      document.querySelector('input[name=rating][value="5"]').checked = true;
      check(form.checkValidity(), "Completed feedback form validates");
      const countBefore = JSON.parse(localStorage.getItem(key) || "[]").length;
      form.requestSubmit();
      const saved = JSON.parse(localStorage.getItem(key) || "[]");
      check(saved.length === countBefore + 1, "One feedback record saved");
      check(
        saved[saved.length - 1].rating === 5 &&
          saved[saved.length - 1].regNo === "TEST001",
        "Feedback data saved correctly",
      );
      check(
        document.getElementById("status").textContent.includes("saved"),
        "Visible save confirmation",
      );
      check(
        document.getElementById("studentName").value === "",
        "Form resets after submission",
      );
      if (document.getElementById("ratingSummary")) {
        check(
          document
            .getElementById("ratingSummary")
            .textContent.includes("Average course rating:"),
          "Computed rating summary",
        );
        check(
          document.getElementById("status").textContent.includes("Thank you"),
          "Thank-you update",
        );
      }
    } finally {
      if (previous === null) localStorage.removeItem(key);
      else localStorage.setItem(key, previous);
    }
  } else if (text.includes("College Placement Portal")) {
    const cards = [...document.querySelectorAll("article.job")];
    check(cards.length >= 2, "Placement companies listed");
    check(
      cards.every((card) =>
        [
          "Job role:",
          "Eligibility:",
          "Package:",
          "Application Deadline:",
        ].every((field) => card.innerText.includes(field)),
      ),
      "Each job has all required details",
    );
    check(
      cards.every((card) =>
        card.querySelector('a[href^="mailto:placements@example.com"]'),
      ),
      "Placement contact links",
    );
    if (cards.length === 3)
      check(
        cards.some((card) => card.querySelector("h2").textContent === "Google"),
        "Updated Google opportunity",
      );
  }
  return {
    url: location.href,
    title: document.title,
    viewport: { width: innerWidth, height: innerHeight },
    results,
  };
}
