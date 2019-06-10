/**
 * VComponents is the name of a global object used by rails-vue-loader to
 * register components so they can be used from other components. Since
 * Sprockets loads the tree in alphabetical order, we couldn’t access components
 * that had not been registered yet.
 *
 * Vue supports lazy-loaded components by setting the component name to a
 * promise-returning function in the `components` object, but the standard
 * VComponents global doesn’t use promises.
 *
 * This class makes VComponents a little smarter, adding a method that wraps
 * standard property lookup in a promise so it can be loaded lazily.
 *
 * Note: it must be required before mount
 *
 * Usage:
 *   module.exports = {
 *     ...
 *     components: {
 *       componentName: () => VComponents.get('vue/components/componentName')
 *     }
 *   }
 */

function VComponents() {}

VComponents.prototype.get = function get(path) {
  return Promise.resolve(this[path])
}

window.VComponents = new VComponents()
