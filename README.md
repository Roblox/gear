# Gear

Source representation of classic Roblox catalog gear, released as an as-is archive for reading, learning, and experimentation on the Roblox platform.

Gear sources are maintained in an internal Roblox repository and mirrored one-way to the public [Roblox/gear](https://github.com/Roblox/gear) repository. Changes are made internally and flow outward to the mirror, never the reverse.

A browsable catalog of the dumped items is published at [https://roblox.github.io/gear/](https://roblox.github.io/gear/).

## License

This project is licensed under the [MIT License](LICENSE.txt). See `LICENSE.txt` at the root of this repository for the full terms.

## What's in this repo

- `src/gear/` — Rojo source for catalog gear items (scripts, instances, and related files as dumped from the original assets)
- `assets/` — associated binary assets
- `site/` — generator for the static gear catalog
- `scripts/` — Luau tooling used internally to dump, verify, and publish the archive

## Contributions

Roblox is not accepting code contributions to this archive. Pull requests opened against the public mirror will not be reviewed or merged, and issues are turned off there, so there is no need to file one.

Roblox employees can open issues and pull requests in the internal repository, where every change to the archive originates.

## Reporting a security issue

Report suspected vulnerabilities to the Roblox bug bounty program on HackerOne, as described in [SECURITY.md](SECURITY.md). Please do not report a vulnerability through a public issue.
