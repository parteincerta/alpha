#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -e

scriptdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
rootdir="$(cd "$scriptdir/../../" && pwd)"
pushd "$scriptdir" >/dev/null
trap "popd >/dev/null" EXIT

source "$rootdir/shared/scripts/helper.sh"
trap "popd >/dev/null; trap_error" ERR

source "$rootdir/shared_macos/.bash_profile" || true
expected_hostname="mbp15-i7"
if [ "$expected_hostname" != "$SHORT_HOSTNAME" ]; then
	log_warning ">>> This configuration script belongs to another host: $expected_hostname".
	log_warning ">>> The current host is: $SHORT_HOSTNAME"
	exit 1
fi

mkdir -p \
"$HOME"/{.gnupg,.local/{bin,share/lf},.ssh/sockets} \
"$HOME"/.local/{bin,share/lf} \
"$HOME"/Library/{KeyBindings,LaunchAgents} \
"$HOME/Library/Application Support/Code/User/" \
"$HOME/Library/Application Support/com.nuebling.mac-mouse-fix/" \
"$HOME/Library/Application Support/obs-studio/basic/" \
"$XDG_CACHE_HOME"/{ads,code}/{data/User,extensions} \
"$XDG_CACHE_HOME/bun"/{bin,cache-install,cache-transpiler,lib} \
"$XDG_CACHE_HOME/deno/cache" \
"$XDG_CONFIG_HOME"/{bat/themes,fd,fish,git,kitty,lf,mise,nvim,pip,zed} \
"$CODE"/{github,icnew/{git-icone,misc},parteincerta} \
"$DOCUMENTS"/{Captures,Misc,Remote} \
"$DOWNLOADS"/{Brave,Safari,Torrents}

app_support_folder="$HOME/Library/Application Support"
vscode_cache_dir="$XDG_CACHE_HOME/code/data/User"
vscode_settings_dir="$app_support_folder/Code/User"

rm -rf "$XDG_CONFIG_HOME/nvim/"{init.lua,lua/}

cp mise.toml "$XDG_CONFIG_HOME/mise/config.toml"
cp -R obs/* "$app_support_folder/obs-studio/basic"

cp "$rootdir/shared_macos/.bash_profile" "$HOME/"
cp "$rootdir/shared_macos/config.fish" "$XDG_CONFIG_HOME/fish/"
cp "$rootdir/shared_macos/lfrc" "$XDG_CONFIG_HOME/lf/"

cp "$rootdir/shared/.inputrc" "$HOME/"
cp "$rootdir/shared/git.conf" "$XDG_CONFIG_HOME/git/config"
cp "$rootdir/shared/gpg.conf" "$HOME/.gnupg/"
cp "$rootdir/shared/fdignore" "$XDG_CONFIG_HOME/fd/ignore"
cp "$rootdir/shared/keybindings.vscode.json" "$vscode_cache_dir/keybindings.json"
cp "$rootdir/shared/keybindings.vscode.json" "$vscode_settings_dir/keybindings.json"
cp "$rootdir/shared/kitty_theme.conf" "$XDG_CONFIG_HOME/kitty/"
cp "$rootdir/shared/lficons" "$XDG_CONFIG_HOME/lf/icons"
cp "$rootdir/shared/lfpreview" "$HOME/.local/bin/"
cp -R "$rootdir/shared/neovim/"* "$XDG_CONFIG_HOME/nvim/"
cp "$rootdir/shared/obs-mask.png" "$DOCUMENTS/Misc/"
cp "$rootdir/shared/pip.conf" "$XDG_CONFIG_HOME/pip/"
cp "$rootdir/shared/ssh.conf" "$HOME/.ssh/config"
cp "$rootdir/shared/tokyonight-moon.tmTheme" "$XDG_CONFIG_HOME/bat/themes"
cp "$rootdir/shared/zed.keymap.json" "$XDG_CONFIG_HOME/zed/keymap.json"

ln -sf "$HOME/.bash_profile" "$HOME/.bashrc"
chmod u=rwx,g=,o= "$HOME/.gnupg"
chmod u=rw,g=,o= "$HOME/.gnupg/"*
chmod u=rwx,g=,o= "$HOME/.ssh"
chmod u=rwx,g=,o= "$HOME/.ssh/sockets"
chmod u+x "$HOME/.local/bin/lfpreview"

touch "$HOME/.bash_sessions_disable"
touch "$HOME/.hushlogin"
touch "$XDG_CONFIG_HOME/lf/bookmarks"

source "$rootdir/shared_macos/scripts/export-defaults.sh" --source-keys-only
defaults import "$actmon_key" "$actmon_file"
defaults import "$alttab_key" "$alttab_file"
defaults import "$betterdisplay_key" "$betterdisplay_file"
cp "$macmousefix_file" "$app_support_folder/com.nuebling.mac-mouse-fix/config.plist"

# This section is reserved for files that must be patched upfront.
# ================================================================

(echo "cat <<EOF"; cat "$rootdir/shared_macos/lfmarks"; echo EOF) |
	sh >"$HOME/.local/share/lf/marks"

if [ -n "$HOMEBREW_PREFIX" ]; then
	export bun_cache_dir="$XDG_CACHE_HOME/bun/cache-install"
	export bun_global_bindir="$XDG_CACHE_HOME/bun/bin"
	export bun_global_dir="$XDG_CACHE_HOME/bun/lib"
	export font_size="10.5"

	envsubst <"$rootdir/shared_macos/.bunfig.toml" >"$XDG_CONFIG_HOME/.bunfig.toml"
	envsubst <"$rootdir/shared_macos/kitty.conf" >"$XDG_CONFIG_HOME/kitty/kitty.conf"
	envsubst <"$rootdir/shared/settings.vscode.json" >"$TMPDIR/settings.vscode.json"
	envsubst <"$rootdir/shared/zed.settings.json" >"$XDG_CONFIG_HOME/zed/settings.json"
	cp "$TMPDIR/settings.vscode.json" "$vscode_cache_dir/settings.json"
	cp "$TMPDIR/settings.vscode.json" "$vscode_settings_dir/settings.json"
	rm "$TMPDIR/settings.vscode.json"
fi