# ghcid-error-file.nvim

[![CI][status-png]][status]

`ghcid-error-file.nvim` is a `neovim` plugin for Haskell developers who use 
[ghcid] or [ghciwatch] for their feedback compilation loop. It is able to parse 
the error file produced by these tools and fill up the quickfix list with the 
errors found.

Save your file, and hit `:cf` to jump to the first error.

See below for an example of its use in a `tmux` session:

![demo-single-package][demo-single-package]

## Installation

Install the plugin with your favorite plugin manager. For nixos users, [the 
flake file](flake.nix) contains an overlay that will add 
`ghcid-error-file-nvim` to the `vimPlugins` attribute set.

## Configuration

To use the plugin, one must first configure the tool to produce the error file 
on every `ghci` reload. By default, `neovim` will try to load a file named 
`errors.err`. Unless you have changed the `errorfile` setting in `neovim`, the 
tool must be configured to produce an error file with that name.

### ghcid

Create a `.ghcid` file at the root of your project with the following:

```
$ echo "-o errors.err" > .ghcid
```

Then run `ghci` as usual. For a cabal project, for example:

```
$ ghcid -c "cabal repl"
```

### ghciwatch

`ghciwatch` does not have a configuration file. The name of the error file must 
be given on the command line. For example:

```
$ ghciwatch --error-file errors.err --watch ./ --command "cabal repl"
```

## Usage

### Single package project

For single package project, that's all what's needed to work. Save your Haskell 
file, the `ghci` session is automatically reloaded by the tool of your choice, 
hit `:cf` and `neovim` will jump on the first error.

### Multi-package project

For multi-package project, it is unfortunately not that simple. But the plugin 
makes it as easy as possible.

Indeed `ghc` is [not able to output the full 
path](https://gitlab.haskell.org/ghc/ghc/-/issues/15680) of the files that 
contain errors, neither absolute nor relatively to the root of the project (see 
also [that cabal issue](https://github.com/haskell/cabal/issues/6670)). The 
path of the files are only relative to the root of the package itself.

We must somehow tell neovim where the root of the package is. The plugin 
exposes two lua functions from the module 
[ghcid-error-file](src/lua/ghcid-error-file/init.lua) to help with that:
- `cf(new_base_dir)` does what `:cf` does but takes the root directory of the 
  package as an optional argument. `neovim` will prepend that directory to the 
  files listed in the error file. The argument only needs to be given on the 
  first call. Subsequent calls will reuse the previously set directory.
- `cfResetBaseDir()` to reset the base directory to an empty string.

Here is a config example of how to use these functions:

```lua
vim.api.nvim_create_user_command(
  'Cf',
  function(opts)
    require('ghcid-error-file').cf(opts.args)
  end,
  {
    nargs = '?',
    complete = 'file',
  })

vim.api.nvim_create_user_command(
  'CfResetBaseDir',
  require('ghcid-error-file').cfResetBaseDir,
  {}
)
```

Now if the package `some-package` is located in the `./some-package` directory, 
we can call `ghci` with the following command:

```
$ ghcid -c "cabal repl lib:some-package"
```

Then from within `neovim`, one can run `:Cf ./some-package` to load the errors 
the first time. After that, `:Cf` can be called without any argument.

See the following example below:

![demo-multi-package][demo-multi-package]

## Related work

- [ghcid][ghcid-plugin]: The plugin present in the `ghcid` repository. It runs 
  `ghcid` within `neovim`. I used to use it. It works fine as far as I 
  remember. I started developing my plugin because I wanted a simpler approach 
  when running `ghcid` outside of `neovim`.
- [HLS]: Haskell Language Server works fine with small projects. But in my 
  experience, it is very unreliable, memory hungry and slow on big projects.

[HLS]: https://github.com/haskell/haskell-language-server
[demo-multi-package]: ./demo-multi-package.gif
[demo-single-package]: ./demo-single-package.gif
[ghcid-plugin]: https://github.com/ndmitchell/ghcid/tree/master/plugins/nvim
[ghcid]: https://github.com/ndmitchell/ghcid
[ghciwatch]: https://github.com/MercuryTechnologies/ghciwatch
[status-png]: https://github.com/jecaro/ghcid-error-file.nvim/workflows/CI/badge.svg
[status]: https://github.com/jecaro/ghcid-error-file.nvim/actions

