# example using material_symbols_icons package.

Example app allowing browsing of the Material Symbols Icons.
This can be build for any platform.

```

#build for github>>>
```console
 flutter build web --release --web-renderer canvaskit --base-href "/material_symbols_icons/"

# building for web
flutter build web --release --web-renderer canvaskit

# serve http to localhost:8080
dhttpd --path=build\web
```

------

Building without icon tree shaking - due to a bug in flutter's `font-subset` this is breaking the variable fonts used for Material Symbols Icons.
See https://github.com/flutter/flutter/issues/125704 .
I have submitted a PR fixing this in the flutter engine : https://github.com/flutter/engine/pull/41592 .

In the mean time it is necessary to build the web release with the `--no-tree-shake-icons` in order for all variations to work correctly.

```console
flutter build web --release --web-renderer canvaskit --no-tree-shake-icons --base-href "/material_symbols_icons/"
```

It turns out that the icon tree-shaking is breaking the material symbols variable fonts by dropping the GSUB table.
This causes rendering errors for some variations (such as Fill->1 Weight->100)  I filed an issue addressing this, https://github.com/flutter/flutter/issues/125704 , as well as a PR fixing font-subset so that it preserves these tables for variable fonts - https://github.com/flutter/engine/pull/41592.

This dropping of the GSUB table was the reason for the 30% saving in font size, even in the case of using every material symbol icon.  Unfortunately we cannot keep having this saving AND have the variable fonts work correctly.  After the `font-subset ` fix from https://github.com/flutter/engine/pull/41592 the size savings when using every icon in the fonts is ~2% instead of ~30%.
