# xrandr export

A quick little Bash script for exporting the current display settings as an
`xrandr` command, making it easy to save display profiles whilst using your
desktop environment’s GUI tool for modifying the display settings.

### Example output

```
$ ./xrandr-export.sh
xrandr --output LVDS-1 --primary --pos 0x0 --rotate normal --reflect normal --mode 1440x900 --rate 59.94
```

