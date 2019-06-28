<template>
  <div>
    <slot name="header"></slot>
    <div class="tab_container">
      <slot name="question"></slot>
      <div class="tab_contents">
        <slot name="form-response"></slot>
      </div>
    </div>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'form-container',
  props: {
    hello: "hello"
  },
  data() {
    return {
      active: false
    }
  }
}
`</script>
