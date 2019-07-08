<template>
  <div class="tab_block">
    <div class="tabs">
      <div class="tab_bar">
        <slot name="tabBarNav"></slot>
      </div>
    </div>
    <div class="tab_sections content_block">
      <slot name="tabSections"></slot>
    </div>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'tab-container',
  data() {
    return {
      active: false
    }
  }
}
`</script>
