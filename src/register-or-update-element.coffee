
window.__CUSTOM_HTML_ELEMENTS_CLASSES__ ?= {}
callbackProperties = ['createdCallback', 'attachedCallback','detachedCallback','attributeChangedCallback']
decorateElementPrototype = (target, source) ->
  Object.getOwnPropertyNames(source).forEach (k) ->
    return if k is 'constructor'

    descriptor = Object.getOwnPropertyDescriptor(source, k)
    if callbackProperties.indexOf(k) > -1
      Object.defineProperty target, k, {
        value: -> @["__#{k}"].apply(this, arguments)
        writable: true
        enumerable: true
        configurable: true
      }
      Object.defineProperty(target, "__#{k}", descriptor)
    else
      Object.defineProperty(target, k, descriptor)

decorateElementClass = (target, source) ->
  Object.getOwnPropertyNames(source).forEach (k) ->
    return if k is 'prototype'

    descriptor = Object.getOwnPropertyDescriptor(source, k)
    Object.defineProperty(target, k, descriptor)

module.exports = (nodeName, options) ->
  {class: klass} = options
  if klass?
    proto = klass.prototype
  else
    proto = options

  if __CUSTOM_HTML_ELEMENTS_CLASSES__[nodeName]
    elementClass = __CUSTOM_HTML_ELEMENTS_CLASSES__[nodeName]

    decorateElementPrototype(elementClass.prototype, proto)
    decorateElementClass(elementClass, klass) if klass?

    elementClass
  else
    elementPrototype = Object.create(HTMLElement.prototype)
    decorateElementPrototype(elementPrototype, proto)

    elementClass = document.registerElement nodeName, prototype: Object.create(elementPrototype)

    decorateElementClass(elementClass, klass) if klass?

    __CUSTOM_HTML_ELEMENTS_CLASSES__[nodeName] = elementClass
