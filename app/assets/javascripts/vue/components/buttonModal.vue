<template>
  <div>
    <button :class=button_class @click="toggleModalState">
      <slot name="button-text"></slot>
    </button>

    <modalComponent :modalState="modalState" @close="toggleModalState" class="component_container">
      <template slot="heading">
        <slot name="heading"></slot>
      </template>
      <template slot="content">
        <slot name="content"></slot>
      </template>
    </modalComponent>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'button-modal-pair',
  props: ['button_class'],
  components: {
    modalComponent: () => VComponents.get('vue/components/modalComponent')
  },
  data() {
    return {
      modalState: false
    }
  },
  methods: {
    close() {
      this.$emit("close");
    },
    toggleModalState(){
      this.modalState = !this.modalState
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
