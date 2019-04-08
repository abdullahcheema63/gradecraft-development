<template>
  <div>
    <h1>Your License</h1>
    <licenses-details v-if="hasLicense" :license="license"/>
    <licenses-course-selector @updated="onUpdated" v-if="hasLicense" :license="license" :courses="courses" />
    <button v-if="hasLicense" @click="toggleRenew">Toggle Renewal Form</button>
    <licenses-renew-form @updated="onUpdated" v-show="showRenew" v-if="hasLicense" :license="license" :license-type="licenseType" :stripePk="stripePk" />
    <licenses-buy-form @updated="onUpdated" v-if="!hasLicense" :license-types="licenseTypes" :stripePk="stripePk" />
  </div>
</template>

<script lang="coffee">
```
const data = {
  license: undefined,
  licenseTypes: [],
  courses: [],
  showRenew: false,
};

const api = "/api/licenses";

const getService = (serviceName) =>
  angular.element(document.body).injector().get(serviceName);

const getAPIHelper = () =>
  getService("GradeCraftAPI");

const apiResponseToData = (responseJson) =>
  getAPIHelper().dataItem(responseJson.data, responseJson, { include: [ "courses", "payments" ] });

const coursesFromResponse = (responseJson) => {
  const arr = [];
  getAPIHelper().loadFromIncluded(arr, "courses", responseJson)
  return arr;
}

const licenseTypesFromResponse = (responseJson) => {
  const arr = [];
  getAPIHelper().loadFromIncluded(arr, "license_types", responseJson)
  return arr;
}

module.exports = {
  name: "licenses-dash",
  components: {
    "licenses-buy-form": () => VComponents.get("vue/components/licenses/buyForm"),
    "licenses-renew-form": () => VComponents.get("vue/components/licenses/renewForm"),
    "licenses-course-selector": () => VComponents.get("vue/components/licenses/courseSelector"),
    "licenses-details": () => VComponents.get("vue/components/licenses/details"),
  },
  data: function() { return data; },
  props: {
    stripePk: String,
  },
  computed: {
    hasLicense: function() {
      return !!this.license;
    },
    licenseType: function() {
      return (this.license && this.licenseTypes)
        ? this.licenseTypes.find(lt => lt.id === this.license.license_type_id)
        : undefined;
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
      console.log(json);
      data.courses = coursesFromResponse(json);
      data.licenseTypes = licenseTypesFromResponse(json);
      console.log(data.licenseTypes);
      const final = apiResponseToData(json);
      return final;
    },
    toggleRenew: function() {
      this.showRenew = !this.showRenew;
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