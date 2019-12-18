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
        <slot name="submit-button"></slot>
        <slot name="cancel-link">
          <a @click="close">Cancel</a>
        </slot>
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
  mounted(){
    this.$root.$on('closeAllModals', data => {
      console.log("Triggered closeallModals from mounted method in modal component")
      this.close()
    });
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
  },
  directives: {
    modalPresent: {
      inserted: function(el){
        document.querySelector(".wrapper").classList.add("freeze");
      },
      compontentUpdated: function(el){
        console.log(el)
        document.querySelector(".wrapper").classList.remove("freeze");
      }
    }
  }
}
`</script>
