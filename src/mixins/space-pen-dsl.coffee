Mixin = require 'mixto'

Tags =
  'a abbr address article aside audio b bdi bdo blockquote body button canvas
   caption cite code colgroup datalist dd del details dfn dialog div dl dt em
   fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header html i
   iframe ins kbd label legend li main map mark menu meter nav noscript object
   ol optgroup option output p pre progress q rp rt ruby s samp script section
   select small span strong style sub summary sup table tbody td textarea tfoot
   th thead time title tr u ul var video area base br col command embed hr img
   input keygen link meta param source track wbr'.split /\s+/

SelfClosingTags = {}
'area base br col command embed hr img input keygen link meta param
 source track wbr'.split(/\s+/).forEach (tag) -> SelfClosingTags[tag] = true

Events =
  'blur change click dblclick error focus input keydown
   keypress keyup load mousedown mousemove mouseout mouseover
   mouseup resize scroll select submit unload'.split /\s+/

module.exports =
class SpacePenDSL extends Mixin
  @includeInto: (klass) ->
    super(klass)

    Object.defineProperty klass, 'content',
      enumerable: false
      get: -> @prototype.__content__
      set: (value) -> @prototype.__content__ = value

    Object.defineProperty klass::, 'createdCallback',
      enumerable: false
      get: -> @__create__
      set: (value) -> @__createdCallback__ = value

    Object.defineProperty klass::, '__create__',
      enumerable: false
      value: ->
        SpacePenDSL.buildContent(this, @__content__) if @__content__?

        do @__createdCallback__ if @__createdCallback__?

  @buildContent: (element, content) ->
    template = new Template

    content.call(template)

    [html] = template.buildHtml()
    element.innerHTML = html

    @wireOutlets(element)

  @wireOutlets: (view) ->
    for element in view.querySelectorAll('[outlet]')
      outlet = element.getAttribute('outlet')
      view[outlet] = element
      element.removeAttribute('outlet')

    undefined

class Template
  constructor: -> @currentBuilder = new Builder

  Tags.forEach (tagName) ->
    Template::[tagName] = (args...) -> @currentBuilder.tag(tagName, args...)

  subview: (name, view) -> @currentBuilder.subview(name, view)

  text: (string) -> @currentBuilder.text(string)

  tag: (tagName, args...) -> @currentBuilder.tag(tagName, args...)

  raw: (string) -> @currentBuilder.raw(string)

  buildHtml: -> @currentBuilder.buildHtml()

class Builder
  constructor: ->
    @document = []
    @postProcessingSteps = []

  buildHtml: ->
    [@document.join(''), @postProcessingSteps]

  tag: (name, args...) ->
    options = @extractOptions(args)

    @openTag(name, options.attributes)

    if SelfClosingTags.hasOwnProperty(name)
      if options.text? or options.content?
        throw new Error("Self-closing tag #{name} cannot have text or content")
    else
      options.content?()
      @text(options.text) if options.text
      @closeTag(name)

  openTag: (name, attributes) ->
    if @document.length is 0
      attributes ?= {}

    attributePairs =
      for attributeName, value of attributes
        "#{attributeName}=\"#{value}\""

    attributesString =
      if attributePairs.length
        " " + attributePairs.join(" ")
      else
        ""

    @document.push "<#{name}#{attributesString}>"

  closeTag: (name) ->
    @document.push "</#{name}>"

  text: (string) ->
    escapedString = string
      .replace(/&/g, '&amp;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')

    @document.push escapedString

  raw: (string) ->
    @document.push string

  subview: (outletName, subview) ->
    subviewId = "subview-#{++idCounter}"
    @tag 'div', id: subviewId
    @postProcessingSteps.push (view) ->
      view[outletName] = subview
      subview.parentView = view
      view.find("div##{subviewId}").replaceWith(subview)

  extractOptions: (args) ->
    options = {}
    for arg in args
      switch typeof(arg)
        when 'function'
          options.content = arg
        when 'string', 'number'
          options.text = arg.toString()
        else
          options.attributes = arg
    options
