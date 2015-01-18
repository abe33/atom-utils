
module.exports =
  requirePackages: (packages...) ->
    new Promise (resolve, reject) ->
      required = []
      failures = []
      remains = packages.length

      solved = ->
        remains--
        return unless remains is 0
        return reject(failures) if failures.length > 0
        resolve(required)

      packages.forEach (pkg, i) ->
        atom.packages.activatePackage(pkg)
        .then (activatedPackage) ->
          required[i] = activatedPackage.mainModule
          solved()
        .fail (reason) ->
          failures[i] = reason
          solved()

  AncestorsMethods: require './mixins/ancestors-methods'
  DisposableEvents: require './mixins/disposable-events'
  EventsDelegation: require './mixins/events-delegation'
  SpacePenDSL: require './mixins/space-pen-dsl'
