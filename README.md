## atom-utils

[![Build Status](https://travis-ci.org/abe33/atom-utils.svg?branch=master)](https://travis-ci.org/abe33/atom-utils)

A bunch of general purpose utilities for Atom packages.

### requirePackages

Returns a promise that is only resolved when all the requested packages have been activated.

```coffee
{requirePackages} = require 'atom-utils'

requirePackages('tree-view', 'find-and-replace', 'snippets')
.then ([treeView, findAndReplace, snippets]) ->
  # Do something with the required packages
```
