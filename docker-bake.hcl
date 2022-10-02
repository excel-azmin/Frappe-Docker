# Docker Buildx Bake build definition file
# Reference: https://github.com/docker/buildx/blob/master/docs/reference/buildx_bake.md

variable "REGISTRY_USER" {
    default = "frappe"
}

variable "FRAPPE_VERSION" {
    default = "develop"
}

variable "ERPNEXT_VERSION" {
    default = "develop"
}

variable "FRAPPE_REPO" {
    default = "https://github.com/frappe/frappe"
}

variable "ERPNEXT_REPO" {
    default = "https://github.com/frappe/erpnext"
}

variable "BENCH_REPO" {
    default = "https://github.com/frappe/bench"
}

# Bench image

target "bench" {
    args = {
        GIT_REPO = "${BENCH_REPO}"
    }
    context = "images/bench"
    target = "bench"
    tags = ["frappe/bench:latest"]
}

target "bench-test" {
    inherits = ["bench"]
    target = "bench-test"
}

# Main images
# Base for all other targets

group "frappe" {
    targets = ["frappe-worker", "frappe-nginx", "frappe-socketio", "assets-builder"]
}

group "erpnext" {
    targets = ["erpnext-worker", "erpnext-nginx"]
}

group "default" {
    targets = ["frappe", "erpnext"]
}

function "tag" {
    params = [repo, version]
    result = [
      # If `version` param is develop (development build) then use tag `latest`
      "${version}" == "develop" ? "${REGISTRY_USER}/${repo}:latest" : "${REGISTRY_USER}/${repo}:${version}",
      # Make short tag for major version if possible. For example, from v13.16.0 make v13.
      can(regex("(v[0-9]+)[.]", "${version}")) ? "${REGISTRY_USER}/${repo}:${regex("(v[0-9]+)[.]", "${version}")[0]}" : "",
    ]
}

target "default-args" {
    args = {
        FRAPPE_REPO = "${FRAPPE_REPO}"
        ERPNEXT_REPO = "${ERPNEXT_REPO}"
        BENCH_REPO = "${BENCH_REPO}"
        FRAPPE_VERSION = "${FRAPPE_VERSION}"
        ERPNEXT_VERSION = "${ERPNEXT_VERSION}"
        # If `ERPNEXT_VERSION` variable contains "v12" use Python 3.7. If "v13" — 3.9. Else 3.10.
        PYTHON_VERSION = can(regex("v12", "${ERPNEXT_VERSION}")) ? "3.7" : can(regex("v13", "${ERPNEXT_VERSION}")) ? "3.9" : "3.10"
    }
}

target "frappe-worker" {
    inherits = ["default-args"]
    context = "images/worker"
    target = "frappe"
    tags = tag("frappe-worker", "${FRAPPE_VERSION}")
}

target "erpnext-worker" {
    inherits = ["default-args"]
    context = "images/worker"
    target = "erpnext"
    tags =  tag("erpnext-worker", "${ERPNEXT_VERSION}")
}

target "frappe-nginx" {
    inherits = ["default-args"]
    context = "images/nginx"
    target = "frappe"
    tags =  tag("frappe-nginx", "${FRAPPE_VERSION}")
}

target "assets-builder" {
  inherits = ["default-args"]
  context = "images/nginx"
  target = "assets_builder"
  tags = tag("assets-builder", "${FRAPPE_VERSION}")
}

target "erpnext-nginx" {
    inherits = ["default-args"]
    context = "images/nginx"
    target = "erpnext"
    tags =  tag("erpnext-nginx", "${ERPNEXT_VERSION}")
}

target "frappe-socketio" {
    inherits = ["default-args"]
    context = "images/socketio"
    tags =  tag("frappe-socketio", "${FRAPPE_VERSION}")
}
