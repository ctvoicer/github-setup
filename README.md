# CT Voicer Github Setup

Using this script your project will be bootstraped with the basic labels needed to control your issues according with the *CT Voicer* methodology.

You can take a look here: https://github.com/ctvoicer/github-setup/labels

We now support setting up projects on [GitHub](#github) and [GitLab](#gitlab), click in the links to see more.

## How to use

### GitHub

This repository has a script named [`github-setup.bash`](github-setup.bash) there are two ways to use it.

 1) You could just call it direct from GitHub using cURL, and it will ask you the info to updated your repository:

```bash
$ bash -c "$(curl -sL https://raw.githubusercontent.com/ctvoicer/github-setup/master/github-setup.bash)"
Type your Github repository name (owner/repo_name): github_username/github-setup
Type your Github username: github_username
Type your Github password (won't be shown):
```

 2) Or you [install into your machine](#install) and run it directly setting parameters (or not and it will be asked as shown before):

Usage: `github-setup -u githubUser -p githubPassword owner/repo`

```
    --user, -u      GitHub username
    --password, -p  GitHub password
    --verbose, -v   Details process
```

#### Using Github Token

If you're using github token you must set the environment variable `GITHUB_TOKEN`, then the script will ignore and won't ask for your username and password

### GitLab

Much like the GitHub script, this repository has a script named [`gitlab-setup.bash`](gitlab-setup.bash) and there are two ways to use it.

 1) Just run it directly from GitHub using cURL, a GitLab [personal token](https://docs.gitlab.com/ee/api/README.html#personal-access-tokens) and projects name (owner/project) will be asked:

```bash
$ bash -c "$(curl -sL https://raw.githubusercontent.com/ctvoicer/gitlab-setup/master/gitlab-setup.bash)"
Type your GitLab repository name (owner/repo_name): ctvoicer/awesome-project
Type your GitLab Private-token: <private-token>
```

 2) Or, after [installing it](#gitlab-setup), you can run it directly with parameters (or not and they will be asked as if you were running from GitHub)

Usage: `./gitlab-setup.bash --token gitlab-private-token [-u http://gitlab.example.com] owner/repo`

```
    --help, -h    Show this help
    --token, -t   GitLab Private-Token (defaults to $GITLAB_TOKEN)
    --url, -u     GitLab base URL (defaults to $GITLAB_URL or https://gitlab.com)
    --verbose, -v Details process
```

## Install

To install into your machine just run the commands bellow, and then use the command `github-setup` or `gitlab-setup`.

### GitHub Setup

```sh
curl -sL "https://raw.githubusercontent.com/ctvoicer/github-setup/master/github-setup.bash" -o "/usr/local/bin/github-setup"
chmod a+x /usr/local/bin/github-setup
```

### GitLab Setup

```sh
curl -sL "https://raw.githubusercontent.com/ctvoicer/github-setup/master/gitlab-setup.bash" -o "/usr/local/bin/gitlab-setup"
chmod a+x /usr/local/bin/gitlab-setup
```
