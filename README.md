# project-beta-automations

This repository provides the ability to automate GitHub issues and pull requests for [Github Projects (Beta)](https://docs.github.com/en/issues/trying-out-the-new-projects-experience/about-projects). 

It is based on https://github.com/leonsteinhaeuser/project-beta-automations

This action is designed to REMOVE issues or PRs from a project (e.g. when closed)

Note: GITHUB_TOKEN does not have the necessary scopes to access projects (beta).
You must create a token with ***org:write*** scope and save it as a secret in your repository or organization.
For more information, see [Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).


## Variables

| Variable           | Required | Description |
| ------------------ | -------- |----------- |
| `gh_token`         | true     | The GitHub token to use for the automation. |
| `user`             | false    | The GitHub username that owns the projectboard. Either a user or an organization must be specified. |
| `organization`     | false    | The GitHub organization that owns the projectboard. Either a user or an organization must be specified. |
| `project_id`       | true     | The projectboard id. |
| `resource_node_id` | true     | The id of the resource node. |

## Example config


The resulting workflow file is defined as follows:

```yaml
name: Remove issue from project when closed
on:
  issues:
    types:
      - closed
  pull_request:
    types:
      - closed
jobs:
  issue_closed:
    name: issue_closed
    runs-on: ubuntu-latest
    if: github.event_name == 'issues' && github.event.action == 'closed'
    steps:
      - name: 'Removed issue'
        uses: matthewmayer/project-beta-remove@v0.0.1
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.issue.node_id }}
```