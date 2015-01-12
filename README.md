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
{CompositeDisposable} = require 'event-kit'

class DummyNode extends HTMLElement
  # It includes the mixin on the class prototype.
  EventsDelegation.includeInto(this)

  # Custom element's callback on creation.
  createdCallback: ->
    @subscriptions = new CompositeDisposable

    @appendChild(document.createElement('div'))
    @firstChild.appendChild(document.createElement('span'))

    # Without a target and a selector, it registers to the event on the
    # element itself.
    # The `subscribeTo` method returns a disposable that unsubscribe from
    # all the events that was added by this call.
    @subscriptions.add @subscribeTo
      click: (e) ->
        console.log("won't be called if the click is done on the child div")

    # With just a selector, it registers to the event on the elements children
    # matching the passed-in selector.
    @subscriptions.add @subscribeTo 'div',
      click: (e) ->
        console.log("won't be called if the click is done on the child span")
        e.stopPropagation()

    # By passing a node and a selector, it registers to the event on the
    # elements children matching the passed-in selector.
    @subscriptions.add @subscribeTo @firstChild, 'span',
      click: (e) ->
        e.stopPropagation()

# It creates the custom element and register with as the `dummy-node` tag.
DummyNode = document.registerElement 'dummy-node', prototype: DummyNode.prototype
```
