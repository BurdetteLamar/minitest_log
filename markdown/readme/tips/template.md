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

In the example below, the test attempts to create a user.  If the that succeeds, the test then further validates, then deletes the user.

However, if the create fails, there's no point in cluttering the log with more (and redundant) failures, so the test puts code into a conditional:

```ruby
user_name = 'Bill Jones'
user = SomeApi.create_user(user_name)
if log.verdict_refute_nil?(:user_created, user)
  log.verdict_assert_equal?(:user_name, user_name, user.name)
  SomeApi.delete_user(user.id)
end

```
