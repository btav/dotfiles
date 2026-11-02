# macOS /etc/zprofile adjusts PATH after .zshenv; restore Homebrew's priority.
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" "${(@)path:#$HOMEBREW_PREFIX/bin}")
  path=("${(@u)path}")
  export PATH
fi

# Restore the ai-tools launchers ahead of other binaries.
promote_ai_tools
