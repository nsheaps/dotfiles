#!/usr/bin/env bash
# Environment variables for login shells
# This file is sourced by both zprofile and bash_profile

# Java/OpenJDK 21
export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
export PATH="$JAVA_HOME/bin:$PATH"

# .NET
export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
export PATH="$DOTNET_ROOT:$PATH"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi
