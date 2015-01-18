Mixin = require 'mixto'

module.exports =
class AncestorsMethods extends Mixin
  parents: (selector='*') ->
    parents = []
    @eachParent (parent) -> parents.push(parent) if parent.matches?(selector)
    parents

  eachParent: (block) ->
    parent = @parentNode

    block(parent) if parent?
    while parent = parent.parentNode
      block(parent) if parent?
