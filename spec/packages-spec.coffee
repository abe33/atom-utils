require './spec-helper'
{requirePackages} = require '../lib/atom-utils'

describe 'requirePackages', ->
  mockPackageManager()

  it 'returns a promise resolved at package activation', ->
    runs ->
      requirePackages('foo', 'bar', 'baz').then (pkgs) ->
        expect(pkgs.length).toEqual(3)
