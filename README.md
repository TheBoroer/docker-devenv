# DevEnv

### An all-in-one development environment docker image

This image is meant to be an all-in-one dev environment image that's bundled with some common tooling.

It's bundled with:

- docker-ce-cli
- zsh + ohmyzsh + powerlevel10k theme
- python2 + pip
- python3 + pip3
- pyenv
- pipenv
- nvm (default version: node18) + yarn
- gcloud cli + the following extras:
  - google-cloud-cli-app-engine-python
  - google-cloud-cli-app-engine-python-extras
  - google-cloud-cli-cloud-run-proxy
  - google-cloud-cli-datastore-emulator
  - google-cloud-cli-firestore-emulator
