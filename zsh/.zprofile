# macOS /etc/zprofile adjusts PATH after .zshenv; restore Homebrew's priority.
if [[ $OSTYPE == darwin* && -n "${HOMEBREW_PREFIX:-}" ]]; then
  path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" "${(@)path:#$HOMEBREW_PREFIX/bin}")
  path=("${(@u)path}")
  export PATH
fi

# Restore the ai-tools launchers ahead of other binaries.
if (( $+functions[promote_ai_tools] )); then
  promote_ai_tools
fi
