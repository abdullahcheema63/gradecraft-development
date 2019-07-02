<template>
  <div>
    <div class="license_summary" v-if="license">
      <h3 class="lining_figures">Current Package: {{license.license_type_name}}</h3>
      <p>
        <b>${{licenseType.price_usd}}</b> for
        <b>{{licenseType.default_max_courses}} course license{{licenseType.default_max_courses > 1 ? "s" : ""}}</b>
      </p>
      <p>Up to {{licenseType.default_duration_months}} months </p>
      <p>Up to {{licenseType.default_max_students}} students </p>
    </div>

    <p v-if="license">
      Your
      <b>{{license.license_type_name}}</b>
      course license package allows you to create
      <b>{{license.max_courses || "unlimited"}} licensed courses</b>.
      <br/>
      Licensed courses can be:
    </p>

    <ul>
      <li>Published, making them visible to your students and other users</li>
      <li>Integrated with other tools (like Canvas or Moodle)</li>
    </ul>

    <p v-if="!courses.length">You don't have any courses!</p>
    <p v-if="courses && license.max_courses !== null">
      You have used
      <strong>{{licensedCourses.length}} of your {{license.max_courses}} course licenses.</strong>
    </p>

    <p>Your license <b>expires {{license.expires}} </b>.</p>

<!-- We may need to make v ifs for the expires/expired info
<p>Expired? {{license.is_expired ? "Yes" : "No"}}</p> -->
  </div>
</template>

<script lang="coffee">
```
module.exports = {
  name: "licenses-details",
  props: {
    license: Object,
    licenseType: Object,
    courses: Array
  },
  computed: {
    licensedCourses(){
      return this.$store.state.userLicense.courses
    },
  }
}
```
</script>
