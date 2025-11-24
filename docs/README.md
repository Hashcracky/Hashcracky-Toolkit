# Hashcracky Toolkit Container
This repository defines a multi-stage Docker build that packages several password-cracking–related utilities into a Alpine-based image. The goal of this image is to make it easy to use and access tooling for cryptographic hash recovery research and training. We are not the author of all tools used in this repository and are only providing an environment. Please consider supporting the tool creators.

## Included Tools

The image currently builds and bundles the following projects:

- **ptt**  
  - Source: [hashcracky/ptt](https://github.com/hashcracky/ptt)  
  - Description: Password Transformation Tool (ptt) is a versatile utility designed for password cracking.

- **brainstorm**  
  - Source: [hashcracky/brainstorm](https://github.com/hashcracky/brainstorm)  
  - Description: Brainstorm is a focused text transformation tool designed to help generate and normalize candidate strings from raw text.

- **rulechef**  
  - Source: [Cynosureprime/rulechef](https://github.com/Cynosureprime/rulechef)  
  - Description: A powerful tool for analyzing and generating rule chains using Markov chains and probabilistic transitions.

- **rulecat**  
  - Source: [Cynosureprime/rulecat](https://github.com/Cynosureprime/rulecat)  
  - Description: A sophisticated password rule generator and mutator for password cracking tools that uses statistical learning to create high-quality transformation rules. 

- **hashcat-utils** (binaries and Perl scripts)  
  - Source: [hashcat/hashcat-utils](https://github.com/hashcat/hashcat-utils)  
  - Description: A collection of helper tools and several `*.pl` scripts that assist in wordlist and rule processing for hashcat.

All of these tools are copied into `/bin` in the final runtime image so they are available directly on the `PATH`.

## Image Layout

The Dockerfile uses a three-stage build:

1. **Go build layer (`gobuild`)**
2. **C build layer (`cbuild`)**
3. **Run layer (final image)**

The container uses `tini` as PID 1 and a small entrypoint script. 

## Basic Usage

Assuming you have built the image locally as `hashcracky-toolkit`:

```bash
docker build -t hashcracky-toolkit .
```

### Discover Installed Tools

Run the container with no command to see the overview:

```bash
docker run --rm hashcracky-toolkit
```

### Use Binaries and Scripts

All tools are placed in `/bin`, so you can call them directly:

```bash
docker run --rm hashcracky-toolkit combinator.bin --help
```

Perl scripts are also available in `/bin` and can be invoked directly if they are marked executable, or via `perl`:

```bash
docker run --rm hashcracky-toolkit perl some_hashcat_util.pl
```

## Work Directory and Volumes

The container’s working directory is set to:

```text
/data
```

You can mount a host directory there for input wordlists, hashes, or output files:

```bash
docker run --rm -v "$(pwd)":/data hashcracky-toolkit rulechef ...
```
