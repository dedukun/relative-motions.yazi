# relative-motions.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin based about vim motions.

> [!NOTE]
> The latest main branch of Yazi is required at the moment.

## Installation

```sh
# Linux/macOS
git clone https://github.com/dedukun/relative-motions.yazi.git ~/.config/yazi/plugins/relative-motions.yazi

# Windows
git clone https://github.com/dedukun/relative-motions.yazi.git %AppData%\yazi\config\plugins\relative-motions.yazi
```

## Configuration

If you want to use the numbers directly to start a motion add this to your `keymap.toml`:

<details>

```toml
[[manager.prepend_keymap]]
on = [ "1" ]
exec = "plugin relative-motions --args=1"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "2" ]
exec = "plugin relative-motions --args=2"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "3" ]
exec = "plugin relative-motions --args=3"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "4" ]
exec = "plugin relative-motions --args=4"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "5" ]
exec = "plugin relative-motions --args=5"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "6" ]
exec = "plugin relative-motions --args=6"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "7" ]
exec = "plugin relative-motions --args=7"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "8" ]
exec = "plugin relative-motions --args=8"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "9" ]
exec = "plugin relative-motions --args=9"
desc = "Move in relative steps"
```

</details>

Alternatively you can use a key to trigger a new motion, for that add the following in `keymap.toml`:

```lua
[[manager.prepend_keymap]]
on = [ "9" ]
exec = "plugin relative-motions"
desc = "Trigger a new relative motion"
```

---

Additionally there are a couple of initial configurations that can be given to the plugin's `setup` function:

| Configuration  | Values                           | Default    | Description                                             |
| -------------- | -------------------------------- | ---------- | ------------------------------------------------------- |
| `show_numbers` | `relative`, `absolute` or `none` | `relative` | Shows relative or absolute numbers before the file icon |
| `show_motion`  | `true` or `false`                | `false`    | Shows current motion in Status bar                      |

If you want, for exemple, to enable absolute numbers, as well as the show the motion in the status bar,
add the following to `init.lua`:

```lua
require("relative-motions"):setup({show_numbers="absolute", show_motion = true})
```

> [!NOTE]
> The `show_numbers` functionality overwrites [`Folder:icon`](https://github.com/sxyazi/yazi/blob/e51e8ad789914b2ab4a9485da7aa7fbc7b3bb450/yazi-plugin/preset/components/folder.lua#L17)
> and `show_motion` adds a new `Status.motions` and modifies `Status.render`,
> so if you are already modifying using any of this functions you will encounter some issues.

## Usage

This plugin adds the some basic vim motions like `3k`, `12j`, `10gg`, etc.
The following table show all the available motions:

| Command | Description       |
| ------- | ----------------- |
| `j`     | Move `x` down     |
| `k`     | Move `x` up       |
| `gj`    | Go `x` lines down |
| `gk`    | Go `x` lines up   |
| `gg`    | Go to line        |

Furthermore, the following operations were also added:

| Command | Description   |
| ------- | ------------- |
| `v`     | visual select |
| `y`     | Yank          |
| `x`     | Cut           |
| `d`     | Delete motion |

This however must be followed by a direction, which can be `j`, `k` or repeating the command key,
which will default the direction down, e.g. `2yy` will copy two lines down.
