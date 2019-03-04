//= require vue
//= require vuex
//= require_tree ./vue

document.addEventListener('DOMContentLoaded', function() {
  const selector = "[data-component]";
  const rootElems = document.querySelectorAll(selector);
  if (rootElems.length < 1) {
    return;
  }

  const sanitaryComponents = {};
  for (k in VComponents) {
    const sanitizedKey = k
      .replace("vue/components/", "")
      .replace("/", "-");
    const v = VComponents[k];
    sanitaryComponents[sanitizedKey] = v;
  }

  [...rootElems].map((e) =>
    new Vue({
      el: e,
      store,
      components: sanitaryComponents,
    }));
});
