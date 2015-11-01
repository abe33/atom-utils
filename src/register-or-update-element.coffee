
window.__CUSTOM_HTML_ELEMENTS_CLASSES__ ?= {}
callbackProperties = ['createdCallback', 'attachedCallback','detachedCallback','attributeChangedCallback']
decorateElementPrototype = (target, source) ->
  for k in Object.keys(source)
    continue if k is 'constructor'

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

module.exports = (nodeName, proto) ->
  if __CUSTOM_HTML_ELEMENTS_CLASSES__[nodeName]
    elementClass = __CUSTOM_HTML_ELEMENTS_CLASSES__[nodeName]

    decorateElementPrototype(elementClass.prototype, proto)
    elementClass
  else
    elementPrototype = Object.create(HTMLElement.prototype)
    decorateElementPrototype(elementPrototype, proto)

    elementClass = document.registerElement nodeName, prototype: Object.create(elementPrototype)
    __CUSTOM_HTML_ELEMENTS_CLASSES__[nodeName] = elementClass
