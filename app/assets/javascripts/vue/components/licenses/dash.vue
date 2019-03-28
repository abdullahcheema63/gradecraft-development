<template>
  <div>
    <h2>Your License</h2>
    <p>Do you have a license? {{hasLicense ? "YUP" : "NOPE"}}</p>
    <licenses-details v-if="hasLicense" :license="license"/>
    <licenses-renew-form @updated="onUpdated" v-if="hasLicense" :license="license" :stripePk="stripePk" />
    <licenses-buy-form @updated="onUpdated" v-if="!hasLicense" :license-types="licenseTypes" :stripePk="stripePk" />
  </div>
</template>

<script lang="coffee">
```
const data = {
  license: undefined,
};

const api = "/api/licenses";

const getService = (serviceName) =>
  angular.element(document.body).injector().get(serviceName);

const getAPIHelper = () =>
  getService("GradeCraftAPI");

const apiResponseToData = (responseJson) =>
  getAPIHelper().dataItem(responseJson.data, responseJson);

module.exports = {
  components: {
    "licenses-buy-form": () => VComponents.get("vue/components/licenses/buy-form"),
    "licenses-renew-form": () => VComponents.get("vue/components/licenses/renew-form"),
    "licenses-details": () => VComponents.get("vue/components/licenses/details"),
  },
  data: function() { return data; },
  props: {
    licenseTypes: Array,
    stripePk: String,
  },
  computed: {
    hasLicense: function() {
      return !!this.license;
    },
  },
  methods: {
    getLicense: async function() {
      const resp = await fetch(api);
      if (resp.status === 404) {
        return undefined;
      }
      else if (!resp.ok) {
        throw resp;
      }
      const json = await resp.json();
      return apiResponseToData(json);
    },
    onUpdated: function(license) {
      console.log("onUpdated");
      console.log(license);
      data.license = license;
    },
  },
  created: async function() {
    data.license = await this.getLicense();
  },
}
```
</script>