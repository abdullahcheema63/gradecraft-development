<template>
  <div>
    <div class="overlay" :class="modalClass" @click="close"></div>
    <div class="modal" :class="modalClass">
      <h2 class="modal_heading">
        <slot name="heading"></slot>
        <span class="close" @click="close"></span>
      </h2>
      <div class="modal_content">
        <slot name="content"></slot>
      </div>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'modal-component',
  props: {
    modalState: {
      default: false,
      type: Boolean
    }
  },
  methods: {
    close() {
      this.$emit("close");
    }
  },
  computed: {
    modalClass() {
      if (this.modalState) {
        return 'is-open';
      }
      return 'is-closed';
    }
  }
}
`</script>
