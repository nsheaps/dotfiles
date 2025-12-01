Dotfiles for nsheaps

Lots exist, these are mine.
Inspired by https://github.com/getantidote/zdotdir

TODO:

- [ ] update files after updated in repo

Start with:

```bash

setopt interactivecomments
FETCH=($(command -v curl &>/dev/null && echo 'curl -fsSL' || echo 'wget -O -'))
bash <($FETCH "https://raw.githubusercontent.com/nsheaps/homebrew-devsetup/HEAD/install_brew.sh")
\. ~/.zshrc
brew install --cask --adopt nsheaps/devsetup/nsheaps-base

cat << 'EOF' >> ~/.zshrc
#### === MANAGED BY CASK nsheaps/devsetup/nsheaps-base === ####
setopt interactivecomments

source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh

# Initialize antidote's dynamic mode, which changes `antidote bundle`
# from static mode.
source <(antidote init)

antidote bundle <<EOBUNDLES
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-completions
    getantidote/use-omz
    ohmyzsh/ohmyzsh path:lib
    ohmyzsh/ohmyzsh path:plugins/git
    ohmyzsh/ohmyzsh path:plugins/autojump
    ohmyzsh/ohmyzsh path:plugins/brew
    ohmyzsh/ohmyzsh path:plugins/direnv
    ohmyzsh/ohmyzsh path:plugins/docker
    ohmyzsh/ohmyzsh path:plugins/mise
    ohmyzsh/ohmyzsh path:plugins/command-not-found
    ohmyzsh/ohmyzsh path:themes/robbyrussell.zsh-theme
EOBUNDLES

#### === END MANAGED BLOCK === ####

EOF

\. ~/.zshrc

mise use -g \
  node@lts \
  bun \
  python \
  golang
mise ls

```
