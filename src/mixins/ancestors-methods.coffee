Mixin = require 'mixto'

module.exports =
class AncestorsMethods extends Mixin
  @parents: (node, selector='*') ->
    parents = []
    @eachParent node, (parent) -> parents.push(parent) if parent.matches?(selector)
    parents

  @eachParent: (node, block) ->
    parent = node.parentNode

    block(parent) if parent?
    while parent = parent.parentNode
      block(parent) if parent?

  parents: (selector='*') -> AncestorsMethods.parents(this, selector)

  queryParentSelectorAll: (selector) ->
    unless selector?
      throw new Error '::queryParentSelectorAll requires a valid selector as argument'
    @parents(selector)

  queryParentSelector: (selector) ->
    unless selector?
      throw new Error '::queryParentSelector requires a valid selector as argument'
    @queryParentSelectorAll(selector)[0]

  eachParent: (block) -> AncestorsMethods.eachParent(this, block)
