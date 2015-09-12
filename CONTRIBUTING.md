# Contributing

## Reporting issues

We would love to help if you are having a problem. Feel free to open an issue. We ask that you please provide as much detail as possible.

## Contributing code

Contributions are encouraged through GitHub Pull Requests.

### Adding validations

To submit your own validation:

- Create your new validation class in `lib/fit_commit/validators/`.
- Add an entry to the default config settings in `fit_commit.default.yml`. If it's a feature not everyone will want by default, `Enabled` should be `false`.
- Create unit tests. Ensure the entire test suite still passes (`rake`).
- Update the config defaults & validation descriptions in the README.
