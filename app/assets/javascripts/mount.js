//= require vue
//= require vuex
//= require_tree ./vue

document.addEventListener('DOMContentLoaded', function() {
  const selector = "[data-component]";
  const rootElems = document.querySelectorAll(selector);
  if (rootElems.length < 1) {
    return;
  }

  const components = {};
  for (k in VComponents) {
    const sanitizedKey = k
      .replace("vue/components/", "")
      .replace("/", "-");
    const v = VComponents[k];
    components[sanitizedKey] = v;
  }

  for (el of rootElems) {
    console.log(el);
    new Vue({
      el,
      store,
      components,
    });
  }
});
