{deprecate} = require 'grim'

if window.__CUSTOM_HTML_ELEMENTS_CLASSES__?
  window.__ATOM_UTILS_CUSTOM_ELEMENT_CLASSES__ = window.__CUSTOM_HTML_ELEMENTS_CLASSES__
  delete window.__CUSTOM_HTML_ELEMENTS_CLASSES__
else
  window.__ATOM_UTILS_CUSTOM_ELEMENT_CLASSES__ ?= {}

callbackProperties = [
  'createdCallback'
  'attachedCallback'
  'detachedCallback'
  'attributeChangedCallback'
]

decorateElementPrototype = (target, source) ->
  callbackProperties.forEach (k) ->
    Object.defineProperty target, k, {
      value: -> @["__#{k}"]?.apply(this, arguments)
      writable: true
      enumerable: true
      configurable: true
    }

  Object.getOwnPropertyNames(source).forEach (k) ->
    return if k in ['constructor']

    descriptor = Object.getOwnPropertyDescriptor(source, k)
    if callbackProperties.indexOf(k) > -1
      Object.defineProperty(target, "__#{k}", descriptor)
    else
      Object.defineProperty(target, k, descriptor)

decorateElementClass = (target, source) ->
  Object.getOwnPropertyNames(source).forEach (k) ->
    return if k in ['length', 'name', 'arguments', 'caller', 'prototype']

    descriptor = Object.getOwnPropertyDescriptor(source, k)
    Object.defineProperty(target, k, descriptor)

module.exports = (nodeName, options) ->
  {class: klass} = options
  if klass?
    proto = klass.prototype
  else
    proto = options.prototype ? options

  if proto is options
    deprecate('Using the prototype as the second argument is deprecated, use the prototype option instead')


  if __ATOM_UTILS_CUSTOM_ELEMENT_CLASSES__[nodeName]
    elementClass = __ATOM_UTILS_CUSTOM_ELEMENT_CLASSES__[nodeName]

    decorateElementPrototype(elementClass.prototype, proto)
    decorateElementClass(elementClass, klass) if klass?

    elementClass
  else
    elementPrototype = Object.create(HTMLElement.prototype)
    decorateElementPrototype(elementPrototype, proto)

    elementClass = document.registerElement nodeName, prototype: Object.create(elementPrototype)

    decorateElementClass(elementClass, klass) if klass?

    __ATOM_UTILS_CUSTOM_ELEMENT_CLASSES__[nodeName] = elementClass
