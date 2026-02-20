# Kitty Theme and UI Notes

These are random notes on various configurations I've tried and liked over the time I've used Kitty, but don't use in my current config. Things I may return to, or others may be interested in trying.

## Background and Window Styles

### Frosted Glass

This are settings to get a cool transparent frosted glass effect, BUT you really need a light/dark dynamic theme or to only use dark mode for everything system-wide, as the clash between a light window behind a dark themed Kitty window destroys readability. If you have everything configured to toggle light and dark themes within Kitty though, and have a powerful enough computer that this doesn't bog down performance, it can look really nice.

If I one day find the time to configure Rose Pine Dawn as a light theme for everything, I may use this.

```kitty.conf
background_opacity         0.6
background_blur            90
background_tint            0.8
dynamic_background_opacity yes

```

### Background Image

This is a set of configs I used for awhile to layer in a background image without affecting my workflow and readability. The key is ensuring the content of the image is positioned at the bottom with partial transparency, then faded to fully transparent quickly above the desired content. With the right tint and opacity settings, you get an unobtrusive transparent overlay towards the bottom of the window, which is generally not where you're focused when you're working, so doesn't get in the way. ImageMagick is the ideal tool for this kind of processing. Also, city skylines work well with this pattern, as they can easily be positioned at the bottom, like a horizon, and still give the impression of their shape well without being fully opaque. For the time being, I find the purity of a solid color more appealing, but this is fun, and I used it for a while.

```kitty.conf
background_image             ~/Pictures/kitty_bg_anime_city_sunset_1.png
background_image_layout      cscaled
background_tint              0.94
dynamic_background_opacity   no
```
