## Verdicts

Use ```MinitestLog``` verdicts to log details of ```Minitest``` assertions.

Each verdict method in ```MinitestLog``` is a wrapper for a corresponding ```Minitest``` assertion (or refutation).

The wrapping verdict logs all details for the wrapped assertion.

The arguments for the verdict method and its assert method are the same, except that the verdict method adds a required leading verdict identifier.  (Both allow an optional trailing message string.)

The verdict identifier:
- Is commonly a string or a symbol, but may be any object that responds to ```:to_s```.
- Must be unique among the verdict identifiers in its *test method* (but not necessarily in its *test class*.)

Example verdict:

```ruby
log.verdict_assert?(:my_verdict_id, true, 'My message')
```

Each verdict method returns ```true``` or ```false``` to indicate whether the verdict succeeded or failed.

@[:markdown](assert/template.md)

@[:markdown](refute/template.md)

