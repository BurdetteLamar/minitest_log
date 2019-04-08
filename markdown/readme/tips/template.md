## Tips

### Avoid Failure Clutter

Use verdict return values to omit verdicts that would definitely fail.  This can greatly simplify your test results.

In the example below, the test attempts to create a user.  If the that succeeds, the test then attempts to further validate the user.

However, if the create fails, there's no point in cluttering the log with more (and redundant) failures, so the test puts code into a conditional:

```ruby
user_name = 'Bill Jones'
user = SomeApi.create_user(user_name)
if log.verdict_assert_equal?(
  :user_created, # Verdict id.
  user_name,     # Expected user name.
  user.name,     # Actual user name.
  )
  log.verdict_assert_match
  SomeApi.delete_user(user.id)
end

```
