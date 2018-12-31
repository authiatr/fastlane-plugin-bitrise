# bitrise plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-bitrise)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-bitrise`, add it to your project by running:

```bash
fastlane add_plugin bitrise
```

## About bitrise

This plugin allow you to trigger a specific Bitrise workflow with some arguments with a HTTPS POST request on the Bitrise.io API.

It also allow you to override some environments variables.

It can help you to automatically trigger a build after a bump commit for instance without have to log into bitrise.io. 

## Options

| Option | Description | Type | Requirement | Environment Variable |
| --- | --- | :---: | :---: | --- |
| `app_slug` | Bitrise application slug, avalaible on bitrise.io > your app > code | String | **Mandatory** | `BITRISE_APP_SLUG` |
| `trigger_token` | Bitrise build trigger token, avalaible on bitrise.io > your app > code | String | **Mandatory** | `BITRISE_TRIGGER_TOKEN` |
| `workflow` | Bitrise workflow to trigger, if not specified, it'll trigger the default one | String | Optional | `BITRISE_WORKFLOW` |
| `author` | Desribe who triggered the build. It'll appear on the Bitrise.io build | String | Optional | `BITRISE_AUTHOR` |
| `build_message` | Build message who'll appear on the Bitrise.io build | String | Optional | `BITRISE_BUILD_MESSAGE` |
| `branch` | The git branch to build | String | Optional | `BITRISE_GIT_BRANCH` |
| `commit` | The git commit hash to build | String | Optional | `BITRISE_GIT_COMMIT` |
| `tag` | The git Tag to build | String | Optional | `BITRISE_GIT_TAG` |
| `environments` | Bitrise environments to replace, it'll override the previous environment variables specified. The Hash key has to be the environment variable key (without the `$`), the Hash value has to be environment variable value | Hash | Optional | `BITRISE_ENVIRONMENTS` |

## Return values

The `bitrise` plugin return a Hash containing the bitrise build informations return by the API. 

| Hash key | Description |
| --- | --- |
| `build_number` | Bitrise build number |
| `build_url` | Bitrise build url |

If an error is return by the bitrise.io API, the plugin will **throw an exception**. 

## Examples

To trigger the default workflow set on Bitrise.io on the default git branch execute:
```
bitrise(
    "app_slug": "YOUR_APP_SLUG",
    "trigger_token": "YOUR_TRIGGER_TOKEN"
)
```

To trigger a build with a specific workflow, a specific git branch, display a build message, the build author and override some environments variables execute the following command:
```
bitrise(
    "app_slug": "YOUR_APP_SLUG",
    "trigger_token": "YOUR_TRIGGER_TOKEN",
    "workflow": "Beta",
    "author": "Developer",
    "build_message": "Deploy build version 1.3.2 build number 11 to Beta test",
    "branch": "release/1.3.2",
    "environments": {
        "BUILD_CONFIGURATION" => "Production",        # Environment variable to override during Bitrise.io build
        "ANOTHER_ENVIRONMENT_VARIABLE" => "123456"    # Environment variable to override during Bitrise.io build
    }
)
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, **please submit it to this repository**.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## Author
Robin Authiat, [@authiat_robin](https://twitter.com/authiat_robin)

I'm available for freelance work (Fastlane Continuous Delivery, Continuous Integration and iOS development). Feel free to contact me 🚀