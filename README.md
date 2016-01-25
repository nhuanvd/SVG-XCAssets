# SVG-XCAssets
Command line tool to make xcode assets image from SVG<br>
Version 0.1.0<br>
Copyright 2016 by [@Nhuanvd](https://twitter.com/nhuanvd)<br>

#### Usage:
Convert one svg:
```
  ./svg_xcassets.sh --source=./flags --name=vn --xcassets=./Assets.xcassets --width=100 --height=100 --group=flag
```
Convert all svgs in a folder:
```
  ./svg_xcassets.sh --all --source=./flags --xcassets=./Assets.xcassets --width=100 --height=100
```

#### Flags:
```
  -h, --help     Display this help
  --all          Convert all svg in source folder (optional)
  --source       Source folder (required)
  --name         Name of svg inage (required if all flag not set)
  --xcassets     Image.xcassets folder (required)
  --width        Width of output image (required) 
  --height       Height of output image (required) 
  --group        Output name prefix (optional)
```

#### Install Dependent Software
Python:
```
brew install python
```
Inkscape:
```
brew install homebrew/x11/inkscape
```
