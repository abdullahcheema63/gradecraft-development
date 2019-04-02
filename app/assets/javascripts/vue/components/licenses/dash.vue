<template>
  <div>
    <h1>Your License</h1>
    <licenses-details v-if="hasLicense" :license="license"/>
    <licenses-course-selector @updated="onUpdated" v-if="hasLicense" :license="license" :courses="courses" />
    <button @click="toggleRenew">Toggle Renewal Form</button>
    <licenses-renew-form @updated="onUpdated" v-show="showRenew" v-if="hasLicense" :license="license" :license-type="licenseType" :stripePk="stripePk" />
    <licenses-buy-form @updated="onUpdated" v-if="!hasLicense" :license-types="licenseTypes" :stripePk="stripePk" />
  </div>
</template>

<script lang="coffee">
```
const data = {
  license: undefined,
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

module.exports = {
  components: {
    "licenses-buy-form": () => VComponents.get("vue/components/licenses/buy-form"),
    "licenses-renew-form": () => VComponents.get("vue/components/licenses/renew-form"),
    "licenses-course-selector": () => VComponents.get("vue/components/licenses/course-selector"),
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
    licenseType: function() {
      return this.license
        ? this.licenseTypes.find(lt => lt.id === this.license.license_type_id)
        : "no license";
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
      data.courses = coursesFromResponse(json);
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