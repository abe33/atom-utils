{requirePackages} = require '../lib/atom-utils'

describe 'requirePackages', ->
  it 'returns a promise resolved at package activation', ->
    runs ->
      requirePackages('foo', 'bar', 'baz').then (pkgs) ->
        expect(pkgs.length).toEqual(3)
