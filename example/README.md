# example using material_symbols_icons package.

Example app allowing browsing of the Material Symbols Icons.
This can be build for any platform.

```

#build for github>>> flutter build web --release --web-renderer canvaskit --base-href "/material_symbols_icons/"

# building for web
flutter build web --release --web-renderer canvaskit

# serve http to localhost:8080
dhttpd --path=build\web


```


With new tree shaking for web on master channel this still results large savings EVEN WHEN USING EVERY ICON in each of the
Material Symbols Icons fonts.  (This is most likely because of letters and numbers/regular symbols present in these fonts being removed):

```
Font asset "CupertinoIcons.ttf" was tree-shaken, reducing it from 283452 to 1236 bytes (99.6% reduction). Tree-shaking
can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 10808 bytes (99.3% reduction).
Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialSymbolsOutlined[FILL,GRAD,opsz,wght].ttf" was tree-shaken, reducing it from 6944756 to 4781576 bytes
(31.1% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf" was tree-shaken, reducing it from 9361824 to 6397020 bytes
(31.7% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialSymbolsSharp[FILL,GRAD,opsz,wght].ttf" was tree-shaken, reducing it from 5848492 to 4079548 bytes
(30.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib\main.dart for the Web...                             51.2s
```

