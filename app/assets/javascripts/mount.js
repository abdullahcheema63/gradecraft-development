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
      components: sanitaryComponents,
      render: function (createElement) {
        return createElement(e.dataset.component, {
          props: e.dataset.props
            ? JSON.parse(e.dataset.props)
            : undefined,
        });
      },
    }));
});