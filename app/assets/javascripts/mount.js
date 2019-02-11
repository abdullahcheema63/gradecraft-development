Vue.component('hello', VComponents['index']);

var vm = new Vue({
  el: 'footer',
  render: function(createElement) {
    return createElement('hello')
  }
})
