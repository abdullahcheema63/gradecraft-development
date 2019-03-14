<template>
  <div>
    <button @click="toggleModalState">
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
  components: {
    modalComponent: () => VComponents.get('vue/components/modalComponent')
  },
  props: {
    modalState: {
      default: false,
      type: Boolean
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
