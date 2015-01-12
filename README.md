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

### EventsDelegation

A mixin that provides events delegation ala jQuery without jQuery.
Use it by including it into your custom element:

```coffee
{EventsDelegation} = require 'atom-utils'

class DummyNode extends HTMLElement
  EventsDelegation.includeInto(this)

  createdCallback: ->
    @appendChild(document.createElement('div'))
    @firstChild.appendChild(document.createElement('span'))

    @subscribeTo this,
      click: (e) ->
        console.log("won't be called if the click is done on the child div")

    @subscribeTo this, 'div',
      click: (e) ->
        console.log("won't be called if the click is done on the child span")
        e.stopPropagation()

    @subscribeTo this, 'div span',
      click: (e) ->
        e.stopPropagation()

DummyNode = document.registerElement 'dummy-node', prototype: DummyNode.prototype
```
