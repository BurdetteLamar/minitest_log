## Verdicts

Use ```MinitestLog``` verdict methods to log details of ```Minitest``` assertions.

Each verdict method in ```MinitestLog``` is a wrapper for a corresponding ```Minitest``` assertion (or refutation).

The verdict method logs all details for the assertion.

The arguments for the verdict method and its assert method are the same, except that the verdict method adds a required leading verdict identifier.  (Both allow an optional trailing message string.)

The verdict identifier:
- Is commonly a string or a symbol, but may be any object that responds to ```:to_s```.
- Must be unique among the verdict identifiers in its *test method* (but not necessarily in its *test class*.)

Each verdict method returns ```true``` or ```false``` to indicate whether the verdict succeeded or failed.

Each verdict method also has a shorter alias -- ```va``` substituting for ```verdict_assert```, and ```vr``` substituting for ```verdict_refute```.  (This not only saves keystrokes, but also *really*, *really* helps your editor do code completion.)

Example verdict (long form and alias):

```ruby
log.verdict_assert?(:my_verdict_id, true, 'My message')
log.va?(:my_verdict_id, true, 'My message')
```

Verdict methods are described below.  For each, the following is given:

- The method's syntax.
- An example test using the method, including both passing and failing verdicts.
- The log output by the example test.
- Descriptive text, adapted from [docs.ruby-lang.org](https://docs.ruby-lang.org/en/2.1.0/MiniTest/Assertions.html)

@[:markdown](assert/template.md)

@[:markdown](refute/template.md)

