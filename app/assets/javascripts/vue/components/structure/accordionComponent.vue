<template>
  <div class="accordion">
    <h3 :class="{open:active}" @click="toggleActive">
      <span></span>
      <slot name="heading"></slot>
    </h3>
    <div :class="accordionClass">
      <div :class=accordion_content>
        <slot name="content"></slot>
      </div>
    </div>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'accordion-component',
  props: ['open_default', 'accordion_content'],
  data() {
    return {
      active: this.open_default,
    }
  },
  methods: {
    toggleActive() {
      this.active = !this.active;
    }
  },
  computed: {
    accordionClass() {
      if (this.active) {
        return 'is-open';
      }
      return 'is-closed';
    }
  }
}
`</script>
