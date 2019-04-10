<template>
  <div>
    <input type="radio"
      @click="onSelected"
      :value="licenseType.id"
      :id="licenseType.id"
      v-model="selected"
       />
    <label :for="licenseType.id">
      <h3 class="lining_figures">{{licenseType.name}}</h3>
      <div>
        <p>
          Hello!
        </p>
      </div>
    </label>
  </div>
</template>

<script lang="coffee">
```
module.exports = {
  name: "licenses-type-radio-button",
  props: {
    licenseType: Object,
    selected: Object,
    onSelected: Function,
  }
}
```
</script>
