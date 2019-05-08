### Options

#### Root Name

The default name for the XML root element is ```log```.

Override that name by specifying option ```:root_name```.

@[ruby](root_name.rb)

@[xml](default_root_name.xml)

@[xml](custom_root_name.xml)

#### XML Indentation

The default XML indentation is 2 spaces.

Override that value by specifying option ```xml_indentation```.

An indentation value of ```0``` puts each line of the log at the left, with no indentation.

An indentation value of ```-1``` puts the entire log on one line, with no whitespace at all.  This format is best for logs that will be parsed in post-processing.

Note that many applications that display XML will ignore the indentation altogether, so in general it matters only when the raw XML is read (by a person) or parsed.

@[ruby](xml_indentation.rb)

@[xml](default_xml_indentation.xml)

@[xml](xml_indentation_0.xml)

@[xml](xml_indentation_-1.xml)

#### Summary

By default, the log does not have a summary: counts of total verdicts, failed verdicts, and errors.

Override that behavior by specifying option ```:summary``` as ```true```.  This causes the log to begin with a summary.

@[ruby](summary.rb)

@[xml](no_summary.xml)

@[xml](summary.xml)

#### Error Verdict

By default, the log does not have an error verdict: a generated verdict that expects the error count to be 0.

Override that behavior by specifying option ```:error_verdict``` as ```true```.  This causes the log to end with an error verdict.

This verdict may be useful when a log has errors, but no failed verdicts.

@[ruby](error_verdict.rb)

@[xml](no_error_verdict.xml)

@[xml](error_verdict.xml)

#### Backtrace Filter

By default, a backtrace omits entries containing the token ```minitest```.  This keeps the backtrace focussed on your code instead of the gems' code.

Override that behavior by specifying ioption ```:backtrace_filter``` with a ```Regexp``` object.  Entries matching that pattern will be omitted from the backtrace.

@[ruby](backtrace_filter.rb)

@[xml](default_backtrace_filter.xml)

@[xml](custom_backtrace_filter.xml)

