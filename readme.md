# Reflective Standards in Cairo 🐫
![Description of Image](public/alter.png)
## Overview 🌐

This repository is dedicated to the exploration and development of reflective standards and assets using the Cairo language. Reflective assets have the unique property of automatically redistributing a portion of transactions to existing holders, creating a self-rewarding mechanism.

## Motivation 🚀

Blockchain and smart contracts present a vast, ever-evolving domain. It's pivotal to adapt existing standards and foster innovations like reflective assets, a novelty in decentralized finance (DeFi).

## Goals 🎯

- **Translate and Adapt**: Our primary goal (by now) is to translate the well-known `reflect.sol` from Solidity to Cairo, ensuring that the unique properties of reflective assets are preserved and optimized for the Cairo environment.
- **Wrapper**: Coming soon...

## Installation 🔧

Before you can set up the project, you'll need to have `scarb` and `starkli` installed on your machine. If you don't have them installed, you can find the installation instructions on the official documentation:

- [Scarb Installation](https://docs.swmansion.com/scarb/download.html)
- [Starkli Installation](https://github.com/starkware-libs/starkli)

## Project Setup 🛠️

Once you have installed `scarb` and `starkli`, it's time to set up the project on your local machine. Follow the steps below:

1. Create a new folder for the project.
```bash
mkdir your_project_name
```
2. Navigate to the new folder in your terminal.
```bash
cd your_project_name
```
3. Clone the repository into your new project folder.
```bash
git clone https://github.com/henryf10h/reflect_cairo.git
```
4. Change directory to the cloned repository.
```bash
cd reflect_cairo
```
5. Now you are ready to build the project using scarb.
```bash
scarb build
```
6. You can also run the provided tests using scarb.
```bash
scarb test
```

## Deployment

To deploy the `reflect.cairo` contract, follow the steps below:

### 1. Declaration

```bash
starkli declare --watch target/dev/reflect_cairo_REFLECT.sierra.json --account ~/.starkli-wallets/deployer/account.json --keystore ~/.starkli-wallets/deployer/keystore.json
```
### 2. Deployment

```bash
starkli deploy --watch 0x06ddeba5578f6f28b0688bfb0b6891a3d50ee8a0a7f8b98d26fd874e710a4674 str:name str:symbol u256:10000000000000000 0x52e6ad8187767ef41f2f3bc225d33d31b37dd9bbee7b628f4b6b16b90d293ec --account ~/.starkli-wallets/deployer/account.json --keystore ~/.starkli-wallets/deployer/keystore.json 
```
emoji of wuju!
## Tooling

The following tools are utilized in this project:

- **Starkli**: A CLI tool for interacting with StarkNet.[Starkli](https://book.starkli.rs/)
- **Scarb**: A testing framework for StarkNet contracts. [Scarb](https://docs.swmansion.com/scarb/docs.html/)
- **Cairo 1.0 VSCode Extension**: An extension for Visual Studio Code to support Cairo language. [Get it here](https://marketplace.visualstudio.com/items?itemName=starkware.cairo1)

## Resources

Here are some resources to get more familiar with the underlying technologies:

- [Technical Paper on Reflect Contracts by Anonymous Builder](https://forum.openzeppelin.com/t/a-technical-whitepaper-for-reflect-contracts/14297)
- [Cairo Book](https://book.cairo-lang.org/)
- [Cairo by Example](https://cairo-by-example.com/)
- [StarkNet Book](https://book.starknet.io/index.html/)

## Version

The versions of the tools and libraries used are as follows:

```bash
starkli --version
# Output: 0.1.15 (995c95a)
scarb --version
# Output: 0.7.0 (58cc88efb 2023-08-23)
cairo --version
# Output: 2.2.0 (https://crates.io/crates/cairo-lang-compiler/2.2.0)
sierra --version
# Output: 1.3.0
```


### Contribution ✨
We welcome contributions from the community! Whether you're a seasoned developer or just getting started, there's room for everyone to make an impact. If you have ideas, optimizations, you just want to write tests or anything aligned with reflective standards, please feel free to raise an issue or submit a pull request.

### Final Thoughts 💭
Let's come together to create, inspire, and redefine the boundaries of what's possible."
