# Waybar-Clockify [![Licence](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) 

> Track and display [Clockify](https://clockify.me/)'s time entry at `Waybar`

https://user-images.githubusercontent.com/57322459/187881265-150b0227-c0b4-41c7-97d7-c203fbcebb27.mp4

## Description

`Waybar-Clockify` is a simple wrapper between [clockify-cli](https://github.com/lucassabreu/clockify-cli) and [timewarrior](https://github.com/GothenburgBitFactory/timewarrior).

### Why?

I love `timewarrior`, but I find the summary and report functionalities lacking, while `Clockify` offers rich reports and time analysis:

![clockify-2.png](./assets/clockify-2.png)

Fortunately, we have `clockify-cli` which offers amazing integration with `Clockify`. Hence the birth of `Waybar-Clockify`.

## Getting Started

### Dependencies

- [Waybar](https://github.com/Alexays/Waybar)
- [timewarrior](https://github.com/GothenburgBitFactory/timewarrior)
- [clockify-cli](https://github.com/lucassabreu/clockify-cli)
- [rofi](https://github.com/davatorium/rofi)
- [jq](https://github.com/stedolan/jq)
- [fzf](https://github.com/junegunn/fzf) (optional if you want to control through terminal)

### Installation

1. Clone this repository:
`git clone https://github.com/kohane27/Waybar-Clockify.git`

2. Put the directory `src/Waybar-Clockify` under `~/.config/waybar/scripts/Waybar-Clockify`:

```
❯ tree -L 3
.
├── config
├── scripts
│   ├── custom-script.sh
│   └── Waybar-Clockify
│       ├── click.sh
│       ├── main.sh
│       └── stop.sh
│       ├── clockify-tags.txt
└── style.css
```

3. Make `click.sh`, `main.sh` and `stop.sh` executable:

`chmod +x click.sh main.sh stop.sh`

4. Add `Waybar-Clockify` module to `~/.config/waybar/config`:

```bash
    "custom/Waybar-Clockify": {
    "format": " {} ",
    "exec": "~/.config/waybar/scripts/Waybar-Clockify/main.sh",
    "on-click": "~/.config/waybar/scripts/Waybar-Clockify/click.sh",
    "on-click-right": "~/.config/waybar/scripts/Waybar-Clockify/stop.sh",
    },
```

5. Add the module to whichever modules you want the timer to appear. In this example it's `modules-right`:

```
    "modules-right": [
        "custom/Waybar-Clockify",
        "cpu",
        "memory"
    ],
```

6. Restart `Waybar` and the timer should appear

7. (Optional) Add the following two shell functions to `~/.bashrc` or `~/.zshrc`:

```bash
ti() {
  # no running instance
  if [[ "$(timew get dom.active)" == 0 ]]; then
    timew start > /dev/null 2>&1
    print -z timew tag @1 \'"$(cat <~/.config/waybar/scripts/Waybar-Clockify/clockify-tags.txt | fzf)"\'
  fi
  # already have a running instance with tag(s)
  if [[ "$(timew get dom.active)" == 1 ]] && [[ "$(timew get dom.active.tag.count)" == 1 ]]; then
    return
  fi
}

to() {
    ~/.config/waybar/scripts/Waybar-Clockify/stop.sh
}
```

You may choose whatever function command names you want. For example, if you're used to [timewarrior: zsh plugin for timewarrior](https://github.com/svenXY/timewarrior), then you can use the default `twa` and `two`.

## Usage

I recommend getting familiar with `clockify-cli` and `timewarrior` before using.

I. Purely through Waybar:

https://user-images.githubusercontent.com/57322459/187881265-150b0227-c0b4-41c7-97d7-c203fbcebb27.mp4

1. Left click to start
2. Use rofi to choose predefined tag in `clockify-tags.txt`
3. Right click to stop

II. Purely through the command line:

https://user-images.githubusercontent.com/57322459/187881260-48ad1ad1-7964-4a61-8b84-2f1fb8876fc0.mp4

If you've added the optional shell functions to `~/.bashrc` or `~/.zshrc` (step 7 above):

1. Start the timer with `ti`
2. Choose predefined tag in `clockify-tags.txt`
3. Stop the timer with `to`

III. Start in command line and stop in Waybar

IV. Start in Waybar and stop in command line

## Architecture

Permissive that default values are used.
If no Project, Description, Tags are provided, default values are used.

I can continue using `timewarrior` to track time from the command line.

So any `timewarrior` commands like `cancel`, `continue`, `lengthen`, `shorten` will work.

I want to display a timer on `Waybar`.

`Waybar` will display the latest time tracked by `timewarrior`.

At the end of each time record, `Waybar-Clockify` will send it to clockify.

## How `Waybar-Clockify` works

Once the record is done, `Waybar-Clockify` will use `clockify-cli` to send the record to `clockify`:

When you right-click the Waybar module or use the command `to`, it'll trigger the follow `clockify-cli` command:

```sh
clockify-cli manual \
  --project "$project" \
  --description "$description" \
  --when "$start" \
  --when-to-close "$end" \
  --tag "$tag"
  --interactive=0
```

## Caveats

I. Inside `clockify-tags.txt`, you'll find the following two samples:

```
{"p": "Code","t":["clientA","career"], "d": ""}
{"p": "Code","t":["clientB","career"], "d": ""}
{"p": "Entertainment","t": ["youtube"], "d": ""}
{"p": "Entertainment","t": ["movie"], "d": ""}
```

I use the timewarrior tag field

TODO rewrite
When you finish tracking a time record, each line will become a timewarrior tag record. 

I hijacked it to become a json for `clockify-cli` to consume. Meaning of each key-value pair:

- `p`: project
- `t`: tags
- `d`: description

which correspond to PROJECT, TAGS and DESCRIPTION in `clockify-cli`:

```
❯ clockify-cli report
+--------------------------+---------------------+---------------------+---------+---------------+-------------+------+------------------------------------+
|            ID            |        START        |         END         |   DUR   |    PROJECT    | DESCRIPTION | TASK |                TAGS                |
+--------------------------+---------------------+---------------------+---------+---------------+-------------+------+------------------------------------+
| 63121910b456dc322924eb1f | 2022-09-01 08:00:00 | 2022-09-01 09:00:00 | 1:00:00 | Health        | gym         |      | gym (630328ec899ba763d36b39d7)     |
|                          |                     |                     |         |               |             |      | weight (630106dd96dd4c674e51a45a)  |
+--------------------------+---------------------+---------------------+---------+---------------+-------------+------+------------------------------------+
| 63131a977f07da44c10f6a21 | 2022-09-01 09:52:59 | 2022-09-01 10:49:00 | 0:56:01 | Entertainment | yt          |      | ent-vid (6306445eb59c366b3eaz4280) |
+--------------------------+---------------------+---------------------+---------+---------------+-------------+------+------------------------------------+
| TOTAL                    |                     |                     | 1:56:01 |               |             |      |                                    |
+--------------------------+---------------------+---------------------+---------+---------------+-------------+------+------------------------------------+
```

You need to make sure `p`(`project`) and `t`(`tags`) fields exist in clockify, or else `Waybar-Clockify` will fail. In the above example, the projects `Entertainment` and `Health`, and the tags `ent-vid`, `gym`, `weight` need to exist in clockify.

To see the projects available `clockify-cli project list --not-archived --csv`.

To see the tags available: `clockify-cli tag`.

II. Back up your `.timewarrior` data.

I use `timewarrior` as a medium between `Waybar-Clockify` and `clockify-cli`. It'll append records like below to `~/.timewarrior/data/2022-08.data`:

```
inc 20220831T091726Z - 20220831T091729Z # "{\"p\": \"Config\",\"d\": \"\",\"t\": [\"config\"]}"
inc 20220831T091819Z - 20220831T091822Z # "{\"p\": \"Entertainment\",\"d\": \"\",\"t\": [\"ent-vid\"]}"
inc 20220831T133109Z - 20220831T133121Z # "{\"p\": \"Code\",\"t\": [\"code\",\"personal\"], \"d\": \"client A\"}"
```

Please consider this modification of timewarrior data before using `Waybar-Clockify`.

## Roadmap

- [ ] `fzf`: after selection, move cursor inside `d` field so it's ready for input:
`'{"p": "Health","t":["gym","weight", "d": "|"]}'`

## Contributing

Any contributions you make are **greatly appreciated**. If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

`Waybar-Clockify` is licensed under the MIT license. [See LICENSE for more information](https://github.com/kohane27/Waybar-Clockify/blob/main/LICENSE).

## Acknowledgments

* [Waybar](https://github.com/Alexays/Waybar)
* [timewarrior](https://github.com/GothenburgBitFactory/timewarrior)
* [clockify-cli](https://github.com/lucassabreu/clockify-cli)
* [rofi](https://github.com/davatorium/rofi)
* [fzf](https://github.com/junegunn/fzf)
* [jq](https://github.com/stedolan/jq)

