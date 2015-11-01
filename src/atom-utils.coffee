
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
        failHandler = (reason) ->
          failures[i] = reason
          solved()

        promise = atom.packages.activatePackage(pkg)
        .then (activatedPackage) ->
          required[i] = activatedPackage.mainModule
          solved()

        if promise.fail?
          promise.fail(failHandler)
        else if promise.catch?
          promise.catch(failHandler)

  registerOrUpdateElement: require './register-or-update-element'
  Ancestors: require './mixins/ancestors'
  AncestorsMethods: require './mixins/ancestors'
  DisposableEvents: require './mixins/disposable-events'
  EventsDelegation: require './mixins/events-delegation'
  ResizeDetection: require './mixins/resize-detection'
  SpacePenDSL: require './mixins/space-pen-dsl'
