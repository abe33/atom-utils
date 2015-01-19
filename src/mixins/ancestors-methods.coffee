Mixin = require 'mixto'

module.exports =
class AncestorsMethods extends Mixin
  @parents: (node, selector='*') ->
    parents = []
    @eachParent (parent) -> parents.push(parent) if parent.matches?(selector)
    parents

  @eachParent: (node, block) ->
    parent = node.parentNode

    block(parent) if parent?
    while parent = parent.parentNode
      block(parent) if parent?

  parents: (selector='*') -> AncestorsMethods.parents(this, selector)

  eachParent: (block) -> AncestorsMethods.eachParent(this, block)
