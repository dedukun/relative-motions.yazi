# relative-motions.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin based about vim motions.

https://github.com/dedukun/relative-motions.yazi/assets/25795432/04fb186a-5efe-442d-8d7b-2dccb6eee408

## Requirements

- [Yazi](https://github.com/sxyazi/yazi) v0.2.4+

## Installation

<details>
<summary>Yazi v0.2.5 and before (manual installation)</summary>

```sh
# Linux/macOS
git clone -b 0.2.5 https://github.com/dedukun/relative-motions.yazi.git ~/.config/yazi/plugins/relative-motions.yazi

# Windows
git clone -b 0.2.5 https://github.com/dedukun/relative-motions.yazi.git %AppData%\yazi\config\plugins\relative-motions.yazi
```

</details>

<details>
<summary>Latest commit in Yazi (package manager)</summary>

```sh
# Add the plugin
ya pack -a dedukun/relative-motions

# Install plugin
ya pack -i

# Update plugin
ya pack -u
```

</details>

## Configuration

If you want to use the numbers directly to start a motion add this to your `keymap.toml`:

<details>

```toml
[[manager.prepend_keymap]]
on = [ "1" ]
run = "plugin relative-motions --args=1"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "2" ]
run = "plugin relative-motions --args=2"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "3" ]
run = "plugin relative-motions --args=3"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "4" ]
run = "plugin relative-motions --args=4"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "5" ]
run = "plugin relative-motions --args=5"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "6" ]
run = "plugin relative-motions --args=6"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "7" ]
run = "plugin relative-motions --args=7"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "8" ]
run = "plugin relative-motions --args=8"
desc = "Move in relative steps"

[[manager.prepend_keymap]]
on = [ "9" ]
run = "plugin relative-motions --args=9"
desc = "Move in relative steps"
```

</details>

Alternatively you can use a key to trigger a new motion without any initial value, for that add the following in `keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = [ "m" ]
run = "plugin relative-motions"
desc = "Trigger a new relative motion"
```

---

Additionally there are a couple of initial configurations that can be given to the plugin's `setup` function:

| Configuration  | Values                                                | Default | Description                                                                                                                        |
| -------------- | ----------------------------------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `show_numbers` | `relative`, `absolute`, `relative_absolute` or `none` | `none`  | Shows relative or absolute numbers before the file icon                                                                            |
| `show_motion`  | `true` or `false`                                     | `false` | Shows current motion in Status bar                                                                                                 |
| `only_motions` | `true` or `false`                                     | `false` | If true, only the motion movements will be enabled, i.e., the commands for delete, cut, yank and visual selection will be disabled |

If you want, for example, to enable relative numbers as well as to show the motion in the status bar,
add the following to Yazi's `init.lua`, i.e. `~/.config/yazi/init.lua`:

```lua
-- ~/.config/yazi/init.lua
require("relative-motions"):setup({ show_numbers="relative", show_motion = true })
```

> [!NOTE]
> The `show_numbers` and `show_motion` functionalities overwrite [`Current:render`](https://github.com/sxyazi/yazi/blob/ec33085f672e52adb934503d78703b8dd70621a8/yazi-plugin/preset/components/current.lua#L26)
> and [`Status:children_render`](https://github.com/sxyazi/yazi/blob/ec33085f672e52adb934503d78703b8dd70621a8/yazi-plugin/preset/components/status.lua#L173) respectively.
> If you have custom implementations for any of this functions
> you can add the provided `Entity:number` and `Status:motion` to your implementations, just check [here](https://github.com/dedukun/relative-motions.yazi/blob/main/init.lua#L126) how we are doing things.

## Usage

This plugin adds the some basic vim motions like `3k`, `12j`, `10gg`, etc.
The following table show all the available motions:

| Command        | Description         |
| -------------- | ------------------- |
| `j`/`<Down>`   | Move `n` lines down |
| `k`/`<Up>`     | Move `n` lines up   |
| `gj`/`g<Down>` | Go `n` lines down   |
| `gk`/`g<Up>`   | Go `n` lines up     |
| `gg`           | Go to line          |

Furthermore, the following operations were also added:

| Command | Description   |
| ------- | ------------- |
| `v`     | visual select |
| `y`     | Yank          |
| `x`     | Cut           |
| `d`     | Delete motion |

This however must be followed by a direction, which can be `j`/`<Down>`, `k`/`<Up>` or repeating the command key,
which will operate from the cursor down, e.g. `2yy` will copy two files.

Finally, we also support some tab operations:

| Command | Description                          |
| ------- | ------------------------------------ |
| `t`     | create `n` tabs                      |
| `H`     | Move `n` tabs left                   |
| `L`     | Move `n` tabs right                  |
| `gt`    | Go to the `n` tab                    |
| `w`     | Close tab `n`                        |
| `W`     | Close `n` tabs right                 |
| `<`     | Swap current tab with `n` tabs left  |
| `>`     | Swap current tab with `n` tabs right |
| `~`     | Swap current tab with tab `n`        |
