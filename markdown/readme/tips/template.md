## Tips

### Use Short Verdict Aliases

Use the short alias for a verdict method, to:

- Have less source code.
- Allow code-completion to work *much* better (completion select list gets shorter *much* sooner).

Examples:

- ```log.va_equal?```, not ```log.verdict assert_equal?```.
- ```log.vr_empty?```, not ```log.verdict_refute_empty?```.

### Avoid Failure Clutter

Use verdict return values (```true```/```false```) to omit verdicts that would definitely fail.  This can greatly simplify your test results.

In the example below, the test attempts to create a user.  If the create succeeds, the test further validates, then deletes the user.

However, if the create fails, the test does not attempt to validate or delete the user (which attempts would fail, and might raise exceptions).

Thus, assuming a failed create returns ```nil```:

```ruby
user_name = 'Bill Jones'
user = SomeApi.create_user(user_name)
if log.verdict_refute_nil?(:user_created, user)
  log.verdict_assert_equal?(:user_name, user_name, user.name)
  SomeApi.delete_user(user.id)
end
```

### Facilitate Post-Processing

If your logs will be parsed in post-processing, you can make that go smoother by creating the logs with certain options:

- ```xml_indentation => -1```:  so that there's no log-generated whitespace.  (But you'll still see the same indented display in your browser.)
- ```:summary => true```:  so that the counts are already computed.
- ```:error_verdict => true```: so that a log that has errors will also have at least one failed verdict.

See [Options](#options)
