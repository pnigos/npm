workflow "Build and Publish" {
  on = "push"
  resolves = "Docker Publish"
}

action "Shell Lint" {
  uses = "actions/bin/shellcheck@master"
  args = "entrypoint.sh"
}

action "Test" {
  uses = "actions/bin/bats@master"
  args = "test/*.bats"
}

action "Integration Test" {
  uses = "./"
  args = "version"
}

action "Docker Lint" {
  uses = "docker://replicated/dockerfilelint"
  args = ["Dockerfile"]
}

action "Build" {
  needs = ["Shell Lint", "Test", "Integration Test", "Docker Lint"]
  uses = "actions/docker/cli@master"
  args = "build -t npm ."
}

action "Docker Tag" {
  needs = ["Build"]
  uses = "actions/docker/tag@master"
  args = "npm github/npm --no-latest"
}

action "Publish Filter" {
  needs = ["Build"]
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Docker Login" {
  needs = ["Publish Filter"]
  uses = "actions/docker/login@master"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "Docker Publish" {
  needs = ["Docker Tag", "Docker Login"]
  uses = "actions/docker/cli@master"
  args = "push github/npm"
}

workflow "New workflow" {
  on = "push"
  resolves = ["GraphQL query"]
}

action "GraphQL query" {
  uses = "helaili/github-graphql-action@f9197781e4fe192857ae3a20eb7b028b78097d38"
}
