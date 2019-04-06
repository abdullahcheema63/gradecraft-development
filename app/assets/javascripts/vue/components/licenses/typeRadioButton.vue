<template>
  <li>
    <label :for="licenseType.id">{{licenseType.name}}</label>
    <input type="radio" 
      @click="onSelected"
      :value="licenseType.id" 
      v-model="selected"
       />
  </li>
</template>

<script lang="coffee">
```
module.exports = {
  name: "type-radio-button",
  props: {
    licenseType: Object,
    selected: Object,
    onSelected: Function,
  }
}
```
</script>