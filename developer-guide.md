# Developer Guide

Welcome to the BeS Playbook Developer Guide! This document is designed to provide you with all the necessary information to contribute effectively to our project. Whether you're a seasoned developer or just starting out, we appreciate your interest in helping us improve, create and expand BeS Playbooks.

## About BeS Playbook

A playbook in Be-Secure ecosystem refers to a set of instructions for completing a routine task. Not to be confused with an Ansible playbook. There can be automated(.sh), interactive(.ipynb) & manual(*.md) playbooks. It helps the security analyst who works in a BeSLab instance to carry out routine tasks in a consistent way. These playbooks are automated and are executed using the [BeSman](https://github.com/Be-Secure/BeSman) utility.

All the playbooks that are created by our community is stored in this repo.

## Repository Structure

```code
. ----------------------------------------------------------- Root dir where repo related files are present
└── playbook-metadata.json ---------------------------------- File containing details of the available playbooks.
└── playbooks ----------------------------------------------- Dir which holds all the playbooks and steps files.
    ├── besman-scorecard-0.0.1-steps.sh            -----|
    ├── besman-sonarqube-0.0.1-playbook.sh              |              
    ├── besman-sonarqube-0.0.1-steps.ipynb              |
    ├── besman-spdx-sbom-generator-0.0.1-playbook.sh    |----- Examples of playbooks and steps file
    ├── besman-spdx-sbom-generator-0.0.1-steps.sh       |
    ├── besman-watchtower-0.0.1-playbook.sh             |
    └── besman-watchtower-0.0.1-steps.sh           -----|
```

## OS

BeSman, environments and playbooks are designed to run on Linux platforms. If you are a Windows user, check about Windows Subsystem for Linux(WSL) from [here](https://learn.microsoft.com/en-us/windows/wsl/setup/environment).

You can pretty much develop playbooks in any OS of your choice, but to test it you will require a Linux machine. Peferably Ubuntu.

## Prerequisites

Before you begin you should have the following tool installed in your machine.

- [BeSman](https://github.com/Be-Secure/BeSman)

Have an understanding of

- [BeSman](https://github.com/Be-Secure/BeSman/blob/master/README.md).
- [Playbooks](./README.md).
- [Environments](https://github.com/Be-Secure/besecure-ce-env-repo/blob/develop/README.md).

## Set up IDE

You can use any IDE that supports extensions for shell script development, creation/viewing of jupyter notebook and creation of md files.

We prefer Microsoft Visual Studio Code. You can see the instruction to install it from [here](https://code.visualstudio.com/download).


## Getting Started

### 1. Fork the repo

You should have a fork of this repo under you namespace.

### 2. Clone the repo

To begin developement you should clone the playbook store repo from your namespace

    git clone https://github.com/[your namespace]/besecure-playbooks-store

### 3. Install BeS Environment

The BeS Environment installs the dependencies for the project and the tools to perform assessment. The tool for which you are developing the playbook has to be installed using the environment. Learn how to add tools to environment [here](TBD).

<!-- 1. Open your terminal (`ctrl` + `alt` + `t`)
2. Confirm installation of BeSman by running

        bes help

3. Get the list of available environments

        bes list -env

    `Note:` Know about switching branches and repos from you run environments from [here](https://github.com/Be-Secure/BeSman/tree/develop?tab=readme-ov-file#21-list).

4. Set up the environment configuration by following the steps from [here](https://github.com/Be-Secure/besecure-ce-env-repo/tree/develop?tab=readme-ov-file#41-edit-environment-configuration).

5. Run the install command to install an environment from the available list of environments.

        bes install -env <environment name> -V <version> -->



## Developing your playbook

Few things to know before starting the development of playbook,

Every environment script has a configuration file associated with it. The configuration file contain a set of parameters such as parameters related to artifact such as name; version; type, assessment datastore such as url and location, tools to be installed, lab association such as lab name and type, environment such as its name. It can also contain parameters related to tool such as the version.

You can also add your own configuration to the environment.

Learn more about environment configuration and how to add more variables into environment configuration from [here](tbd).


A playbook consists of two files,

 - lifecycle file
 - steps file

### Creating playbook files

Follow the below steps to create a new playbook

1. Open the cloned repo in your editor.
2. Create a new branch. [Learn more](./CONTRIBUTING.md#branching-and-release-strategy)
3. Under the `playbooks/` dir, create the following files - `besman-<tool name>-0.0.1-playbook.sh` and `besman-<tool name>-0.0.1-steps.(md | sh | ipynb)`.

