## Have an issue?

Before opening an issue, try the following:

##### Consult the documentation

See if your issue can be resolved by information in the documentation.

TBD

##### Check for an existing issue

Take a look at the issues to see if a similar one has already been created. If
one exists, please add any additional information that might expedite
resolution.

#### Open an issue

If the documentation wasn't able to help resolve the issue and no issue already
exists, please open a new issue with the following in mind:

- Please make sure only to include one issue per report. If you encounter
  multiple, unrelated issues, please report them as such.
- Be detailed. Provide backtraces and example code when possible. Provide
  information about your environment. e.g., Ruby version, rails version, etc.
- Own your issue. Actively participate in the discussion and help drive the
  issue to closure.
- If you resolve your own issue, please share the details on the issue and close
  it out. Others might have the same issue and sharing solutions is helpful.

## Contributing

Contributing can be done in many ways and is not exclusive to code. If you have
thoughts on a particular issue or feature, we encourage you to open new issues
for discussion or add your comments to existing ones.

#### Pull requests

We also gladly welcome pull requests. When preparing to work on pull request,
please adhere to these standards:

- Base work on the master branch unless fixing an issue with
  [0.10-stable](https://github.com/rails-api/active_model_serializers/tree/0-10-stable)
  or
  [0.9-stable](https://github.com/rails-api/active_model_serializers/tree/0-9-stable)
  or
  [0.8-stable](https://github.com/rails-api/active_model_serializers/tree/0-8-stable)
- Squash your commits and regularly rebase off master.
- Provide a description of the changes contained in the pull request.
- Note any specific areas that should be reviewed.
- Include tests.
- The test suite must pass on [supported Ruby versions](.travis.yml)
- Include updates to the [documentation](https://github.com/rails-api/active_model_serializers/tree/master/docs)
  where applicable.
- Update the
  [CHANGELOG](https://github.com/rails-api/active_model_serializers/blob/master/CHANGELOG.md)
  to the appropriate sections with a brief description of the changes.
- Do not change the VERSION file.

#### Running tests

Run all tests

`$ rake test`

Run a single test suite

`$ rake test TEST=path/to/test.rb`

Run a single test

`$ rake test TEST=path/to/test.rb TESTOPTS="--name=test_something"`
