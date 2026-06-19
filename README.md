# GitHub Workflows

## External action versions

These reusable workflows reference the following external GitHub Actions:

| Action | Version | Referenced by |
| --- | --- | --- |
| `MrSquaare/ssh-setup-action` | `v4.0.0` | `create-release.yml`, `docker-build-arm.yml`, `docker-build.yml`, `run-pylint.yml`, `run-ruff.yml`, `run-unit-tests.yml` |
| `actions/checkout` | `v7.0.0` | `create-release.yml`, `docker-build-arm.yml`, `docker-build.yml`, `run-pylint.yml`, `run-ruff.yml`, `run-unit-tests.yml`, `workflow-publish-package-arm.yml`, `workflow-publish-package.yml` |
| `actions/download-artifact` | `v8.0.1` | `docker-build-arm.yml` |
| `actions/setup-python` | `v6.2.0` | `create-release.yml`, `run-pylint.yml`, `run-ruff.yml`, `run-unit-tests.yml` |
| `docker/build-push-action` | `v7.2.0` | `docker-build-arm.yml`, `docker-build.yml`, `workflow-publish-package-arm.yml`, `workflow-publish-package.yml` |
| `docker/login-action` | `v4.2.0` | `docker-build-arm.yml`, `docker-build.yml`, `workflow-publish-package-arm.yml`, `workflow-publish-package.yml` |
| `docker/metadata-action` | `v6.1.0` | `docker-build-arm.yml`, `docker-build.yml`, `workflow-publish-package-arm.yml`, `workflow-publish-package.yml` |
| `docker/setup-buildx-action` | `v4.1.0` | `docker-build-arm.yml`, `docker-build.yml`, `workflow-publish-package-arm.yml` |
| `docker/setup-qemu-action` | `v4.1.0` | `docker-build-arm.yml`, `docker-build.yml`, `workflow-publish-package-arm.yml` |
| `mathieudutour/github-tag-action` | `v6.2` | `create-release.yml` |
| `softprops/action-gh-release` | `v3.0.1` | `create-release.yml`, `docker-build-arm.yml`, `docker-build.yml` |
