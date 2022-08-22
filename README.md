# coshipy
vim(**co**nda, **sh**ell, v.**ipy**thon)
_______________________________________________________________________________

This is a fork of [vim-pyShell](https://github.com/greghor/vim-pyShell) by
[@greghor](https://github.com/greghor), originally made with the intent of
"boosting a data science workflow with vim+tmux" (more info
[here](https://towardsdatascience.com/boosting-your-data-science-workflow-with-vim-tmux-14505c5e016e)).
What `coshipy` expands on, is in its integration with the
[conda](https://github.com/conda/conda) ecosystem.

The simplicity of implementation of `vim-pyShell` and above all its usefulness,
interconnecting Vim plugins [vimux](https://github.com/preservim/vimux) with
[vim-cellmode](https://github.com/julienr/vim-cellmode), to form a workflow for
users of both
[Vim](https://github.com/vim/vim) and
[IPython](https://github.com/ipython/ipython), finds added value residing in
the customization of mappings to Python's pandas library methods for data
inspection purposes.

In [@greghor](https://github.com/greghor)'s own words:
> "This is a very basic integration of the ipython. 
> So far it allows to start an ipython repl in tmux, then vimux is used to
> send lines to it. There are also specific functions to work with pandas 
> dataframes."

## Why coshipy!?
When one uses IPython through several <u>conda environments</u> and typically
works in <u>vi-mode</u>, prescience dictates that one might need to:

* **choose which conda environment to launch IPython from**;
* **run "vipython" i.e., IPython in vi-mode**.

## Components

### coshipy.vim
This file inherits from `vim-pyShell` in almost its entirety, with the
exception that its `StartPyShell()`**<sup>*</sup>** and
`StopPyShell()`**<sup>*</sup>** functions now wrap vimux function calls to
activate conda environments (thus running IPython from them) and also exit and
deactivate them, respectively.

<b>*</b> <sub>now known as `StartCondaShell()` and `StopCondaShell()` in
`coshipy`</sub>

### conda_env_sel.sh
This bash script is responsible for the listing, selection and activation of
conda environments, as well as ensuring that the selected environments indeed
host IPython and, of course, ultimately it takes care of the latter's execution
in vi-mode.

#### $CONDAENVSEL
**⚠ Outside the below mentioned use cases this can be safely ignored.**

This environment variable defines the path to `conda_env_sel.sh`, it is useful
in case of:

* using only one specific conda environment with `coshipy`;
* multi-user setups (where the `coshipy` Vim plugin is installed outside the
usual home directory path i.e., `~/.vim/bundle/coshipy/`).

And it should be exported to `.bashrc`, or the like (see
[.bashrc](#.bashrc) section).

## Installation

### Requirements
The following dependencies are required for full functionality:

* [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html)
* [ipython](https://anaconda.org/anaconda/ipython)**<sup>*</sup>**
* [matplotlib](https://anaconda.org/anaconda/matplotlib)**<sup>*</sup>**
* [pandas](https://anaconda.org/anaconda/pandas)**<sup>*</sup>**
* [tmux](https://github.com/tmux/tmux)  (tested with version 1.9, fails with 1.6)

<b>*</b> <sub>these packages should be installed under the same conda 
environment, in order to solve and maintain dependency issues ("how to" example
[here](https://medium.com/@balance1150/how-to-build-a-conda-environment-through-a-yaml-file-db185acf5d22))</sub>

### .bashrc

#### Using a multi conda env setup
**⚠ If you're using multiple environments in your conda setup, then there's no
need to change anything, you can follow along to the [.vimrc](#.vimrc)
section.**

Else continue...

#### Using a single conda env setup
If you know beforehand that you'll only be using a specific conda environment,
then `conda_env_sel.sh` can be overridden in favour of sourcing that one
specific environment. 

Follow these next steps to setup for a single conda environment:

<ol>
<li> Use the following command to generate the new shell script, replacing the
<code>&ltconda_env_name&gt</code> field with your conda's environment name:

```sh
printf "
source "$(conda info --base)"/etc/profile.d/conda.sh
conda activate <conda_env_name>
ipython --TerminalInteractiveShell.editing_mode=vi" > \
conda_env.sh && sudo chmod 755 conda_env.sh
```
</li>

<li>Move the newly created <code>conda_env.sh</code> script to a desired
location;</li>

<li>Place the following line, with the full path to the
<code>conda_env.sh</code> script, inside <code>.bashrc</code>:

```bashrc
export CONDAENVSEL="<path/to/conda_env.sh>"
```
</li> 
</ol>

#### Using a shared user conda env setup
When using a conda environment setup encompassing multiple users, with a
centralized file system shared across them, one might run into a situation
where the `conda_env_sel.sh` file falls outside it's usual path (e.g., usually
something of sorts
`~/.vim/bundle/coshipy/plugin/conda_env_sel.sh`).

Setting the `$CONDAENVSEL` envar to the central `conda_env_sel.sh` and
exporting this for each user in the setup, provides a solution.

To setup for a shared user with multiple conda environments, simply place the
following line, with the full path to the central `conda_env_sel.sh` script
inside `.bashrc`:

```bashrc
export CONDAENVSEL="<path/to/central/user/conda_env_sel.sh>"
```

### .vimrc

#### Plugin bundle
After installing the required dependencies, use a Vim plugin manager and add
the following plugins to your `.vimrc` e.g., using
[vim-plug](https://github.com/junegunn/vim-plug):

```vimrc
Plug 'preservim/vimux'
Plug 'joaoandreporto/coshipy'
Plug 'julienr/vim-cellmode'
```

#### Useful mappings
To also include in your `.vimrc`:

```vimrc
"" coshipy/vim-cellmode mappings
" ipython-shell
noremap <localleader>is :call StartCondaShell()<CR>
noremap <localleader>ik :call StopCondaShell()<CR>

" code execution
" sends the currently selected lines to tmux
nnoremap <localleader>l :call CondaShellSendLine()<CR>
vnoremap <silent> <localleader>l :call RunTmuxPythonChunk()<CR>
" sends the current cell to tmux, moving to the next one
noremap <silent> <localleader>c :call RunTmuxPythonCell(0)<CR>
" sends the current cell to tmux
noremap <silent> <localleader>cc :call RunTmuxPythonCell(1)<CR>
" executes all the cells above the current line. That is, everything from the
" beginning of the file to the closest ## above the current line
noremap <silent> <localleader>C :call RunTmuxPythonAllCellsAbove()<CR>

" code inspection
" get the lenght of iterable under cursor
nnoremap <localleader>iil :call CondaShellSendKey("len(<C-R><C-W>)\r")<CR><Esc>
" get the number of occurences of the item under the cursor in the data
nnoremap <localleader>iic :call CondaShellSendKey("<C-R><C-W>.count()\r")<CR><Esc>
" get the content of the item under the cursor
nnoremap <localleader>iii :call CondaShellSendKey("<C-R><C-W>\r")<CR><Esc>
" escape quote characters in target selection
vnoremap <localleader>iis y:call CondaShellSendKey(substitute('<C-R>0',"\"","\\\"","")."\r")<CR> 

" dataframes (pandas)
" print the dataframe first elements
nnoremap <localleader>idh :call CondaShellSendKey("<C-R><C-W>.head()\r")<CR><Esc>
" print the dataframe column labels
nnoremap <localleader>idc :call CondaShellSendKey("<C-R><C-W>.columns\r")<CR><Esc>
" print dataframe information, including the index dtype and columns, non-null
" values and memory usage
nnoremap <localleader>idi :call CondaShellSendKey("<C-R><C-W>.info()\r")<CR><Esc>
" Generate descriptive statistics, include those that summarize the central
" tendency, dispersion and shape of a dataset’s distribution, excluding NaN
nnoremap <localleader>idd :call CondaShellSendKey("<C-R><C-W>.describe()\r")<CR><Esc>
" return a series with the data type of each column
nnoremap <localleader>idt :call CondaShellSendKey("<C-R><C-W>.dtypes\r")<CR><Esc>

" plots (matplotlib)
" plot the content of the dataframe
nnoremap <localleader>ipp :call CondaShellSendKey("<C-R><C-W>.plot()\r")<CR><Esc>
" display the histograms
nnoremap <localleader>iph :call CondaShellSendKey("<C-R><C-W>.hist()\r")<CR><Esc>
" close all plots
nnoremap <localleader>ipc :call CondaShellSendKey("plt.close('all')\r")<CR><Esc>
```

Following on the lead from upstream:
> "Be creative, build-up on that, and create your own mappings!"

##### Extras
Since `vim-cellmode`'s mappings clash with Vim's default mappings, it is
probably a good idea, for users who rely on these defaults, to disable these
mappings, like so:

```vimrc
let g:cellmode_default_mappings='0'
```

The following options might also be sensible to set and were derived from
[@greghor](https://github.com/greghor)'s
[.vimrc](https://github.com/greghor/vimux-ds-workflow/blob/master/src/.vimrc):

```vimrc
set bomb
set binary
set ttyfast
```

## Usage
Once all is setup and if using the mappings described above:

1. Open your `.py` file in Vim;
2. Press `<localleader>is` to activate the conda environment and start the
   IPython session;
3. Select your session by typing its number and evaluate the line where it is
   typed with `<localleader>l` or jump to the tmux pane and insert it there;
4. Do your thing (use the different mappings);
5. Once you're done, press `<localleader>ik` to exit IPython and deactivate the
   conda environment.

## TODO
- [ ] Implement Qt Console for Jupyter

## Contributing
Feel free to raise any related issues and pull requests on 
[this repo](https://github.com/joaoandreporto/coshipy).

## Credits
Thank you to [@greghor](https://github.com/greghor) and
[@tcarette](https://github.com/tcarette) for laying out the groundwork for this
plugin with `vim-pyShell` and `vim-sparkShell`, as well as
[@julienr](https://github.com/julienr) et al. for `vim-cellmode` and
[@benmills](https://github.com/benmills) et al. for `vimux`
