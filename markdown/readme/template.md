# MinitestLog

Class ```MinitestLog``` is a wrapper for class ```Minitest::Assertions``` that:

- Automatically and fully logs each assertion, whether passing or failingg.
- Allows a test to be structured as nested sections.

Here, we say *verdict*, not *assertion*, to emphasize that a failure does not terminate the test.

Se, we have:
 
- **Verdicts**:
  - All verdicts are automatically logged.
  - Verdicts for certain collections are closely analyzed (e.g., ```Hash```, ```Sets```).
- **Sections** that can have:
  - Nested subsections
  - Verdicts
  - Text
  - Attributes
  - Duration
  - Timestamp
  - Rescuing
  - Comments

@[:markdown](verdicts/template.md)

@[:markdown](sections/template.md)



