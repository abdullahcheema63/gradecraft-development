<template>
  <div>
    <button :class=button_class @click.prevent="openModalState">
      <slot name="button-text"></slot>
    </button>

    <modalComponent :modalState="modalState" @close="close" class="component_container">
      <template slot="heading">
        <slot name="heading"></slot>
      </template>
      <template slot="content" :close="close">
        <slot name="content"></slot>
      </template>
      <template slot="submit-button">
        <slot name="submit-button"></slot>
      </template>
    </modalComponent>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'button-modal-pair',
  props: ['button_class'],
  mounted(){
    this.$root.$on('closeAllModals', data => {
      console.log("Triggered closeallModals from mounted method in buttonmodal component")
      this.close()
    });
  },
  components: {
    modalComponent: () => VComponents.get('vue/components/structure/modalComponent')
  },
  data() {
    return {
      modalState: false
    }
  },
  methods: {
    close() {
      this.closeModalState()
    },
    closeModalState(){
      this.modalState = false
    },
    openModalState(){
      this.modalState = true
    },
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
