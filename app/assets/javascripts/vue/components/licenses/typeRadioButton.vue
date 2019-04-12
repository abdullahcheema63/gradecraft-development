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
        <ul>
          <li>
            <b>${{Math.trunc(licenseType.price_usd)}}</b> for
            <b>{{licenseType.default_max_courses}} course{{licenseType.default_max_courses > 1 ? "s" : ""}}</b>
          </li>
          <li>Up to {{licenseType.default_duration_months}} months </li>
          <li>Up to {{licenseType.default_max_students}} students </li>
        </ul>
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
