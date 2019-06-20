<template>
  <div>
    <p>
      Your
      <b>{{license.license_type_name}} licensed account </b>
      allows you to create <b>{{license.max_courses || "unlimited"}} licensed courses</b>, which have the ability to:
    </p>

    <ul>
      <li>Integrate with other tools (like Canvas or Moodle)</li>
      <li>Import or add other users (such as assistants and students)</li>
    </ul>

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
  },
}
```
</script>
