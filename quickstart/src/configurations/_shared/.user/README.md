# What is `.user` for?

`.user` is used as `$HOME`, so that for example the cloud CLIs have a place to store temporary data and configuration. This directory is in `.gitignore` so that changes are not committed but by also being under the mounted volume, still can be used to make files created at runtime available to the host easily.
