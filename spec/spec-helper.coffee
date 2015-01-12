global.Promise = require 'promise'

class Package
  constructor: (@name) ->
    @mainModule = {}

global.atom =
  packages:
    activatePackage: (packageName) ->
      new Promise (resolve, reject) ->
        resolve(new Package(packageName))
