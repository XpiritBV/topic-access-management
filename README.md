# Team Permissions Topic Action

This repository contains a GitHub Action that can be used to manage team permissions on a repository, based on a combination of a configuration file and the [topics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics) applied to a repository.

Configuration is simple. The action reads a YAML configuration file (`teams.yml`) from this repository, and then applies the permissions defined in the configuration to any team that matches the topic of the repository.


## Setup and Usage

To use this action, simply clone this repository into your destination environment and configure the following repository secrets:

- `GITHUB_TOKEN`: A GitHub token with the necessary permissions to manage teams and repositories in your organization.

Then, update the `teams.yml` file to match your desired configuration. The action will automatically apply the permissions defined in the configuration to any team that matches the topic of the repository.

```yaml
# A prefix for access-specific topics
prefix: "iam-"
teams:
  # In the configuration below, a GitHub team with the slug "example-github-team"
  # will be granted push permissions on any repository with the topic "iam-example"
  # applied to it.
  example-github-team:
    topic: example
    permission: push # One of: admin, maintain, push, triage, pull
  another-example-team:
    topic: another
    permission: maintain
  # ...
```

## Features

- Manage team permissions based on repository topics
- Simple configuration
- No need to manually modify repository settings
- Automatically remediates incorrect permissions for teams collaborating on a repository
- Adjusting teams.yml will apply the updated permissions to your entire environment