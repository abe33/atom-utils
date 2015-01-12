global.Promise = require 'promise'

class Package
  constructor: (@name) ->
    @mainModule = {}

global.mockPackageManager = ->
  manager = atom.packages

  beforeEach ->
    atom.packages =
      activatePackage: (packageName) ->
        new Promise (resolve, reject) ->
          resolve(new Package(packageName))

  afterEach ->
    atom.packages = manager
