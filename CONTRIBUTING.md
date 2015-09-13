# Contributing

## Reporting issues

We would love to help if you are having a problem. Feel free to open an issue. We ask that you please provide as much detail as possible.

## Contributing code

Contributions are encouraged through GitHub Pull Requests.

Guidelines when adding new code:

* Create tests when possible.
* Ensure the entire test suite still passes by running `rake`.
* Ensure code conventions are maintained by running `rubocop`.

### Adding validations

To submit your own validation:

* Create your new validation class in `lib/fit_commit/validators/`.
* Add an entry to the default config settings in `fit_commit.default.yml`. If it's a feature not everyone will want by default, set `Enabled: false`.
* Create a unit test in `test/unit/validators/`.
* Update the config defaults & validation descriptions in the README.
