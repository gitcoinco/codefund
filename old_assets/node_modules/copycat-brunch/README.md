# copycat-brunch

 Inspired from copyfilemon-brunch (which in turn is inspired from assetsmanager-brunch), this plugin makes a similar uses quickly-copy-file plugin.

install:
```nodejs
npm i copycat-brunch
```

demo of use:
```javascript
plugins:{
  copycat:{
    "fonts" : ["bower_components/material-design-iconic-font", "bower_components/font-awesome/fonts"],
    "images": ["someDirectoryInProject", "bower_components/some_package/assets/images"],
    verbose : true, //shows each file that is copied to the destination directory
    onlyChanged: true //only copy a file if it's modified time has changed (only effective when using brunch watch)
  }
}
```

As you can see in [brunch-docs](https://github.com/brunch/brunch/tree/master/docs), the default folder of your static files is public, but you can prefer any other folder to do this.

You can copy file by file, or if you desired copy a folder structure and files content.

## License

The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
