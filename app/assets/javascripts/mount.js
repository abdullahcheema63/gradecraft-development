//= require vue
//= require vuex
//= require_tree ./vue

document.addEventListener('DOMContentLoaded', function() {
  const selector = "[data-component]";
  const rootElems = document.querySelectorAll(selector);
  if (rootElems.length < 1) {
    return;
  }

  for (k in VComponents) {
    const sanitizedKey = k
      .replace("vue/components/", "")
      .replace("/", "-");
    const v = VComponents[k];
    Vue.component(sanitizedKey, v);
  }
  
  [...rootElems].map((e) => 
    new Vue({
      el: e,
      render: function (createElement) {
        return createElement(e.dataset.component, {
          props: e.dataset.props
            ? JSON.parse(e.dataset.props)
            : undefined,
        });
      },
    }));
});